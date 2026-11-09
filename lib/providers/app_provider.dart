import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final _box = Hive.box('robo_cache');

  // Theme Management (Default Dark Mode, with Light Mode support)
  ThemeMode _themeMode = ThemeMode.dark;

  // Cached Data
  List<Map<String, dynamic>> _hierarchyData = [];
  List<Map<String, dynamic>> _posts = [];
  List<Map<String, dynamic>> _meetings = [];
  List<Map<String, dynamic>> _committees = [];
  List<Map<String, dynamic>> _users = [];

  // Loading States
  bool _isLoadingHierarchy = false;
  bool _isLoadingPosts = false;
  bool _isLoadingMeetings = false;

  AppProvider() {
    _loadFromCache();
  }

  void _loadFromCache() {
    final isDark = _box.get('is_dark_mode', defaultValue: true);
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    final cachedHierarchy = _box.get('hierarchyData');
    if (cachedHierarchy != null) {
      _hierarchyData = List<Map<String, dynamic>>.from(
        (cachedHierarchy as List).map((e) => Map<String, dynamic>.from(e)),
      );
    }

    final cachedPosts = _box.get('posts');
    if (cachedPosts != null) {
      _posts = List<Map<String, dynamic>>.from(
        (cachedPosts as List).map((e) => Map<String, dynamic>.from(e)),
      );
    }

    final cachedMeetings = _box.get('meetings');
    if (cachedMeetings != null) {
      _meetings = List<Map<String, dynamic>>.from(
        (cachedMeetings as List).map((e) => Map<String, dynamic>.from(e)),
      );
    }

    final cachedCommittees = _box.get('committees');
    if (cachedCommittees != null) {
      _committees = List<Map<String, dynamic>>.from(
        (cachedCommittees as List).map((e) => Map<String, dynamic>.from(e)),
      );
    }

    notifyListeners();
  }

  // Theme Getters & Actions
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleThemeMode(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _box.put('is_dark_mode', isDark);
    notifyListeners();
  }

  // Data Getters
  List<Map<String, dynamic>> get hierarchyData => _hierarchyData;
  List<Map<String, dynamic>> get posts => _posts;
  List<Map<String, dynamic>> get meetings => _meetings;
  List<Map<String, dynamic>> get committees => _committees;
  List<Map<String, dynamic>> get users => _users;

  List<Map<String, dynamic>> get latestPosts => _posts.take(3).toList();
  List<Map<String, dynamic>> get liveMeetings =>
      _meetings.where((m) => m['attendance_enabled'] == true).toList();

  bool get isLoadingHierarchy => _isLoadingHierarchy;
  bool get isLoadingPosts => _isLoadingPosts;
  bool get isLoadingMeetings => _isLoadingMeetings;

  Future<void> fetchHierarchy() async {
    _isLoadingHierarchy = true;
    notifyListeners();

    debugPrint('=== COMMITTEE DIAGNOSTIC ===');
    debugPrint(
      'AUTH SESSION EXISTS = ${_supabase.auth.currentSession != null}',
    );
    debugPrint('AUTH USER UUID = ${_supabase.auth.currentUser?.id}');
    debugPrint('COMMITTEE QUERY START');

    try {
      final res = await _supabase
          .from('committee_members_view')
          .select()
          .order('display_order', ascending: true)
          .order('id', ascending: true);
      _hierarchyData = List<Map<String, dynamic>>.from(res as List);
      _box.put('hierarchyData', _hierarchyData);
      debugPrint('COMMITTEE ROW COUNT = ${_hierarchyData.length}');
      debugPrint('COMMITTEE QUERY ERROR = NONE');
    } catch (e) {
      debugPrint('COMMITTEE QUERY ERROR = $e');
    } finally {
      debugPrint('FINAL COMMITTEE LIST LENGTH = ${_hierarchyData.length}');
      debugPrint('=== END COMMITTEE DIAGNOSTIC ===');
      _isLoadingHierarchy = false;
      notifyListeners();
    }
  }

  Future<void> fetchPosts({bool forceRefresh = false}) async {
    if (_posts.isNotEmpty && !forceRefresh) return;
    _isLoadingPosts = true;
    notifyListeners();

    try {
      final res = await _supabase
          .from('posts')
          .select('*, users(name, photo_url, role)')
          .order('created_at', ascending: false);

      _posts = List<Map<String, dynamic>>.from(res as List);
      _box.put('posts', _posts);
    } catch (e) {
      debugPrint("Fetch Posts error: $e");
    } finally {
      _isLoadingPosts = false;
      notifyListeners();
    }
  }

  Future<void> fetchMeetings({
    bool forceRefresh = false,
    bool loadUsers = false,
    dynamic userCommitteeId,
  }) async {
    if (_meetings.isNotEmpty && !forceRefresh) return;
    _isLoadingMeetings = true;
    notifyListeners();

    try {
      var query = _supabase.from('meetings').select();

      final res = await query.order('scheduled_at', ascending: false);
      _meetings = List<Map<String, dynamic>>.from(res as List);
      _box.put('meetings', _meetings);

      if (loadUsers) {
        final cRes = await _supabase.from('committees').select();
        _committees = List<Map<String, dynamic>>.from(cRes as List);
        _box.put('committees', _committees);

        final uRes = await _supabase
            .from('users')
            .select('id, name, committee_id, role');
        _users = List<Map<String, dynamic>>.from(uRes as List);
      }
    } catch (e) {
      debugPrint("Fetch Meetings error: $e");
    } finally {
      _isLoadingMeetings = false;
      notifyListeners();
    }
  }
}
