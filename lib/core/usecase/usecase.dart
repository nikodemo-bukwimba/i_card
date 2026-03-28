/// Base contracts for all use-cases.
abstract class UseCase<Type, Params> {
  const UseCase();
  Future<Type> call(Params params);
}

abstract class NoParamsUseCase<Type> {
  const NoParamsUseCase();
  Future<Type> call();
}

abstract class SyncUseCase<Type, Params> {
  const SyncUseCase();
  Type call(Params params);
}

/// Sentinel for parameterless use-cases.
class NoParams {
  const NoParams();
}