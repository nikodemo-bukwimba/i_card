import 'package:shared_preferences/shared_preferences.dart';
import '../error/exceptions.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// StorageService — thin wrapper around SharedPreferences.
///
/// Swap the backend (e.g. Drift / SQLite) by modifying ONLY this file.
/// All callers stay unchanged.
///
/// Drift migration notes:
///   1. Add `drift` + `drift_flutter` to pubspec.yaml.
///   2. Create `AppDatabase` with `@DriftDatabase(tables: [Contacts])`.
///   3. Replace `_prefs` calls below with DAO calls.
///   4. Update injection_container.dart to register the database singleton.
/// ─────────────────────────────────────────────────────────────────────────────
class StorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e, st) {
      throw StorageException('Failed to initialise storage: $e', st);
    }
  }

  String?       getString(String key)     => _prefs.getString(key);
  bool?         getBool(String key)       => _prefs.getBool(key);
  int?          getInt(String key)        => _prefs.getInt(key);
  List<String>? getStringList(String key) => _prefs.getStringList(key);
  bool          containsKey(String key)   => _prefs.containsKey(key);

  Future<void> setString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
    } catch (e, st) {
      throw StorageException('setString("$key") failed: $e', st);
    }
  }

  Future<void> setBool(String key, bool value) async {
    try {
      await _prefs.setBool(key, value);
    } catch (e, st) {
      throw StorageException('setBool("$key") failed: $e', st);
    }
  }

  Future<void> setInt(String key, int value) async {
    try {
      await _prefs.setInt(key, value);
    } catch (e, st) {
      throw StorageException('setInt("$key") failed: $e', st);
    }
  }

  /// Write multiple string entries — closest to an atomic batch with prefs.
  Future<void> setMap(Map<String, String> map) async {
    for (final e in map.entries) {
      await setString(e.key, e.value);
    }
  }

  Future<void> remove(String key) async {
    try {
      await _prefs.remove(key);
    } catch (e, st) {
      throw StorageException('remove("$key") failed: $e', st);
    }
  }

  Future<void> clear() async {
    try {
      await _prefs.clear();
    } catch (e, st) {
      throw StorageException('clear() failed: $e', st);
    }
  }
}