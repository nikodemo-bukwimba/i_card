import '../entities/saved_contact.dart';

abstract class ContactsBookRepository {
  Future<List<SavedContact>> loadAll();
  Future<void> save(SavedContact contact);
  Future<void> delete(String id);
}