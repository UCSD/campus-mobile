// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//
// class StorageService {
//   static const _secureStorage = FlutterSecureStorage(
//     iOptions: IOSOptions(
//       accessibility: KeychainAccessibility.first_unlock_this_device,
//       synchronizable: false,
//     ),
//     aOptions: AndroidOptions(
//       encryptedSharedPreferences: true,
//     ),
//   );
//
//   // Store credential in secure storage
//   static Future<void> storeCredential(String key, String value) async {
//     try {
//       await _secureStorage.write(key: key, value: value);
//     } catch (e) {
//       throw StorageException('Failed to store credential: $e');
//     }
//   }
//
//   // Get credential from secure storage
//   static Future<String?> getCredential(String key) async {
//     try {
//       return await _secureStorage.read(key: key);
//     } catch (e) {
//       print('Storage read error for key "$key": $e');
//       return null;
//     }
//   }
//
//   // Remove credential from secure storage
//   static Future<void> removeCredential(String key) async {
//     try {
//       await _secureStorage.delete(key: key);
//     } catch (e) {
//       print('Storage delete error for key "$key": $e');
//     }
//   }
//
//   // Clear all credentials from secure storage
//   static Future<void> clearAll() async {
//     try {
//       await _secureStorage.deleteAll();
//     } catch (e) {
//       print('Storage clear all error: $e');
//     }
//   }
//
//   // Check if a key exists in secure storage
//   static Future<bool> hasKey(String key) async {
//     try {
//       return await _secureStorage.containsKey(key: key);
//     } catch (e) {
//       print('Storage key check error for key "$key": $e');
//       return false;
//     }
//   }
//
//   // Get all keys from secure storage
//   static Future<Map<String, String>> getAllCredentials() async {
//     try {
//       return await _secureStorage.readAll();
//     } catch (e) {
//       print('Storage read all error: $e');
//       return {};
//     }
//   }
// }
//
// class StorageException implements Exception {
//   final String message;
//   StorageException(this.message);
//
//   @override
//   String toString() => 'StorageException: $message';
// }
