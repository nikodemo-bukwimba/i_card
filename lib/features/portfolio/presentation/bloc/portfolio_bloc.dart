// lib/features/portfolio/presentation/bloc/portfolio_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/load_portfolio_usecase.dart';
import '../../domain/usecases/save_portfolio_usecase.dart';
import 'portfolio_event.dart';
import 'portfolio_state.dart';

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final LoadPortfolioUseCase _load;
  final SavePortfolioUseCase _save;

  PortfolioBloc({
    required LoadPortfolioUseCase load,
    required SavePortfolioUseCase save,
  })  : _load = load,
        _save = save,
        super(const PortfolioInitial()) {
    on<PortfolioLoadRequested>(_onLoad);
    on<PortfolioSaveRequested>(_onSave);
  }

  Future<void> _onLoad(
      PortfolioLoadRequested e, Emitter<PortfolioState> emit) async {
    emit(const PortfolioLoading());
    try {
      emit(PortfolioLoaded(await _load()));
    } catch (err) {
      emit(PortfolioError(err.toString()));
    }
  }

  Future<void> _onSave(
      PortfolioSaveRequested e, Emitter<PortfolioState> emit) async {
    try {
      await _save(e.items);
      emit(PortfolioLoaded(e.items));
    } catch (err) {
      emit(PortfolioError(err.toString()));
    }
  }
}