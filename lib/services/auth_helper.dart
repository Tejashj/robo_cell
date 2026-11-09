/// Centralized helper for Supabase Auth synthetic identity generation.
/// Deterministically reproduces the server-side synthetic email format:
/// usn_<normalized_usn>_u<public_user_id>@auth.robocell.internal
class AuthHelper {
  static String deriveSyntheticEmail(dynamic userId, String? usn) {
    final strId = userId.toString();
    if (usn != null && usn.trim().isNotEmpty) {
      final cleanUsn = usn.trim().toLowerCase().replaceAll(
        RegExp(r'[^a-z0-9]'),
        '',
      );
      if (cleanUsn.isNotEmpty) {
        return 'usn_${cleanUsn}_u$strId@auth.robocell.internal';
      }
    }
    return 'user_$strId@auth.robocell.internal';
  }
}
