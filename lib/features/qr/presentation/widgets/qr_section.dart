import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/config/brand_config.dart';
import '../../../contact/domain/entities/contact_entity.dart';
import '../../../contact/domain/usecases/build_vcard_usecase.dart';
import '../../../nfc/presentation/pages/nfc_share_page.dart';
import '../../../portfolio/domain/entities/portfolio_item.dart';
import '../../../portfolio/presentation/bloc/portfolio_bloc.dart';
import '../../../portfolio/presentation/bloc/portfolio_state.dart';

class QrSection extends StatefulWidget {
  final ContactEntity contact;
  final BrandConfig brand;
  final BuildVCardUseCase buildVCard;

  const QrSection({
    super.key,
    required this.contact,
    required this.brand,
    this.buildVCard = const BuildVCardUseCase(),
  });

  @override
  State<QrSection> createState() => _QrSectionState();
}

class _QrSectionState extends State<QrSection> {
  // null = still checking, true = on, false = off or unavailable
  bool? _nfcAvailable;

  @override
  void initState() {
    super.initState();
    _checkNfc();
  }

  Future<void> _checkNfc() async {
    try {
      final available = await NfcManager.instance.isAvailable();
      if (mounted) setState(() => _nfcAvailable = available);
    } catch (_) {
      if (mounted) setState(() => _nfcAvailable = false);
    }
  }

  void _openNfc() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => BlocProvider.value(
              value: context.read<PortfolioBloc>(),
              child: NfcSharePage(contact: widget.contact, brand: widget.brand),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brand = widget.brand;
    final portfolioState = context.watch<PortfolioBloc>().state;
    final portfolioItems =
        portfolioState is PortfolioLoaded
            ? portfolioState.items
            : <PortfolioItem>[];
    final hasPortfolio = portfolioItems.isNotEmpty;

    final externalVCard = widget.buildVCard.callMinimal(widget.contact);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: brand.primaryColor.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          const Text(
            'SCAN · HIFADHI CONTACT · TAP MOJA TU',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
              letterSpacing: 2.2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),

          // ── QR Code ─────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: brand.primaryColor.withValues(alpha: 0.35),
                width: 2.5,
              ),
            ),
            child: QrImageView(
              data: externalVCard,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF1A1828),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF1A1828),
              ),
              errorStateBuilder:
                  (_, __) => const SizedBox(
                    width: 200,
                    height: 200,
                    child: Center(
                      child: Text(
                        'Contact info too long.\nShorten your name or address.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.redAccent, fontSize: 11),
                      ),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Scanner hint ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: brand.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: brand.primaryColor.withValues(alpha: 0.25),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, color: AppColors.purpleMid, size: 13),
                SizedBox(width: 7),
                Flexible(
                  child: Text(
                    'iPhone: Camera app  •  Android: Google Lens',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // ── Portfolio notice ──────────────────────────────────────────────
          if (hasPortfolio) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: brand.accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: brand.accentColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.folder_outlined,
                    color: brand.accentColor,
                    size: 13,
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      '${portfolioItems.length} portfolio items · '
                      'Use NFC or i card scanner for full transfer',
                      style: TextStyle(
                        color: brand.accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── NFC section ───────────────────────────────────────────────────
          // Always show the divider + NFC row once the check completes.
          // If NFC is OFF we show a dimmed button with a hint to enable it.
          // If still checking (_nfcAvailable == null) we show nothing yet.
          if (_nfcAvailable != null) ...[
            const SizedBox(height: 14),
            _OrDivider(),
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                // Button is always tappable; NfcSharePage handles the
                // "NFC is off" state gracefully with a message inside.
                onPressed: _openNfc,
                icon: Icon(
                  Icons.nfc_rounded,
                  size: 18,
                  color:
                      _nfcAvailable == true
                          ? brand.primaryColor
                          : AppColors.textMuted,
                ),
                label: Text(
                  _nfcAvailable == true
                      ? 'Sambaza kwa NFC · Full transfer'
                      : 'NFC · Washa NFC kwenye mipangilio',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        _nfcAvailable == true
                            ? brand.primaryColor
                            : AppColors.textMuted,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color:
                        _nfcAvailable == true
                            ? brand.primaryColor.withValues(alpha: 0.5)
                            : AppColors.textMuted.withValues(alpha: 0.25),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),
            Text(
              _nfcAvailable == true
                  ? 'Picha + portfolio + contact yote kwa tap moja'
                  : 'NFC iko kwenye simu hii lakini imezimwa',
              style: TextStyle(
                color:
                    _nfcAvailable == true
                        ? AppColors.textMuted.withValues(alpha: 0.7)
                        : AppColors.textMuted.withValues(alpha: 0.45),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Or divider ───────────────────────────────────────────────────────────────
class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Container(
          height: 0.5,
          color: AppColors.purpleMid.withValues(alpha: 0.2),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          'au',
          style: TextStyle(
            color: AppColors.textMuted.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
      ),
      Expanded(
        child: Container(
          height: 0.5,
          color: AppColors.purpleMid.withValues(alpha: 0.2),
        ),
      ),
    ],
  );
}
