import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/config/brand_config.dart';
import '../../../contact/domain/entities/contact_entity.dart';

class CardWidget extends StatelessWidget {
  final ContactEntity contact;
  final BrandConfig brand;

  const CardWidget({
    super.key,
    required this.contact,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = contact.photoBase64.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: brand.primaryColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient accent bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                brand.primaryColor,
                brand.primaryColor.withOpacity(0.6),
                brand.accentColor,
              ]),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: brand.accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: brand.accentColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          brand.badgeText,
                          style: TextStyle(
                            color: brand.accentColor,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        contact.name,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        contact.title,
                        style: TextStyle(
                          color: brand.goldColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        contact.org,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          letterSpacing: 0.4,
                        ),
                      ),
                      if (contact.address.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.location_on_outlined,
                              color: AppColors.textMuted, size: 11),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              contact.address,
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Avatar
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: brand.primaryColor.withOpacity(0.5),
                        width: 2),
                    color: brand.primaryColor.withOpacity(0.2),
                  ),
                  child: ClipOval(
                    child: hasPhoto
                        ? Image.memory(
                            base64Decode(contact.photoBase64),
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.person,
                            color: brand.primaryColor, size: 36),
                  ),
                ),
              ],
            ),
          ),
          // Tagline footer
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              color: brand.primaryColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20)),
              border: Border(
                  top: BorderSide(
                      color: brand.primaryColor.withOpacity(0.1))),
            ),
            child: Text(
              '"${contact.tagline}"',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}