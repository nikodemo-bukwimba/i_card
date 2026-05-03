import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/config/brand_config.dart';
import '../../../contact/domain/entities/contact_entity.dart';
import '../../../contact/domain/usecases/build_vcard_usecase.dart';
import '../../../portfolio/domain/entities/portfolio_item.dart';
import '../../../portfolio/presentation/bloc/portfolio_bloc.dart';
import '../../../portfolio/presentation/bloc/portfolio_state.dart';

class NfcSharePage extends StatefulWidget {
  final ContactEntity contact;
  final BrandConfig brand;

  const NfcSharePage({super.key, required this.contact, required this.brand});

  @override
  State<NfcSharePage> createState() => _NfcSharePageState();
}

class _NfcSharePageState extends State<NfcSharePage>
    with SingleTickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────
  _NfcStatus _status = _NfcStatus.waiting;
  String _statusMessage = 'Sogeza simu mbili pamoja\nkusambaza kadi yako';
  bool _nfcAvailable = false;

  // ── Pulse animation for the NFC ring ───────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
    _startNfc();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    NfcManager.instance.stopSession().catchError((_) {});
    super.dispose();
  }

  // ── Build the vCard with full portfolio and photo ──────────────────────
  String _buildFullVCard(List<PortfolioItem> portfolioItems) {
    return const BuildVCardUseCase().callFull(
      widget.contact,
      portfolioItems: portfolioItems,
    );
  }

  // ── Start NFC session ─────────────────────────────────────────────────
  Future<void> _startNfc() async {
    final available = await NfcManager.instance.isAvailable();
    if (!mounted) return;

    if (!available) {
      setState(() {
        _nfcAvailable = false;
        _status = _NfcStatus.error;
        _statusMessage =
            'NFC haipatikani kwenye simu hii\nau imezimwa kwenye mipangilio';
      });
      return;
    }

    setState(() => _nfcAvailable = true);

    // Get portfolio items from bloc
    final portfolioState = context.read<PortfolioBloc>().state;
    final portfolioItems =
        portfolioState is PortfolioLoaded
            ? portfolioState.items
            : <PortfolioItem>[];

    final vCardData = _buildFullVCard(portfolioItems);
    final vCardBytes = utf8.encode(vCardData);

    await NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          final ndef = Ndef.from(tag);
          if (ndef == null) {
            _setStatus(_NfcStatus.error, 'Tagi hii haifanyi kazi na NDEF');
            return;
          }

          if (!ndef.isWritable) {
            _setStatus(_NfcStatus.error, 'Tagi hii haiwezi kuandikwa');
            return;
          }

          // Build NDEF vCard record
          final record = NdefRecord(
            typeNameFormat: NdefTypeNameFormat.media,
            type: Uint8List.fromList(utf8.encode('text/vcard')),
            identifier: Uint8List(0),
            payload: Uint8List.fromList(vCardBytes),
          );

          final message = NdefMessage([record]);

          await ndef.write(message);

          HapticFeedback.heavyImpact();
          _setStatus(_NfcStatus.success, 'Imefanikiwa!\nKadi yako imesambazwa');

          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) Navigator.pop(context);
        } catch (e) {
          _setStatus(_NfcStatus.error, 'Hitilafu imetokea. Jaribu tena.');
        }
      },
      onError: (e) async {
        _setStatus(_NfcStatus.error, 'NFC ilikatika. Jaribu tena.');
      },
    );
  }

  void _setStatus(_NfcStatus status, String message) {
    if (!mounted) return;
    setState(() {
      _status = status;
      _statusMessage = message;
    });
    if (status != _NfcStatus.waiting) {
      _pulseCtrl.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = widget.brand;

    return Scaffold(
      backgroundColor: AppColors.darkSurface,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.textLight,
        title: const Text(
          'Sambaza kwa NFC',
          style: TextStyle(color: AppColors.textLight, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Animated NFC ring ────────────────────────────────
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, __) {
                      final isWaiting = _status == _NfcStatus.waiting;
                      final scale =
                          isWaiting ? 1.0 + (_pulseAnim.value * 0.08) : 1.0;
                      final ringColor = switch (_status) {
                        _NfcStatus.waiting => brand.primaryColor,
                        _NfcStatus.success => const Color(0xFF1D9E75),
                        _NfcStatus.error => Colors.redAccent,
                      };

                      return Transform.scale(
                        scale: scale,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer pulse ring
                            if (isWaiting)
                              Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: brand.primaryColor.withValues(
                                      alpha: 0.2 + _pulseAnim.value * 0.15,
                                    ),
                                    width: 2,
                                  ),
                                ),
                              ),
                            // Middle ring
                            Container(
                              width: 148,
                              height: 148,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: ringColor.withValues(alpha: 0.35),
                                  width: 2,
                                ),
                                color: ringColor.withValues(alpha: 0.06),
                              ),
                            ),
                            // Inner filled circle
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ringColor.withValues(alpha: 0.12),
                                border: Border.all(
                                  color: ringColor.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                switch (_status) {
                                  _NfcStatus.waiting => Icons.nfc_rounded,
                                  _NfcStatus.success => Icons.check_rounded,
                                  _NfcStatus.error => Icons.error_outline,
                                },
                                color: ringColor,
                                size: 44,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 36),

                  // ── Status message ───────────────────────────────────
                  Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 16,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── What will transfer ───────────────────────────────
                  if (_status == _NfcStatus.waiting && _nfcAvailable) ...[
                    const SizedBox(height: 8),
                    _TransferBadge(contact: widget.contact, brand: brand),
                  ],

                  // ── NFC not available hint ───────────────────────────
                  if (_status == _NfcStatus.error && !_nfcAvailable) ...[
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () async {
                        // Open NFC settings
                        await SystemChannels.platform.invokeMethod(
                          'SystemNavigator.routeUpdated',
                        );
                      },
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: AppColors.textMuted,
                        size: 16,
                      ),
                      label: const Text(
                        'Fungua mipangilio ya NFC',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Bottom instructions ────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.purpleMid.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  children: [
                    _InstructionRow(
                      number: '1',
                      text: 'Washa NFC kwenye simu zote mbili',
                      brand: brand,
                    ),
                    const SizedBox(height: 10),
                    _InstructionRow(
                      number: '2',
                      text: 'Sogeza nyuma za simu pamoja (cm 4)',
                      brand: brand,
                    ),
                    const SizedBox(height: 10),
                    _InstructionRow(
                      number: '3',
                      text: 'Simu itatetemeka — kadi itapokelewa mara moja',
                      brand: brand,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── What will transfer badge ────────────────────────────────────────────────
class _TransferBadge extends StatelessWidget {
  final ContactEntity contact;
  final BrandConfig brand;

  const _TransferBadge({required this.contact, required this.brand});

  @override
  Widget build(BuildContext context) {
    final portfolioState = context.watch<PortfolioBloc>().state;
    final portfolioCount =
        portfolioState is PortfolioLoaded ? portfolioState.items.length : 0;
    final hasPhoto = contact.photoBase64.isNotEmpty;

    final items = [
      'Contact kamili',
      if (hasPhoto) 'Picha',
      if (portfolioCount > 0) 'Portfolio ($portfolioCount)',
      'WhatsApp · LinkedIn',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: brand.accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: brand.accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            'Itasambaza:',
            style: TextStyle(
              color: brand.accentColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children:
                items
                    .map(
                      (item) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: brand.accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item,
                          style: TextStyle(
                            color: brand.accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Instruction row ─────────────────────────────────────────────────────────
class _InstructionRow extends StatelessWidget {
  final String number;
  final String text;
  final BrandConfig brand;

  const _InstructionRow({
    required this.number,
    required this.text,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: brand.primaryColor.withValues(alpha: 0.15),
          border: Border.all(color: brand.primaryColor.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              color: brand.primaryColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ),
    ],
  );
}

enum _NfcStatus { waiting, success, error }
