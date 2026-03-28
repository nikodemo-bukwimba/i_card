import '../entities/contact_entity.dart';
import '../repositories/contact_repository.dart';

class SaveContactUseCase {
  final ContactRepository _repository;
  const SaveContactUseCase(this._repository);

  Future<void> call(ContactEntity contact) =>
      _repository.saveContact(contact);
}