import 'package:local_auth/local_auth.dart';

class BiometricService {

  static final LocalAuthentication auth =
      LocalAuthentication();

  static Future<bool>
      canUseBiometrics() async {

    try {

      final canCheck =
          await auth.canCheckBiometrics;

      return canCheck;

    } catch (_) {

      return false;
    }
  }

  static Future<bool>
      authenticate() async {

    try {

      return await auth.authenticate(

        localizedReason:
            'Authenticate to open Robo Cell',
      );

    } catch (_) {

      return false;
    }
  }
}