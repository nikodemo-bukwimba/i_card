// lib/features/portfolio/presentation/bloc/portfolio_event.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/portfolio_item.dart';

abstract class PortfolioEvent extends Equatable {
  const PortfolioEvent();
  @override List<Object?> get props => [];
}

class PortfolioLoadRequested extends PortfolioEvent {
  const PortfolioLoadRequested();
}

class PortfolioSaveRequested extends PortfolioEvent {
  final List<PortfolioItem> items;
  const PortfolioSaveRequested(this.items);
  @override List<Object?> get props => [items];
}