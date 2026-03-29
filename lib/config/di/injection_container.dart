import 'package:get_it/get_it.dart';

import '../../core/services/storage_service.dart';
import '../../core/services/network_service.dart';
import '../../features/contact/data/datasources/contact_local_data_source.dart';
import '../../features/contact/data/repositories/contact_repository_impl.dart';
import '../../features/contact/domain/repositories/contact_repository.dart';
import '../../features/contact/domain/usecases/build_vcard_usecase.dart';
import '../../features/contact/domain/usecases/load_contact_usecase.dart';
import '../../features/contact/domain/usecases/save_contact_usecase.dart';
import '../../features/contact/domain/usecases/parse_vcard_usecase.dart';
import '../../features/contact/presentation/bloc/contact_bloc.dart';
import '../../features/brand/presentation/bloc/brand_bloc.dart';
import '../../features/portfolio/data/datasources/portfolio_local_data_source.dart';
import '../../features/portfolio/data/repositories/portfolio_repository_impl.dart';
import '../../features/portfolio/domain/repositories/portfolio_repository.dart';
import '../../features/portfolio/domain/usecases/load_portfolio_usecase.dart';
import '../../features/portfolio/domain/usecases/save_portfolio_usecase.dart';
import '../../features/portfolio/presentation/bloc/portfolio_bloc.dart';
import '../../features/contacts_book/data/datasources/contacts_book_local_data_source.dart';
import '../../features/contacts_book/data/repositories/contacts_book_repository_impl.dart';
import '../../features/contacts_book/domain/repositories/contacts_book_repository.dart';
import '../../features/contacts_book/presentation/bloc/contacts_book_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ── Services ──────────────────────────────────────────────────────────────
  final storage = StorageService();
  await storage.init();
  sl.registerSingleton<StorageService>(storage);
  sl.registerLazySingleton<NetworkService>(() => NetworkService());

  // ── Contact ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<ContactLocalDataSource>(
    () => ContactLocalDataSourceImpl(sl<StorageService>()),
  );
  sl.registerLazySingleton<ContactRepository>(
    () => ContactRepositoryImpl(sl<ContactLocalDataSource>()),
  );
  sl.registerLazySingleton(() => LoadContactUseCase(sl<ContactRepository>()));
  sl.registerLazySingleton(() => SaveContactUseCase(sl<ContactRepository>()));
  sl.registerLazySingleton(() => const BuildVCardUseCase());
  sl.registerLazySingleton(() => const ParseVCardUseCase()); // ← new

  sl.registerFactory(() => ContactBloc(
        loadContact: sl<LoadContactUseCase>(),
        saveContact: sl<SaveContactUseCase>(),
      ));

  // ── Portfolio ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<PortfolioLocalDataSource>(
    () => PortfolioLocalDataSourceImpl(sl<StorageService>()),
  );
  sl.registerLazySingleton<PortfolioRepository>(
    () => PortfolioRepositoryImpl(sl<PortfolioLocalDataSource>()),
  );
  sl.registerLazySingleton(
      () => LoadPortfolioUseCase(sl<PortfolioRepository>()));
  sl.registerLazySingleton(
      () => SavePortfolioUseCase(sl<PortfolioRepository>()));
  sl.registerFactory(() => PortfolioBloc(
        load: sl<LoadPortfolioUseCase>(),
        save: sl<SavePortfolioUseCase>(),
      ));

  // ── Contacts book (scanned contacts) ─────────────────────────────────────
  sl.registerLazySingleton<ContactsBookLocalDataSource>(
    () => ContactsBookLocalDataSourceImpl(sl<StorageService>()),
  );
  sl.registerLazySingleton<ContactsBookRepository>(
    () => ContactsBookRepositoryImpl(sl<ContactsBookLocalDataSource>()),
  );
  sl.registerFactory(() => ContactsBookBloc(
      repo: sl<ContactsBookRepository>(),
    ));

  // ── Brand ─────────────────────────────────────────────────────────────────
  sl.registerFactory(() => BrandBloc(storage: sl<StorageService>()));
}