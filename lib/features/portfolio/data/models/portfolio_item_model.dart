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
  });

  factory PortfolioItemModel.fromEntity(PortfolioItem e) =>
      PortfolioItemModel(
        id: e.id, type: e.type,
        title: e.title, url: e.url, description: e.description,
      );

  factory PortfolioItemModel.fromJson(Map<String, dynamic> j) =>
      PortfolioItemModel(
        id:          j['id']   as String,
        type:        PortfolioItemType.values
                       .byName(j['type'] as String),
        title:       j['title'] as String,
        url:         j['url']   as String,
        description: j['description'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
    'id':          id,
    'type':        type.name,
    'title':       title,
    'url':         url,
    'description': description,
  };

  // ── Encode / decode a list to a single JSON string for SharedPreferences
  static String encodeList(List<PortfolioItem> items) =>
      jsonEncode(items
          .map((e) => PortfolioItemModel.fromEntity(e).toJson())
          .toList());

  static List<PortfolioItemModel> decodeList(String raw) =>
      (jsonDecode(raw) as List)
          .map((j) => PortfolioItemModel.fromJson(j as Map<String, dynamic>))
          .toList();
}