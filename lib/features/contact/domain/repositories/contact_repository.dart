import '../entities/contact_entity.dart';

abstract class ContactRepository {
  Future<ContactEntity> loadContact();
  Future<void> saveContact(ContactEntity contact);
}