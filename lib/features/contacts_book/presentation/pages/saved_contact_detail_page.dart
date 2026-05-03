// lib/features/contacts_book/presentation/pages/saved_contact_detail_page.dart
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
        title: Text(
          c.name,
          style: const TextStyle(color: AppColors.textLight, fontSize: 16),
        ),
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
                color: brand.primaryColor.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: brand.primaryColor.withValues(alpha: 0.2),
                    border: Border.all(
                      color: brand.primaryColor.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child:
                        hasPhoto
                            ? Image.memory(
                              base64Decode(c.photoBase64),
                              fit: BoxFit.cover,
                            )
                            : Icon(
                              Icons.person,
                              color: brand.primaryColor,
                              size: 38,
                            ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  c.name,
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (c.title.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    c.title,
                    style: TextStyle(color: brand.goldColor, fontSize: 13),
                  ),
                ],
                if (c.org.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    c.org,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Scanned ${DateTimeUtils.timeAgo(saved.scannedAt)}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
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

          // ── Portfolio showcase ─────────────────────────────────────────
          if (saved.portfolioItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            _PortfolioShowcase(
              items: saved.portfolioItems,
              brand: brand,
              onOpen: _launch,
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
                  color: brand.primaryColor.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    color: brand.primaryColor.withValues(alpha: 0.4),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      c.tagline,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Portfolio showcase ──────────────────────────────────────────────────────
class _PortfolioShowcase extends StatelessWidget {
  final List<PortfolioItem> items;
  final BrandConfig brand;
  final ValueChanged<String> onOpen;

  const _PortfolioShowcase({
    required this.items,
    required this.brand,
    required this.onOpen,
  });

  // Visual config per type
  static const _cfg = <PortfolioItemType, _PTypeConfig>{
    PortfolioItemType.video: _PTypeConfig(
      Icons.play_circle_rounded,
      Color(0xFF2D1F5E),
      Color(0xFFB4A0FF),
      'VIDEO',
    ),
    PortfolioItemType.document: _PTypeConfig(
      Icons.description_rounded,
      Color(0xFF0D3D2E),
      Color(0xFF6EDBB5),
      'DOC',
    ),
    PortfolioItemType.website: _PTypeConfig(
      Icons.language_rounded,
      Color(0xFF3D2A0B),
      Color(0xFFE8C064),
      'WEB',
    ),
    PortfolioItemType.image: _PTypeConfig(
      Icons.image_rounded,
      Color(0xFF3D1510),
      Color(0xFFE88B74),
      'IMG',
    ),
    PortfolioItemType.social: _PTypeConfig(
      Icons.people_rounded,
      Color(0xFF0D2A3D),
      Color(0xFF6DB8E8),
      'SOCIAL',
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with count
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
          child: Row(
            children: [
              const Text(
                'PORTFOLIO',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 9,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: brand.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${items.length}',
                  style: TextStyle(
                    color: brand.accentColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Portfolio cards
        ...items.map((item) {
          final cfg =
              _cfg[item.type] ??
              const _PTypeConfig(
                Icons.link_rounded,
                Color(0xFF2D2D2D),
                Color(0xFFAAAAAA),
                'LINK',
              );
          final platformLabel = item.displayPlatform;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: AppColors.darkSurface2,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => onOpen(item.url),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cfg.fg.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      // Type icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: cfg.bg,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(cfg.icon, color: cfg.fg, size: 22),
                      ),
                      const SizedBox(width: 13),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                // Type badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cfg.fg.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    cfg.label,
                                    style: TextStyle(
                                      color: cfg.fg,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                                if (platformLabel.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    platformLabel,
                                    style: TextStyle(
                                      color: AppColors.textMuted.withOpacity(
                                        0.7,
                                      ),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (item.description.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                item.description,
                                style: TextStyle(
                                  color: AppColors.textMuted.withOpacity(0.6),
                                  fontSize: 11,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Open arrow
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: cfg.fg.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.open_in_new_rounded,
                          color: cfg.fg.withOpacity(0.6),
                          size: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _PTypeConfig {
  final IconData icon;
  final Color bg;
  final Color fg;
  final String label;
  const _PTypeConfig(this.icon, this.bg, this.fg, this.label);
}

// ── Shared widgets ──────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
    child: Text(
      label,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 9,
        letterSpacing: 2,
        fontWeight: FontWeight.w500,
      ),
    ),
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
              color: AppColors.purpleMid.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
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
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                  size: 17,
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
