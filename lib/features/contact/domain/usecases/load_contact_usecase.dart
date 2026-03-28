import '../entities/contact_entity.dart';
import '../repositories/contact_repository.dart';

class LoadContactUseCase {
  final ContactRepository _repository;
  const LoadContactUseCase(this._repository);

  Future<ContactEntity> call() => _repository.loadContact();
}