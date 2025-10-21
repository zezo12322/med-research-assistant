import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure storage service using SharedPreferences with encryption
/// This ensures data persists even after app restart
class SecureStorageService {
  static const String _pinKey = 'encrypted_user_pin';
  static const String _biometricKey = 'biometric_enabled';
  
  // Encryption key - MUST be exactly 32 characters (256 bits)
  static final _key = Key.fromUtf8('medResearchAssistantKey2025!!'); // Exactly 32 chars
  static final _iv = IV.fromLength(16);
  static final _encrypter = Encrypter(AES(_key));
  
  /// Save PIN securely (encrypted)
  static Future<bool> savePin(String pin) async {
    try {
      print('💾 Saving PIN to SharedPreferences...');
      
      final prefs = await SharedPreferences.getInstance();
      
      // Encrypt the PIN
      final encrypted = _encrypter.encrypt(pin, iv: _iv);
      final encryptedString = encrypted.base64;
      
      // Save to SharedPreferences
      final saved = await prefs.setString(_pinKey, encryptedString);
      
      // Verify it was saved
      final verify = prefs.getString(_pinKey);
      print('✅ PIN Saved: ${verify != null ? "SUCCESS" : "FAILED"}');
      
      return saved;
    } catch (e) {
      print('❌ Save PIN Error: $e');
      return false;
    }
  }
  
  /// Read PIN securely (decrypt)
  static Future<String?> readPin() async {
    try {
      print('🔍 Reading PIN from SharedPreferences...');
      
      final prefs = await SharedPreferences.getInstance();
      final encryptedString = prefs.getString(_pinKey);
      
      if (encryptedString == null) {
        print('   PIN not found');
        return null;
      }
      
      // Decrypt the PIN
      final encrypted = Encrypted.fromBase64(encryptedString);
      final decrypted = _encrypter.decrypt(encrypted, iv: _iv);
      
      print('   PIN found: [HIDDEN]');
      return decrypted;
    } catch (e) {
      print('❌ Read PIN Error: $e');
      return null;
    }
  }
  
  /// Check if PIN exists
  static Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    final exists = prefs.containsKey(_pinKey);
    print('🔐 Has PIN: $exists');
    return exists;
  }
  
  /// Delete PIN
  static Future<bool> deletePin() async {
    try {
      print('🗑️ Deleting PIN...');
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_pinKey);
    } catch (e) {
      print('❌ Delete PIN Error: $e');
      return false;
    }
  }
  
  /// Save biometric enabled state
  static Future<bool> setBiometricEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_biometricKey, enabled);
    } catch (e) {
      print('❌ Set Biometric Error: $e');
      return false;
    }
  }
  
  /// Read biometric enabled state
  static Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricKey) ?? false;
    } catch (e) {
      print('❌ Read Biometric Error: $e');
      return false;
    }
  }
  
  /// Clear all secure data
  static Future<bool> clearAll() async {
    try {
      print('🧹 Clearing all secure data...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pinKey);
      await prefs.remove(_biometricKey);
      return true;
    } catch (e) {
      print('❌ Clear All Error: $e');
      return false;
    }
  }
}
