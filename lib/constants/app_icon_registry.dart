import 'package:flutter/material.dart';

/// Explicit static registry of all Material IconData used across ROBO CELL.
/// This prevents Flutter's release tree-shaker from stripping icons during `flutter build apk --release`.
class AppIconRegistry {
  static const List<IconData> preservedIcons = [
    // Navigation Bar Icons
    Icons.home_rounded,
    Icons.home_outlined,
    Icons.newspaper_rounded,
    Icons.newspaper_outlined,
    Icons.groups_rounded,
    Icons.groups_outlined,
    Icons.info_rounded,
    Icons.info_outline_rounded,

    // About Page Icons
    Icons.location_on_rounded,
    Icons.precision_manufacturing_rounded,
    Icons.alternate_email_rounded,

    // Committee & Member Icons
    Icons.person_rounded,
    Icons.person_outline_rounded,
    Icons.badge_rounded,
    Icons.email_rounded,
    Icons.open_in_new_rounded,
    Icons.link_rounded,
    Icons.search_rounded,
    Icons.arrow_back_rounded,

    // Login & Auth Icons
    Icons.lock_rounded,
    Icons.fingerprint_rounded,

    // Home & Feed Icons
    Icons.calendar_today_rounded,
    Icons.arrow_forward_ios_rounded,
    Icons.campaign_rounded,
    Icons.event_rounded,
    Icons.favorite_rounded,
    Icons.favorite_border_rounded,
    Icons.comment_rounded,
    Icons.share_rounded,
    Icons.add_rounded,
    Icons.image_rounded,

    // Meetings & Attendance Icons
    Icons.access_time_rounded,
    Icons.calendar_month_rounded,
    Icons.done,
    Icons.error_outline,
    Icons.dialpad,
    Icons.gpp_bad,
    Icons.verified_user,
    Icons.verified_user_outlined,
    Icons.lock_outline,
    Icons.sensors,
    Icons.warning,

    // Profile & Settings Icons
    Icons.logout_rounded,
    Icons.chevron_right_rounded,
    Icons.visibility_outlined,
    Icons.visibility_off_outlined,
    Icons.check_circle_rounded,
    Icons.warning_amber_rounded,
    Icons.error_rounded,
    Icons.inbox_rounded,
    Icons.wifi_off_rounded,
    Icons.timer_off_rounded,
    Icons.error_outline_rounded,
    Icons.security_rounded,
    Icons.refresh_rounded,
    Icons.close_rounded,
  ];
}
