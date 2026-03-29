// lib/features/portfolio/data/repositories/portfolio_repository_impl.dart
import '../../domain/entities/portfolio_item.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../datasources/portfolio_local_data_source.dart';
import '../models/portfolio_item_model.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  final PortfolioLocalDataSource _local;
  const PortfolioRepositoryImpl(this._local);

  @override
  Future<List<PortfolioItem>> loadItems() => _local.loadItems();

  @override
  Future<void> saveItems(List<PortfolioItem> items) =>
      _local.saveItems(
          items.map(PortfolioItemModel.fromEntity).toList());
}