import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/config/brand_config.dart';
import '../../../contact/domain/entities/contact_entity.dart';
import '../../../contact/domain/usecases/build_vcard_usecase.dart';
import '../../../portfolio/domain/entities/portfolio_item.dart';
import '../../../portfolio/presentation/bloc/portfolio_bloc.dart';
import '../../../portfolio/presentation/bloc/portfolio_state.dart';

class QrSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Read portfolio items from the bloc
    final portfolioState = context.watch<PortfolioBloc>().state;
    final portfolioItems = portfolioState is PortfolioLoaded
        ? portfolioState.items
        : <PortfolioItem>[];

    // Try with photo first; if too large, fall back to text-only
    // Both calls include portfolio items
    final vCardWithPhoto = buildVCard(
      contact,
      portfolioItems: portfolioItems,
      includePhoto: true,
      qrSafe: true,
    );
    final vCardTextOnly = buildVCard(
      contact,
      portfolioItems: portfolioItems,
      includePhoto: false,
      qrSafe: true,
    );

    // QR version 40 max capacity: ~2953 bytes — stay safely under
    const maxQrBytes = 2800;
    final safeData =
        vCardWithPhoto.length <= maxQrBytes ? vCardWithPhoto : vCardTextOnly;

    final hasPhotoInQr =
        safeData == vCardWithPhoto && contact.photoQrBase64.isNotEmpty;
    final hasPortfolio = portfolioItems.isNotEmpty;

    // Header label reflects what's actually in the QR
    final headerLabel = [
      'SCAN',
      if (hasPhotoInQr) 'PICHA',
      if (hasPortfolio) 'PORTFOLIO',
      'CONTACT · TAP MOJA TU',
    ].join(' · ');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: brand.primaryColor.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Text(
            headerLabel,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
              letterSpacing: 2.2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: brand.primaryColor.withOpacity(0.35), width: 2.5),
            ),
            child: QrImageView(
              data: safeData, // ← guarded, never oversized
              version: QrVersions.auto,
              size: 190,
              backgroundColor: Colors.white,
              errorStateBuilder: (ctx, err) => SizedBox(
                width: 190,
                height: 190,
                child: Center(
                  child: Text(
                    'QR data too large.\nShorten tagline, reduce portfolio items, or remove photo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF1A1828),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF1A1828),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Photo badge
          if (contact.photoBase64.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: brand.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: brand.accentColor.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_outlined,
                        color: brand.accentColor, size: 12),
                    const SizedBox(width: 6),
                    Text(
                      hasPhotoInQr
                          ? 'Picha imejumuishwa kwenye QR'
                          : 'Picha inaonekana kwenye kadi tu',
                      style: TextStyle(
                        color: brand.accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Portfolio badge
          if (hasPortfolio)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: brand.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: brand.primaryColor.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder_outlined,
                        color: brand.primaryColor, size: 12),
                    const SizedBox(width: 6),
                    Text(
                      '${portfolioItems.length} portfolio item${portfolioItems.length == 1 ? '' : 's'} included',
                      style: TextStyle(
                        color: brand.primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Scanner hint
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: brand.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: brand.primaryColor.withOpacity(0.25)),
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
        ],
      ),
    );
  }
}
