import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/config/brand_config.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../domain/entities/saved_contact.dart';
import '../../../portfolio/domain/entities/portfolio_item.dart';

class SavedContactDetailPage extends StatelessWidget {
  final SavedContact saved;
  final BrandConfig brand;

  const SavedContactDetailPage({
    super.key,
    required this.saved,
    required this.brand,
  });

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = saved.contact;
    final hasPhoto = c.photoBase64.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.darkSurface,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.textLight,
        title: Text(c.name,
            style: const TextStyle(
                color: AppColors.textLight, fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // ── Profile header ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkSurface2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: brand.primaryColor.withValues(alpha: 0.25)),
            ),
            child: Column(
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: brand.primaryColor.withValues(alpha: 0.2),
                    border: Border.all(
                        color: brand.primaryColor.withValues(alpha: 0.5),
                        width: 2),
                  ),
                  child: ClipOval(
                    child: hasPhoto
                        ? Image.memory(base64Decode(c.photoBase64),
                            fit: BoxFit.cover)
                        : Icon(Icons.person,
                            color: brand.primaryColor, size: 38),
                  ),
                ),
                const SizedBox(height: 12),
                Text(c.name,
                    style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                if (c.title.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(c.title,
                      style: TextStyle(
                          color: brand.goldColor, fontSize: 13)),
                ],
                if (c.org.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(c.org,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12)),
                ],
                const SizedBox(height: 8),
                Text(
                  'Scanned ${DateTimeUtils.timeAgo(saved.scannedAt)}',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 10,
                      letterSpacing: 0.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Contact details ────────────────────────────────────────────
          _SectionLabel('MAWASILIANO'),
          if (c.phone.isNotEmpty)
            _ActionTile(
              icon: Icons.phone_outlined,
              color: brand.primaryColor,
              label: 'Simu / Phone',
              value: c.phone,
              onTap: () => _launch('tel:${c.phone}'),
            ),
          if (c.phone2.isNotEmpty)
            _ActionTile(
              icon: Icons.phone_outlined,
              color: brand.primaryColor,
              label: 'Simu 2',
              value: c.phone2,
              onTap: () => _launch('tel:${c.phone2}'),
            ),
          if (c.email.isNotEmpty)
            _ActionTile(
              icon: Icons.email_outlined,
              color: brand.accentColor,
              label: 'Barua Pepe',
              value: c.email,
              onTap: () => _launch('mailto:${c.email}'),
            ),
          if (c.whatsapp.isNotEmpty)
            _ActionTile(
              icon: Icons.chat_outlined,
              color: const Color(0xFF25D366),
              label: 'WhatsApp',
              value: 'Channel link',
              onTap: () => _launch(c.whatsapp),
            ),
          if (c.website.isNotEmpty)
            _ActionTile(
              icon: Icons.language_outlined,
              color: brand.goldColor,
              label: 'Website',
              value: c.website,
              onTap: () => _launch(c.website),
            ),
          if (c.linkedin.isNotEmpty)
            _ActionTile(
              icon: Icons.work_outline,
              color: const Color(0xFF0A66C2),
              label: 'LinkedIn',
              value: 'Profile',
              onTap: () => _launch(c.linkedin),
            ),
          if (c.address.isNotEmpty)
            _ActionTile(
              icon: Icons.location_on_outlined,
              color: AppColors.textMuted,
              label: 'Anwani',
              value: c.address,
              onTap: null,
            ),

          // ── Portfolio ──────────────────────────────────────────────────
          if (saved.portfolioItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            _SectionLabel('PORTFOLIO'),
            ...saved.portfolioItems.map(
              (item) => _PortfolioTile(item: item, brand: brand),
            ),
          ],

          // ── Tagline ────────────────────────────────────────────────────
          if (c.tagline.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: brand.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: brand.primaryColor.withValues(alpha: 0.15)),
              ),
              child: Text('"${c.tagline}"',
                  style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontStyle: FontStyle.italic)),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
        child: Text(label,
            style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 9,
                letterSpacing: 2,
                fontWeight: FontWeight.w500)),
      );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
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
                    color: AppColors.purpleMid.withValues(alpha: 0.15)),
              ),
              child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
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
                if (onTap != null)
                  const Icon(Icons.chevron_right,
                      color: AppColors.textMuted, size: 17),
              ]),
            ),
          ),
        ),
      );
}

class _PortfolioTile extends StatelessWidget {
  final PortfolioItem item;
  final BrandConfig brand;
  const _PortfolioTile({required this.item, required this.brand});

  static const _typeIcon = {
    PortfolioItemType.video:    Icons.play_circle_outline,
    PortfolioItemType.document: Icons.description_outlined,
    PortfolioItemType.website:  Icons.language_outlined,
    PortfolioItemType.image:    Icons.image_outlined,
  };

  static const _typeBg = {
    PortfolioItemType.video:    Color(0xFFEEEDFE),
    PortfolioItemType.document: Color(0xFFE1F5EE),
    PortfolioItemType.website:  Color(0xFFFAEEDA),
    PortfolioItemType.image:    Color(0xFFFAECE7),
  };

  static const _typeColor = {
    PortfolioItemType.video:    Color(0xFF3C3489),
    PortfolioItemType.document: Color(0xFF085041),
    PortfolioItemType.website:  Color(0xFF633806),
    PortfolioItemType.image:    Color(0xFF712B13),
  };

  Future<void> _open() async {
    final uri = Uri.tryParse(item.url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: AppColors.darkSurface2,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: _open,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.purpleMid.withValues(alpha: 0.15)),
              ),
              child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: _typeBg[item.type]!.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_typeIcon[item.type]!,
                      color: _typeColor[item.type]!, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(item.title,
                      style: const TextStyle(
                          color: AppColors.textLight, fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                ),
                const Icon(Icons.open_in_new,
                    color: AppColors.textMuted, size: 15),
              ]),
            ),
          ),
        ),
      );
}