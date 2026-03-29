// lib/features/portfolio/domain/repositories/portfolio_repository.dart
import '../entities/portfolio_item.dart';

abstract class PortfolioRepository {
  Future<List<PortfolioItem>> loadItems();
  Future<void> saveItems(List<PortfolioItem> items);
}