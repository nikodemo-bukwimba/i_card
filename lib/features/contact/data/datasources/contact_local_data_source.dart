import '../../../../core/error/exceptions.dart';
import '../../../../core/services/storage_service.dart';
import '../models/contact_model.dart';

abstract class ContactLocalDataSource {
  Future<ContactModel> loadContact();
  Future<void> saveContact(ContactModel model);
}

class ContactLocalDataSourceImpl implements ContactLocalDataSource {
  final StorageService _storage;
  const ContactLocalDataSourceImpl(this._storage);

  static const _keys = [
    'name', 'title', 'org', 'phone', 'phone2', 'email',
    'whatsapp', 'website', 'linkedin', 'address', 'tagline', 'photoBase64',
  ];

  @override
  Future<ContactModel> loadContact() async {
    try {
      final map = {for (final k in _keys) k: _storage.getString(k)};
      return ContactModel.fromPrefs(map);
    } catch (e, st) {
      throw StorageException('loadContact failed: $e', st);
    }
  }

  @override
  Future<void> saveContact(ContactModel model) async {
    try {
      await _storage.setMap(model.toPrefs());
    } catch (e, st) {
      throw StorageException('saveContact failed: $e', st);
    }
  }
}