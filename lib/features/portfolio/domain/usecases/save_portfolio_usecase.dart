// lib/features/portfolio/domain/usecases/save_portfolio_usecase.dart
import '../entities/portfolio_item.dart';
import '../repositories/portfolio_repository.dart';

class SavePortfolioUseCase {
  final PortfolioRepository _repo;
  const SavePortfolioUseCase(this._repo);
  Future<void> call(List<PortfolioItem> items) => _repo.saveItems(items);
}