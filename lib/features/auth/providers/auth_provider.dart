import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../../../core/storage/secure_storage_service.dart';

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
  
  final _localAuth = LocalAuthentication();
  
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
      return await SecureStorageService.hasPin();
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
      await SecureStorageService.deletePin();
      
      // Write new PIN
      final saved = await SecureStorageService.savePin(pin);
      
      if (saved) {
        // Verify it was saved by reading it back
        final readBack = await SecureStorageService.readPin();
        print('✅ PIN Saved and Verified: ${readBack == pin ? "SUCCESS" : "FAILED"}');
        
        if (readBack == pin) {
          state = state.copyWith(hasPinSet: true);
          return true;
        }
      }
      
      print('❌ PIN save verification failed');
      return false;
    } catch (e) {
      print('❌ Set PIN Error: $e');
      return false;
    }
  }
  
  Future<bool> verifyPin(String pin) async {
    try {
      print('🔑 Verifying PIN...');
      print('   Input PIN: [${pin.length} digits]');
      
      final storedPin = await SecureStorageService.readPin();
      
      if (storedPin == null) {
        print('❌ No stored PIN found');
        return false;
      }
      
      print('   Stored PIN: [${storedPin.length} digits]');
      print('   Match: ${storedPin == pin}');
      
      if (storedPin == pin) {
        print('✅ PIN Verified Successfully!');
        state = state.copyWith(isAuthenticated: true);
        return true;
      }
      
      print('❌ PIN Mismatch!');
      return false;
    } catch (e) {
      print('❌ Verify PIN Error: $e');
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
    final storedPin = await SecureStorageService.readPin();
    if (storedPin == oldPin) {
      return await setPin(newPin);
    }
    return false;
  }
  
  Future<void> resetPin() async {
    await SecureStorageService.deletePin();
    state = state.copyWith(hasPinSet: false, isAuthenticated: false);
  }
  
  Future<bool> isBiometricEnabled() async {
    return await SecureStorageService.isBiometricEnabled();
  }
  
  Future<void> setBiometricEnabled(bool enabled) async {
    await SecureStorageService.setBiometricEnabled(enabled);
  }
}
