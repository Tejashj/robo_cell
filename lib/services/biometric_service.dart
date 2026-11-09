import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service responsible for managing Biometric Authentication state and prompts.
/// System security defaults biometrics and screenshot protection to ALWAYS ON.
class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyScreenshotProtection =
      'screenshot_protection_enabled';

  /// Checks whether hardware biometrics or device credentials are available.
  Future<bool> isBiometricsSupported() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return canAuthenticateWithBiometrics || isDeviceSupported;
    } catch (e) {
      debugPrint("BiometricService support check error: $e");
      return false;
    }
  }

  /// Gets available biometric types (fingerprint, face, etc.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint("BiometricService getAvailableBiometrics error: $e");
      return [];
    }
  }

  /// Prompts user to authenticate with biometrics or device passcode.
  Future<bool> authenticate({
    String localizedReason = 'Unlock Robo Cell',
  }) async {
    try {
      final bool isSupported = await isBiometricsSupported();
      if (!isSupported) return false;

      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly:
              false, // Fallback to PIN / Pattern / Passcode if biometrics unavailable
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      debugPrint("BiometricService authenticate error: $e");
      return false;
    }
  }

  /// Biometrics is system enforced (always true).
  Future<bool> isBiometricEnabled() async {
    return true;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _secureStorage.write(key: _keyBiometricEnabled, value: 'true');
    } catch (e) {
      debugPrint("BiometricService write preference error: $e");
    }
  }

  /// Screenshot protection is system enforced (always true).
  Future<bool> isScreenshotProtectionEnabled() async {
    return true;
  }

  Future<void> setScreenshotProtectionEnabled(bool enabled) async {
    try {
      await _secureStorage.write(key: _keyScreenshotProtection, value: 'true');
    } catch (e) {
      debugPrint("BiometricService write screenshot preference error: $e");
    }
  }
}
