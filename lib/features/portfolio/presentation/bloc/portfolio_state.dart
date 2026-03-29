// lib/features/portfolio/presentation/bloc/portfolio_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/portfolio_item.dart';

abstract class PortfolioState extends Equatable {
  const PortfolioState();
  @override List<Object?> get props => [];
}

class PortfolioInitial  extends PortfolioState { const PortfolioInitial(); }
class PortfolioLoading  extends PortfolioState { const PortfolioLoading(); }

class PortfolioLoaded extends PortfolioState {
  final List<PortfolioItem> items;
  const PortfolioLoaded(this.items);
  @override List<Object?> get props => [items];
}

class PortfolioError extends PortfolioState {
  final String message;
  const PortfolioError(this.message);
  @override List<Object?> get props => [message];
}