// lib/features/portfolio/data/datasources/portfolio_local_data_source.dart
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/storage_service.dart';
import '../models/portfolio_item_model.dart';

abstract class PortfolioLocalDataSource {
  Future<List<PortfolioItemModel>> loadItems();
  Future<void> saveItems(List<PortfolioItemModel> items);
}

class PortfolioLocalDataSourceImpl implements PortfolioLocalDataSource {
  final StorageService _storage;
  static const _key = 'portfolio_items';

  const PortfolioLocalDataSourceImpl(this._storage);

  @override
  Future<List<PortfolioItemModel>> loadItems() async {
    try {
      final raw = _storage.getString(_key);
      if (raw == null || raw.isEmpty) return [];
      return PortfolioItemModel.decodeList(raw);
    } catch (e, st) {
      throw StorageException('loadPortfolio failed: $e', st);
    }
  }

  @override
  Future<void> saveItems(List<PortfolioItemModel> items) async {
    try {
      await _storage.setString(
          _key, PortfolioItemModel.encodeList(items));
    } catch (e, st) {
      throw StorageException('savePortfolio failed: $e', st);
    }
  }
}