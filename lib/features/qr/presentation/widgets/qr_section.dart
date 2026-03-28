import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/config/brand_config.dart';
import '../../../contact/domain/entities/contact_entity.dart';
import '../../../contact/domain/usecases/build_vcard_usecase.dart';

/// QR code that encodes a full vCard 3.0, including a QR-safe photo thumbnail.
///
/// The scanner (iOS Camera / Google Lens / any contact-aware QR reader) will
/// save the contact to the phone's address book with:
///   • All text fields (name, phone, email, URLs, address, tagline)
///   • A thumbnail photo transferred via the PHOTO;ENCODING=BASE64 field
///
/// Photo size note: the [BuildVCardUseCase] truncates the base64 photo to
/// ≤ 2 KB so the total vCard payload fits within QR version 40 capacity.
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
    // includePhoto: true  → photo embedded in vCard (QR-safe truncation applied)
    // qrSafe: true        → ensures payload fits within QR capacity limits
    final vCardData = buildVCard(
      contact,
      includePhoto: true,
      qrSafe: true,
    );

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
            contact.photoBase64.isNotEmpty
                ? 'SCAN · HIFADHI CONTACT + PICHA'
                : 'SCAN · HIFADHI CONTACT · TAP MOJA TU',
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
              data: vCardData,
              version: QrVersions.auto,
              size: 190,
              backgroundColor: Colors.white,
              errorStateBuilder: (ctx, err) => SizedBox(
                width: 190,
                height: 190,
                child: Center(
                  child: Text(
                    'QR data too large.\nShorten tagline or remove photo.',
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
          if (contact.photoBase64.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: brand.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: brand.accentColor.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_outlined,
                        color: brand.accentColor, size: 12),
                    const SizedBox(width: 6),
                    Text(
                      'Picha imejumuishwa kwenye QR',
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
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: brand.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: brand.primaryColor.withOpacity(0.25)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline,
                    color: AppColors.purpleMid, size: 13),
                SizedBox(width: 7),
                Flexible(
                  child: Text(
                    'iPhone: Camera app  •  Android: Google Lens',
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 11),
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