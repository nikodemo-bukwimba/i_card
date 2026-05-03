// lib/features/portfolio/presentation/widgets/portfolio_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/config/brand_config.dart';
import '../../domain/entities/portfolio_item.dart';
import '../bloc/portfolio_bloc.dart';
import '../bloc/portfolio_state.dart';

class PortfolioSection extends StatelessWidget {
  final BrandConfig brand;
  const PortfolioSection({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortfolioBloc, PortfolioState>(
      builder: (context, state) {
        if (state is! PortfolioLoaded || state.items.isEmpty) {
          return const SizedBox.shrink();
        }
        return _PortfolioGrid(items: state.items, brand: brand);
      },
    );
  }
}

class _PortfolioGrid extends StatelessWidget {
  final List<PortfolioItem> items;
  final BrandConfig brand;
  const _PortfolioGrid({required this.items, required this.brand});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: brand.primaryColor.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Text(
                  'PORTFOLIO YA KAZI',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${items.length} items',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (_, i) => _ItemCard(item: items[i], brand: brand),
          ),
        ],
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final PortfolioItem item;
  final BrandConfig brand;
  const _ItemCard({required this.item, required this.brand});

  static const _typeLabel = {
    PortfolioItemType.video: 'video',
    PortfolioItemType.document: 'document',
    PortfolioItemType.website: 'website',
    PortfolioItemType.image: 'image',
  };

  static const _typeColor = {
    PortfolioItemType.video: Color(0xFF3C3489),
    PortfolioItemType.document: Color(0xFF085041),
    PortfolioItemType.website: Color(0xFF633806),
    PortfolioItemType.image: Color(0xFF712B13),
  };

  static const _typeBg = {
    PortfolioItemType.video: Color(0xFFEEEDFE),
    PortfolioItemType.document: Color(0xFFE1F5EE),
    PortfolioItemType.website: Color(0xFFFAEEDA),
    PortfolioItemType.image: Color(0xFFFAECE7),
  };

  static const _typeIcon = {
    PortfolioItemType.video: Icons.play_circle_outline,
    PortfolioItemType.document: Icons.description_outlined,
    PortfolioItemType.website: Icons.language_outlined,
    PortfolioItemType.image: Icons.image_outlined,
  };

  Future<void> _open() async {
    final uri = Uri.tryParse(item.url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _typeIcon[item.type] ?? Icons.link_outlined;
    final bg = _typeBg[item.type] ?? const Color(0xFF1A1828);
    final color = _typeColor[item.type] ?? AppColors.purpleMid;
    final label = _typeLabel[item.type] ?? 'link';

    return GestureDetector(
      onTap: _open,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.purpleMid.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: bg.withOpacity(0.15),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(11),
                  ),
                ),
                child: Icon(icon, color: color.withOpacity(0.7), size: 28),
                alignment: Alignment.center,
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: bg.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
