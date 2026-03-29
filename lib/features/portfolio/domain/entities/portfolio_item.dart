// lib/features/portfolio/domain/entities/portfolio_item.dart
import 'package:equatable/equatable.dart';

enum PortfolioItemType { video, document, website, image }

class PortfolioItem extends Equatable {
  final String id;           // uuid
  final PortfolioItemType type;
  final String title;
  final String url;
  final String description;

  const PortfolioItem({
    required this.id,
    required this.type,
    required this.title,
    required this.url,
    this.description = '',
  });

  PortfolioItem copyWith({
    String? id,
    PortfolioItemType? type,
    String? title,
    String? url,
    String? description,
  }) => PortfolioItem(
    id:          id          ?? this.id,
    type:        type        ?? this.type,
    title:       title       ?? this.title,
    url:         url         ?? this.url,
    description: description ?? this.description,
  );

  @override
  List<Object?> get props => [id, type, title, url, description];
}