import 'package:flutter/foundation.dart';
import 'package:screen_protector/screen_protector.dart';

/// Platform-agnostic Security Service that prevents unauthorized screenshots,
/// screen recordings, and obscures recent app switcher previews (always active).
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  bool _isProtected = false;

  bool get isProtected => _isProtected;

  /// Initializes system-enforced security protection.
  Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      await enableProtection();
    } catch (e) {
      debugPrint("SecurityService initialize error: $e");
    }
  }

  /// Enables screenshot protection and recent app preview masking.
  Future<void> enableProtection() async {
    if (kIsWeb) return;
    try {
      await ScreenProtector.preventScreenshotOn();
      _isProtected = true;
      debugPrint("SecurityService: Protection ENABLED (Enforced)");
    } catch (e) {
      debugPrint("SecurityService enableProtection error: $e");
    }
  }

  /// Disables screenshot protection.
  Future<void> disableProtection() async {
    if (kIsWeb) return;
    try {
      await ScreenProtector.preventScreenshotOff();
      _isProtected = false;
      debugPrint("SecurityService: Protection DISABLED");
    } catch (e) {
      debugPrint("SecurityService disableProtection error: $e");
    }
  }

  Future<void> setProtection(bool enable) async {
    await enableProtection();
  }
}
