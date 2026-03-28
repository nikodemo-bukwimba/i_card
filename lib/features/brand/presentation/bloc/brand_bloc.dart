import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/brand_config.dart';
import '../../../../core/services/storage_service.dart';
import 'brand_event.dart';
import 'brand_state.dart';

class BrandBloc extends Bloc<BrandEvent, BrandState> {
  final StorageService _storage;

  BrandBloc({required StorageService storage})
      : _storage = storage,
        super(const BrandInitial()) {
    on<BrandLoadRequested>(_onLoad);
    on<BrandSaveRequested>(_onSave);
  }

  Future<void> _onLoad(
    BrandLoadRequested event,
    Emitter<BrandState> emit,
  ) async {
    emit(const BrandLoading());
    try {
      final brand = BrandConfig.fromStorage(_storage);
      emit(BrandLoaded(brand));
    } catch (e) {
      emit(BrandError(e.toString()));
    }
  }

  Future<void> _onSave(
    BrandSaveRequested event,
    Emitter<BrandState> emit,
  ) async {
    try {
      await event.brand.save(_storage);
      emit(BrandSaved(event.brand));
    } catch (e) {
      emit(BrandError(e.toString()));
    }
  }
}