import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isAuthenticated;
  final bool hasPinSet;
  final bool isBiometricAvailable;
  final bool isInitialized; // Track if initialization is complete
  
  AuthState({
    this.isAuthenticated = false,
    this.hasPinSet = false,
    this.isBiometricAvailable = false,
    this.isInitialized = false,
  });
  
  AuthState copyWith({
    bool? isAuthenticated,
    bool? hasPinSet,
    bool? isBiometricAvailable,
    bool? isInitialized,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      hasPinSet: hasPinSet ?? this.hasPinSet,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _init();
  }
  
  // Use default secure storage without custom options
  final _storage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();
  
  static const String _pinKey = 'user_pin';
  static const String _biometricEnabledKey = 'biometric_enabled';
  
  Future<void> _init() async {
    try {
      final hasPin = await _checkIfPinExists();
      final hasBiometric = await _checkBiometric();
      
      print('🔐 Auth Init - Has PIN: $hasPin, Has Biometric: $hasBiometric');
      
      state = state.copyWith(
        hasPinSet: hasPin,
        isBiometricAvailable: hasBiometric,
        isInitialized: true, // Mark as initialized
      );
    } catch (e) {
      print('❌ Auth Init Error: $e');
      state = state.copyWith(isInitialized: true); // Still mark as initialized even on error
    }
  }
  
  Future<bool> _checkIfPinExists() async {
    try {
      final pin = await _storage.read(key: _pinKey);
      print('🔍 Checking PIN: ${pin != null ? "Found" : "Not Found"}');
      return pin != null && pin.isNotEmpty;
    } catch (e) {
      print('❌ Check PIN Error: $e');
      return false;
    }
  }
  
  Future<bool> _checkBiometric() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> setPin(String pin) async {
    try {
      print('💾 Saving PIN to secure storage...');
      
      // Delete any existing PIN first
      await _storage.delete(key: _pinKey);
      
      // Write new PIN
      await _storage.write(key: _pinKey, value: pin);
      
      // Verify it was saved by reading it back
      final saved = await _storage.read(key: _pinKey);
      print('✅ PIN Saved and Verified: ${saved == pin ? "SUCCESS" : "FAILED"}');
      print('   Saved value: ${saved != null ? "[HIDDEN]" : "NULL"}');
      
      if (saved == pin) {
        state = state.copyWith(hasPinSet: true);
        return true;
      } else {
        print('❌ Verification failed - saved value does not match');
        return false;
      }
    } catch (e) {
      print('❌ Set PIN Error: $e');
      return false;
    }
  }
  
  Future<bool> verifyPin(String pin) async {
    try {
      final storedPin = await _storage.read(key: _pinKey);
      if (storedPin == pin) {
        state = state.copyWith(isAuthenticated: true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> authenticateWithBiometric() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access medical research data',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      
      if (authenticated) {
        state = state.copyWith(isAuthenticated: true);
      }
      
      return authenticated;
    } catch (e) {
      return false;
    }
  }
  
  void logout() {
    state = state.copyWith(isAuthenticated: false);
  }
  
  Future<bool> changePin(String oldPin, String newPin) async {
    // Verify old PIN without changing auth state
    final storedPin = await _storage.read(key: _pinKey);
    if (storedPin == oldPin) {
      return await setPin(newPin);
    }
    return false;
  }
  
  Future<void> resetPin() async {
    await _storage.delete(key: _pinKey);
    state = state.copyWith(hasPinSet: false, isAuthenticated: false);
  }
  
  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }
  
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }
}
