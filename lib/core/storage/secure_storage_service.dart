import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure storage service using SharedPreferences with encryption
/// This ensures data persists even after app restart
class SecureStorageService {
  static const String _pinKey = 'encrypted_user_pin';
  static const String _biometricKey = 'biometric_enabled';
  
  // Encryption key - MUST be exactly 32 characters (256 bits)
  // Count: MedResearchAssistant_Key_2025_v1
  //        12345678901234567890123456789012
  static const String _encryptionKeyString = 'MedResearchAssistant_Key_2025_v1'; // Exactly 32 chars
  
  // IV - MUST be exactly 16 characters (128 bits) and FIXED (not random!)
  //      1234567890123456
  static const String _ivString = 'MedResearch_IV16'; // Exactly 16 chars
  
  // Use getters to ensure consistent key and IV
  static Key get _key => Key.fromUtf8(_encryptionKeyString);
  static IV get _iv => IV.fromUtf8(_ivString);
  static Encrypter get _encrypter => Encrypter(AES(_key));
  
  /// Save PIN securely (encrypted)
  static Future<bool> savePin(String pin) async {
    try {
      print('💾 Saving PIN to SharedPreferences...');
      print('   PIN to save: [${pin.length} digits]');
      
      final prefs = await SharedPreferences.getInstance();
      
      // Encrypt the PIN
      final encrypted = _encrypter.encrypt(pin, iv: _iv);
      final encryptedString = encrypted.base64;
      
      print('   Encrypted: ${encryptedString.substring(0, 20)}...');
      
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
      
      print('   Found encrypted: ${encryptedString.substring(0, 20)}...');
      
      try {
        // Decrypt the PIN
        final encrypted = Encrypted.fromBase64(encryptedString);
        final decrypted = _encrypter.decrypt(encrypted, iv: _iv);
        
        print('   Decrypted: [${decrypted.length} digits]');
        return decrypted;
      } catch (e) {
        // If decryption fails (old key), clear corrupted data
        print('⚠️  Corrupted PIN data detected (old encryption key), clearing...');
        await prefs.remove(_pinKey);
        return null;
      }
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
