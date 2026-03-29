import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/config/brand_config.dart';
import '../../../contact/domain/usecases/parse_vcard_usecase.dart';
import '../../../contacts_book/domain/entities/saved_contact.dart';
import '../../../contacts_book/domain/repositories/contacts_book_repository.dart';
import '../../../portfolio/domain/entities/portfolio_item.dart';
import '../../../../config/di/injection_container.dart';

class ScannerPage extends StatefulWidget {
  final BrandConfig brand;
  const ScannerPage({super.key, required this.brand});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with SingleTickerProviderStateMixin {
  // ── Controller — tuned for mobile_scanner 7.x ─────────────────────────────
  //  • detectionSpeed: noDuplicates → fires once per unique barcode
  //  • returnImage: false → skip copying camera frames (biggest perf win)
  //  • autoZoom: true → auto-zooms when QR is far from camera (v7 feature)
  late final MobileScannerController _ctrl;

  bool _scanned = false;
  bool _isProcessing = false; // guards against async race conditions

  // ── Scanning line animation ───────────────────────────────────────────────
  late final AnimationController _lineCtrl;
  late final Animation<double> _lineAnim;

  @override
  void initState() {
    super.initState();

    _ctrl = MobileScannerController(
      formats: [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.noDuplicates,
      detectionTimeoutMs: 500,
      returnImage: false,
      autoZoom: true,
    );

    _lineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _lineAnim = CurvedAnimation(
      parent: _lineCtrl,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _lineCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  // ── Detection callback ────────────────────────────────────────────────────
  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_scanned || _isProcessing) return;

    final raw = capture.barcodes.firstOrNull?.rawValue;
    debugPrint('QR detected: $raw');
    if (raw == null || raw.isEmpty) return;
    if (!raw.contains('BEGIN:VCARD')) return;

    // Lock immediately — before any async gap
    _isProcessing = true;
    setState(() => _scanned = true);

    HapticFeedback.heavyImpact();

    await _ctrl.stop();
    _lineCtrl.stop();

    if (!mounted) return;
    _showResultSheet(raw);
  }

  // ── Result sheet ──────────────────────────────────────────────────────────
  // CRITICAL FIX: .whenComplete() ensures scanner resets no matter HOW the
  // sheet is dismissed (swipe, back button, outside tap, or our own pop).
  void _showResultSheet(String rawVCard) {
    final result = const ParseVCardUseCase()(rawVCard);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ScannedResultSheet(
        result: result,
        brand: widget.brand,
        onSave: () => _saveContact(result),
        onDismiss: () => Navigator.pop(context),
      ),
    ).whenComplete(() {
      _resetScanner();
    });
  }

  /// Resets scanner state so it can detect the next QR code.
  void _resetScanner() {
    if (!mounted) return;
    setState(() {
      _scanned = false;
      _isProcessing = false;
    });
    _lineCtrl.repeat(reverse: true);
    _ctrl.start();
  }

  // ── Save contact (flutter_contacts 1.x API — unchanged) ──────────────────
  Future<void> _saveContact(ScannedCardResult result) async {
    // 1. Save to app's internal contacts book
    final repo = sl<ContactsBookRepository>();
    final saved = SavedContact(
      id: const Uuid().v4(),
      contact: result.contact,
      portfolioItems: result.portfolioItems,
      scannedAt: DateTime.now(),
    );
    await repo.save(saved);

    // 2. Save to native phone contacts book
    try {
      if (await fc.FlutterContacts.requestPermission()) {
        final c = result.contact;
        final nameParts = c.name.trim().split(' ');

        final newContact = fc.Contact()
          ..name.first = nameParts.first
          ..name.last = nameParts.length > 1 ? nameParts.skip(1).join(' ') : ''
          ..organizations = [
            if (c.org.isNotEmpty || c.title.isNotEmpty)
              fc.Organization(company: c.org, title: c.title),
          ]
          ..phones = [
            if (c.phone.isNotEmpty)
              fc.Phone(c.phone, label: fc.PhoneLabel.mobile),
            if (c.phone2.isNotEmpty)
              fc.Phone(c.phone2, label: fc.PhoneLabel.mobile),
          ]
          ..emails = [
            if (c.email.isNotEmpty)
              fc.Email(c.email, label: fc.EmailLabel.work),
          ]
          ..addresses = [
            if (c.address.isNotEmpty)
              fc.Address(c.address, label: fc.AddressLabel.work),
          ]
          ..websites = [
            if (c.website.isNotEmpty)
              fc.Website(c.website, label: fc.WebsiteLabel.work),
            if (c.whatsapp.isNotEmpty)
              fc.Website(c.whatsapp,
                  label: fc.WebsiteLabel.custom, customLabel: 'WhatsApp'),
            if (c.linkedin.isNotEmpty)
              fc.Website(c.linkedin,
                  label: fc.WebsiteLabel.custom, customLabel: 'LinkedIn'),
          ]
          ..notes = [
            if (c.tagline.isNotEmpty) fc.Note(c.tagline),
            if (result.portfolioItems.isNotEmpty)
              fc.Note(
                'Portfolio:\n'
                '${result.portfolioItems.map((e) => '• ${e.title}: ${e.url}').join('\n')}',
              ),
          ];

        // Attach photo if available
        if (c.photoBase64.isNotEmpty) {
          try {
            newContact.photo = base64Decode(c.photoBase64);
          } catch (_) {}
        }

        await fc.FlutterContacts.insertContact(newContact);
      }
    } catch (e) {
      debugPrint('Phone book save error: $e');
    }

    if (!mounted) return;
    Navigator.pop(context); // close sheet → triggers .whenComplete
    Navigator.pop(context); // close scanner page

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.portfolioItems.isEmpty
              ? 'Contact ya ${result.contact.name} imehifadhiwa!'
              : 'Contact + portfolio ya ${result.contact.name} imehifadhiwa kwenye app na phone book!',
        ),
        backgroundColor: const Color(0xFF1D9E75),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final brand = widget.brand;
    const boxSize = 260.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan i card QR'),
        actions: [
          IconButton(
            onPressed: () => _ctrl.toggleTorch(),
            icon: const Icon(Icons.flashlight_on_outlined),
            tooltip: 'Torch',
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Camera feed with error handling ──────────────────────────────
          MobileScanner(
            controller: _ctrl,
            onDetect: _onDetect,
            tapToFocus: true, // v7: tap anywhere to refocus camera
            // v7 errorBuilder: (context, error) — NO child parameter
            errorBuilder: (context, error) {
              String message;
              switch (error.errorCode) {
                case MobileScannerErrorCode.permissionDenied:
                  message =
                      'Camera permission required.\nPlease allow camera access in Settings.';
                  break;
                case MobileScannerErrorCode.unsupported:
                  message = 'Camera is not supported on this device.';
                  break;
                default:
                  message =
                      'Camera error: ${error.errorDetails?.message ?? 'Unknown error'}';
              }
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.camera_alt_outlined,
                          color: Colors.white38, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton.icon(
                        onPressed: () => _ctrl.start(),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retry'),
                        style: TextButton.styleFrom(
                          foregroundColor: brand.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Dark overlay with transparent cutout
          CustomPaint(
            painter: _ScanOverlayPainter(
              boxSize: boxSize,
              color: Colors.black.withValues(alpha: 0.62),
            ),
            child: const SizedBox.expand(),
          ),

          // Scan box: corners + animated line
          Center(
            child: SizedBox(
              width: boxSize,
              height: boxSize,
              child: Stack(
                children: [
                  // Border
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: brand.primaryColor.withValues(alpha: 0.8),
                        width: 2,
                      ),
                    ),
                  ),
                  // Corners
                  Positioned(
                      top: 0,
                      left: 0,
                      child: _Corner(color: brand.primaryColor)),
                  Positioned(
                      top: 0,
                      right: 0,
                      child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(3.14159),
                          child: _Corner(color: brand.primaryColor))),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationX(3.14159),
                          child: _Corner(color: brand.primaryColor))),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(3.14159)
                            ..rotateX(3.14159),
                          child: _Corner(color: brand.primaryColor))),

                  // Animated scan line
                  AnimatedBuilder(
                    animation: _lineAnim,
                    builder: (_, __) {
                      final topOffset = 12 + _lineAnim.value * (boxSize - 24);
                      return Positioned(
                        top: topOffset,
                        left: 12,
                        right: 12,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                brand.primaryColor.withValues(alpha: 0),
                                brand.primaryColor,
                                brand.primaryColor.withValues(alpha: 0),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(1),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    brand.primaryColor.withValues(alpha: 0.7),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom hint
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Text(
              _scanned ? 'QR imepatikana ✓' : 'Lenga QR code ya i card',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _scanned ? const Color(0xFF1D9E75) : Colors.white70,
                fontSize: 13,
                fontWeight: _scanned ? FontWeight.w600 : FontWeight.normal,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Corner accent ─────────────────────────────────────────────────────────────
class _Corner extends StatelessWidget {
  final Color color;
  const _Corner({required this.color});

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(22, 22),
        painter: _CornerPainter(color: color),
      );
}

class _CornerPainter extends CustomPainter {
  final Color color;
  const _CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(0, 0), Offset(0, size.height), paint);
    canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.color != color;
}

class _ScanOverlayPainter extends CustomPainter {
  final double boxSize;
  final Color color;
  const _ScanOverlayPainter({required this.boxSize, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final center = Offset(size.width / 2, size.height / 2);
    final left = center.dx - boxSize / 2;
    final top = center.dy - boxSize / 2;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, boxSize, boxSize),
        const Radius.circular(16),
      ))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ScanOverlayPainter old) =>
      old.boxSize != boxSize || old.color != color;
}

// ── Bottom sheet ──────────────────────────────────────────────────────────────
class _ScannedResultSheet extends StatelessWidget {
  final ScannedCardResult result;
  final BrandConfig brand;
  final VoidCallback onSave;
  final VoidCallback onDismiss;

  const _ScannedResultSheet({
    required this.result,
    required this.brand,
    required this.onSave,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final c = result.contact;
    final hasPhoto = c.photoBase64.isNotEmpty;
    final hasPortfolio = result.portfolioItems.isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollCtrl) => ListView(
        controller: scrollCtrl,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Avatar + name
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: brand.primaryColor.withValues(alpha: 0.2),
                  border: Border.all(
                    color: brand.primaryColor.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: hasPhoto
                      ? Image.memory(base64Decode(c.photoBase64),
                          fit: BoxFit.cover)
                      : Icon(Icons.person, color: brand.primaryColor, size: 30),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.name,
                        style: const TextStyle(
                            color: AppColors.textLight,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    if (c.title.isNotEmpty)
                      Text(c.title,
                          style:
                              TextStyle(color: brand.goldColor, fontSize: 12)),
                    if (c.org.isNotEmpty)
                      Text(c.org,
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Contact details
          _DetailRow(
              icon: Icons.phone_outlined,
              color: brand.primaryColor,
              value: c.phone),
          if (c.email.isNotEmpty)
            _DetailRow(
                icon: Icons.email_outlined,
                color: brand.accentColor,
                value: c.email),
          if (c.address.isNotEmpty)
            _DetailRow(
                icon: Icons.location_on_outlined,
                color: AppColors.textMuted,
                value: c.address),

          // Portfolio preview
          if (hasPortfolio) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                Icon(Icons.folder_outlined, color: brand.accentColor, size: 14),
                const SizedBox(width: 6),
                Text(
                  '${result.portfolioItems.length} portfolio '
                  'item${result.portfolioItems.length == 1 ? '' : 's'} included',
                  style: TextStyle(
                    color: brand.accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ]),
            ),
            ...result.portfolioItems.map((item) => _PortfolioRow(item: item)),
          ],

          const SizedBox(height: 24),

          // Save button
          ElevatedButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: Text(
              hasPortfolio ? 'Hifadhi Contact + Portfolio' : 'Hifadhi Contact',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D9E75),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onDismiss,
            child: const Text('Funga / Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  const _DetailRow(
      {required this.icon, required this.color, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 10),
          Flexible(
            child: Text(value,
                style:
                    const TextStyle(color: AppColors.textLight, fontSize: 13)),
          ),
        ]),
      );
}

class _PortfolioRow extends StatelessWidget {
  final PortfolioItem item;
  const _PortfolioRow({required this.item});

  static const _typeIcon = {
    PortfolioItemType.video: Icons.play_circle_outline,
    PortfolioItemType.document: Icons.description_outlined,
    PortfolioItemType.website: Icons.language_outlined,
    PortfolioItemType.image: Icons.image_outlined,
  };

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          Icon(_typeIcon[item.type]!, color: AppColors.purpleMid, size: 15),
          const SizedBox(width: 8),
          Flexible(
            child: Text(item.title,
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ),
        ]),
      );
}