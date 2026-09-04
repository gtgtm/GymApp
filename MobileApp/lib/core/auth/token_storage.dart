import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the Sanctum API token in platform-secure storage
/// (Keychain on iOS, EncryptedSharedPreferences on Android).
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'gymapp_member_token';

  final FlutterSecureStorage _storage;

  Future<String?> read() => _storage.read(key: _tokenKey);

  Future<void> write(String token) => _storage.write(key: _tokenKey, value: token);

  Future<void> clear() => _storage.delete(key: _tokenKey);
}
