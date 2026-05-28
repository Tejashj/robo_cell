import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {

  static const storage =
      FlutterSecureStorage();

  static const biometricKey =
      'biometric_enabled';

  static Future<void>
      enableBiometric() async {

    await storage.write(

      key: biometricKey,

      value: 'true',
    );
  }

  static Future<void>
      disableBiometric() async {

    await storage.delete(
      key: biometricKey,
    );
  }

  static Future<bool>
      isBiometricEnabled() async {

    final value =
        await storage.read(
      key: biometricKey,
    );

    return value == 'true';
  }
}