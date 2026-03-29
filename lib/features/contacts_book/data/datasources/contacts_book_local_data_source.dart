import '../../../../core/error/exceptions.dart';
import '../../../../core/services/storage_service.dart';
import '../models/saved_contact_model.dart';

abstract class ContactsBookLocalDataSource {
  Future<List<SavedContactModel>> loadAll();
  Future<void> saveAll(List<SavedContactModel> contacts);
}

class ContactsBookLocalDataSourceImpl implements ContactsBookLocalDataSource {
  final StorageService _storage;
  static const _key = 'contacts_book';

  const ContactsBookLocalDataSourceImpl(this._storage);

  @override
  Future<List<SavedContactModel>> loadAll() async {
    try {
      final raw = _storage.getString(_key);
      if (raw == null || raw.isEmpty) return [];
      return SavedContactModel.decodeList(raw);
    } catch (e, st) {
      throw StorageException('loadContactsBook failed: $e', st);
    }
  }

  @override
  Future<void> saveAll(List<SavedContactModel> contacts) async {
    try {
      await _storage.setString(_key, SavedContactModel.encodeList(contacts));
    } catch (e, st) {
      throw StorageException('saveContactsBook failed: $e', st);
    }
  }
}