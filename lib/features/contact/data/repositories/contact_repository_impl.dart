import '../../domain/entities/contact_entity.dart';
import '../../domain/repositories/contact_repository.dart';
import '../datasources/contact_local_data_source.dart';
import '../models/contact_model.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ContactLocalDataSource _local;
  const ContactRepositoryImpl(this._local);

  @override
  Future<ContactEntity> loadContact() => _local.loadContact();

  @override
  Future<void> saveContact(ContactEntity contact) =>
      _local.saveContact(ContactModel.fromEntity(contact));
}