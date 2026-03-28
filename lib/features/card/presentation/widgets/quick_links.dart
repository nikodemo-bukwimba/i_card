import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/config/brand_config.dart';
import '../../../../core/utils/url_helper.dart';
import '../../../contact/domain/entities/contact_entity.dart';

class QuickLinks extends StatelessWidget {
  final ContactEntity contact;
  final BrandConfig brand;

  const QuickLinks({
    super.key,
    required this.contact,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    final links = _buildLinks();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'MAWASILIANO YA HARAKA',
            style: TextStyle(
                color: AppColors.textMuted, fontSize: 9, letterSpacing: 2),
          ),
        ),
        ...links.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _LinkTile(
              icon: e.icon,
              iconColor: e.color,
              label: e.label,
              value: e.value,
              onTap: () => UrlHelper.launch(e.url),
            ),
          ),
        ),
      ],
    );
  }

  List<_LinkItem> _buildLinks() {
    return [
      _LinkItem(Icons.phone_outlined, brand.primaryColor,
          'Simu / Phone', contact.phone, 'tel:${contact.phone}'),
      if (contact.phone2.isNotEmpty)
        _LinkItem(Icons.phone_outlined, brand.primaryColor,
            'Simu 2 / Phone 2', contact.phone2, 'tel:${contact.phone2}'),
      _LinkItem(Icons.email_outlined, brand.accentColor,
          'Barua Pepe / Email', contact.email, 'mailto:${contact.email}'),
      if (contact.whatsapp.isNotEmpty)
        _LinkItem(Icons.chat_outlined, AppColors.whatsApp,
            'WhatsApp Channel', 'WhatsApp', contact.whatsapp),
      if (contact.website.isNotEmpty)
        _LinkItem(Icons.language_outlined, brand.goldColor,
            'Website', contact.website, contact.website),
      if (contact.linkedin.isNotEmpty)
        _LinkItem(Icons.work_outline, AppColors.linkedIn,
            'LinkedIn', 'LinkedIn', contact.linkedin),
    ].where((e) => e.url.isNotEmpty).toList();
  }
}

class _LinkItem {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String url;
  const _LinkItem(this.icon, this.color, this.label, this.value, this.url);
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _LinkTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.darkSurface2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.purpleMid.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: iconColor, size: 19),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            letterSpacing: 0.4)),
                    const SizedBox(height: 2),
                    Text(value,
                        style: const TextStyle(
                            color: AppColors.textLight, fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.textMuted, size: 17),
            ],
          ),
        ),
      ),
    );
  }
}