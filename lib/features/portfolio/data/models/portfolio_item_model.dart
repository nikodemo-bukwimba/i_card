// lib/features/portfolio/data/models/portfolio_item_model.dart
import 'dart:convert';
import '../../domain/entities/portfolio_item.dart';

class PortfolioItemModel extends PortfolioItem {
  const PortfolioItemModel({
    required super.id,
    required super.type,
    required super.title,
    required super.url,
    super.description,
    super.platform,
  });

  factory PortfolioItemModel.fromEntity(PortfolioItem e) => PortfolioItemModel(
    id: e.id,
    type: e.type,
    title: e.title,
    url: e.url,
    description: e.description,
    platform: e.platform,
  );

  factory PortfolioItemModel.fromJson(Map<String, dynamic> j) {
    // Graceful fallback: if a stored type name doesn't match any enum value
    // (e.g. future types), default to 'website'.
    final typeName = j['type'] as String? ?? 'website';
    final type =
        PortfolioItemType.values.cast<PortfolioItemType?>().firstWhere(
          (t) => t?.name == typeName,
          orElse: () => PortfolioItemType.website,
        )!;

    return PortfolioItemModel(
      id: j['id'] as String,
      type: type,
      title: j['title'] as String,
      url: j['url'] as String,
      description: j['description'] as String? ?? '',
      platform: j['platform'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'url': url,
    'description': description,
    if (platform.isNotEmpty) 'platform': platform,
  };

  // ── Encode / decode a list to a single JSON string for SharedPreferences
  static String encodeList(List<PortfolioItem> items) => jsonEncode(
    items.map((e) => PortfolioItemModel.fromEntity(e).toJson()).toList(),
  );

  static List<PortfolioItemModel> decodeList(String raw) =>
      (jsonDecode(raw) as List)
          .map((j) => PortfolioItemModel.fromJson(j as Map<String, dynamic>))
          .toList();
}
