// lib/features/portfolio/domain/entities/portfolio_item.dart
import 'package:equatable/equatable.dart';

/// Content types for portfolio items.
/// Each type gets distinct iconography, colors, and URL handling.
enum PortfolioItemType {
  video, // YouTube, Vimeo, Loom, etc.
  document, // PDFs, Google Docs, certificates
  website, // Projects, company sites, landing pages
  image, // Design work, photography, Dribbble
  social, // GitHub, Instagram, Twitter/X, Behance, etc.
}

class PortfolioItem extends Equatable {
  final String id;
  final PortfolioItemType type;
  final String title;
  final String url;
  final String description;

  /// Optional: short label for the platform (e.g. "GitHub", "Dribbble").
  /// Auto-detected from URL if left empty.
  final String platform;

  const PortfolioItem({
    required this.id,
    required this.type,
    required this.title,
    required this.url,
    this.description = '',
    this.platform = '',
  });

  PortfolioItem copyWith({
    String? id,
    PortfolioItemType? type,
    String? title,
    String? url,
    String? description,
    String? platform,
  }) => PortfolioItem(
    id: id ?? this.id,
    type: type ?? this.type,
    title: title ?? this.title,
    url: url ?? this.url,
    description: description ?? this.description,
    platform: platform ?? this.platform,
  );

  /// Try to detect the platform name from the URL for display purposes.
  String get displayPlatform {
    if (platform.isNotEmpty) return platform;
    final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
    if (host.contains('github')) return 'GitHub';
    if (host.contains('gitlab')) return 'GitLab';
    if (host.contains('dribbble')) return 'Dribbble';
    if (host.contains('behance')) return 'Behance';
    if (host.contains('figma')) return 'Figma';
    if (host.contains('instagram')) return 'Instagram';
    if (host.contains('twitter') || host.contains('x.com'))
      return 'X / Twitter';
    if (host.contains('linkedin')) return 'LinkedIn';
    if (host.contains('youtube')) return 'YouTube';
    if (host.contains('vimeo')) return 'Vimeo';
    if (host.contains('loom')) return 'Loom';
    if (host.contains('medium')) return 'Medium';
    if (host.contains('notion')) return 'Notion';
    if (host.contains('docs.google')) return 'Google Docs';
    if (host.contains('drive.google')) return 'Google Drive';
    return '';
  }

  @override
  List<Object?> get props => [id, type, title, url, description, platform];
}
