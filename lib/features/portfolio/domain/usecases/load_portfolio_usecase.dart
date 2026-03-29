// lib/features/portfolio/domain/usecases/load_portfolio_usecase.dart
import '../entities/portfolio_item.dart';
import '../repositories/portfolio_repository.dart';

class LoadPortfolioUseCase {
  final PortfolioRepository _repo;
  const LoadPortfolioUseCase(this._repo);
  Future<List<PortfolioItem>> call() => _repo.loadItems();
}