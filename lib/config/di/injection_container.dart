import 'package:get_it/get_it.dart';

import '../../core/services/storage_service.dart';
import '../../core/services/network_service.dart';
import '../../features/contact/data/datasources/contact_local_data_source.dart';
import '../../features/contact/data/repositories/contact_repository_impl.dart';
import '../../features/contact/domain/repositories/contact_repository.dart';
import '../../features/contact/domain/usecases/build_vcard_usecase.dart';
import '../../features/contact/domain/usecases/load_contact_usecase.dart';
import '../../features/contact/domain/usecases/save_contact_usecase.dart';
import '../../features/contact/presentation/bloc/contact_bloc.dart';
import '../../features/brand/presentation/bloc/brand_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── Services ──────────────────────────────────────────────────────────────
  final storage = StorageService();
  await storage.init();
  sl.registerSingleton<StorageService>(storage);
  sl.registerLazySingleton<NetworkService>(() => NetworkService());

  // ── Data sources ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<ContactLocalDataSource>(
    () => ContactLocalDataSourceImpl(sl<StorageService>()),
  );

  // ── Repositories ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<ContactRepository>(
    () => ContactRepositoryImpl(sl<ContactLocalDataSource>()),
  );

  // ── Use cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => LoadContactUseCase(sl<ContactRepository>()));
  sl.registerLazySingleton(() => SaveContactUseCase(sl<ContactRepository>()));
  sl.registerLazySingleton(() => const BuildVCardUseCase());

  // ── BLoCs — factory = fresh instance per screen ───────────────────────────
  sl.registerFactory(() => ContactBloc(
        loadContact: sl<LoadContactUseCase>(),
        saveContact: sl<SaveContactUseCase>(),
      ));

  sl.registerFactory(
      () => BrandBloc(storage: sl<StorageService>()));
}