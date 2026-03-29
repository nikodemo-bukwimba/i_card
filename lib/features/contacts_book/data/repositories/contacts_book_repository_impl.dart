import '../../domain/entities/saved_contact.dart';
import '../../domain/repositories/contacts_book_repository.dart';
import '../datasources/contacts_book_local_data_source.dart';
import '../models/saved_contact_model.dart';

class ContactsBookRepositoryImpl implements ContactsBookRepository {
  final ContactsBookLocalDataSource _local;
  const ContactsBookRepositoryImpl(this._local);

  @override
  Future<List<SavedContact>> loadAll() => _local.loadAll();

  @override
  Future<void> save(SavedContact contact) async {
    final all = await _local.loadAll();
    // Replace if same id already exists, otherwise append
    final idx = all.indexWhere((e) => e.id == contact.id);
    if (idx >= 0) {
      all[idx] = SavedContactModel.fromDomain(contact);
    } else {
      all.add(SavedContactModel.fromDomain(contact));
    }
    await _local.saveAll(all);
  }

  @override
  Future<void> delete(String id) async {
    final all = await _local.loadAll();
    all.removeWhere((e) => e.id == id);
    await _local.saveAll(all);
  }
}