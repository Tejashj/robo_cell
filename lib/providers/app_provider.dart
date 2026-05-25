import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  final _box = Hive.box('robo_cache');

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
    final cachedHierarchy = _box.get('hierarchyData');
    if (cachedHierarchy != null) {
      _hierarchyData = List<Map<String, dynamic>>.from(
        (cachedHierarchy as List).map((e) => Map<String, dynamic>.from(e))
      );
    }
    
    final cachedPosts = _box.get('posts');
    if (cachedPosts != null) {
      _posts = List<Map<String, dynamic>>.from(
        (cachedPosts as List).map((e) => Map<String, dynamic>.from(e))
      );
    }
    
    final cachedMeetings = _box.get('meetings');
    if (cachedMeetings != null) {
      _meetings = List<Map<String, dynamic>>.from(
        (cachedMeetings as List).map((e) => Map<String, dynamic>.from(e))
      );
    }

    final cachedCommittees = _box.get('committees');
    if (cachedCommittees != null) {
      _committees = List<Map<String, dynamic>>.from(
        (cachedCommittees as List).map((e) => Map<String, dynamic>.from(e))
      );
    }

    // Instantly notify listeners with the disk-cached data
    notifyListeners();
  }

  // Getters
  List<Map<String, dynamic>> get hierarchyData => _hierarchyData;
  List<Map<String, dynamic>> get posts => _posts;
  List<Map<String, dynamic>> get meetings => _meetings;
  List<Map<String, dynamic>> get committees => _committees;
  List<Map<String, dynamic>> get users => _users;

  bool get isLoadingHierarchy => _isLoadingHierarchy;
  bool get isLoadingPosts => _isLoadingPosts;
  bool get isLoadingMeetings => _isLoadingMeetings;

  // Helper getters
  List<Map<String, dynamic>> get liveMeetings => _meetings.where((m) => 
      m['attendance_enabled'] == true && m['is_completed'] != true).toList();

  List<Map<String, dynamic>> get latestPosts => _posts.take(3).toList();

  /// ================= FETCH HIERARCHY (Committees Page) =================
  Future<void> fetchHierarchy({bool forceRefresh = false}) async {
    // If we have data and we're not forcing a refresh, skip the network call
    if (_hierarchyData.isNotEmpty && !forceRefresh) return;

    _isLoadingHierarchy = true;
    if (forceRefresh) notifyListeners();

    try {
      final List<dynamic> response = await _supabase
          .from('users_hierarchy_view')
          .select()
          .order('display_order', ascending: true)
          .order('id', ascending: true);

      _hierarchyData = List<Map<String, dynamic>>.from(response);

      if (_hierarchyData.isNotEmpty) {
        final List<dynamic> userIds = _hierarchyData.map((row) => row['id']).toList();
        
        final List<dynamic> usersResponse = await _supabase
            .from('users')
            .select('id, linkedin')
            .inFilter('id', userIds);

        final Map<dynamic, String?> linkedinMapping = {
          for (var row in usersResponse) row['id']: row['linkedin']?.toString().trim()
        };

        for (var row in _hierarchyData) {
          final userId = row['id'];
          row['linkedin'] = linkedinMapping[userId];
        }
      }

      // Save fresh data to Hive
      await _box.put('hierarchyData', _hierarchyData);

    } catch (e) {
      debugPrint("Hierarchy fetch failed: $e");
    }

    _isLoadingHierarchy = false;
    notifyListeners();
  }

  /// ================= FETCH POSTS (Feed & Home) =================
  Future<void> fetchPosts({bool forceRefresh = false}) async {
    if (_posts.isNotEmpty && !forceRefresh) return;

    _isLoadingPosts = true;
    if (forceRefresh) notifyListeners();

    try {
      final data = await _supabase
          .from('posts')
          .select('*, users(name, role, photo_url)')
          .order('created_at', ascending: false);

      _posts = List<Map<String, dynamic>>.from(data);
      
      // Save fresh data to Hive
      await _box.put('posts', _posts);

    } catch (e) {
      debugPrint("Posts fetch failed: $e");
    }

    _isLoadingPosts = false;
    notifyListeners();
  }

  /// ================= FETCH MEETINGS (Meetings & Home) =================
  Future<void> fetchMeetings({bool forceRefresh = false, bool loadUsers = false, int? userCommitteeId}) async {
    if (_meetings.isNotEmpty && !forceRefresh) return;

    _isLoadingMeetings = true;
    if (forceRefresh) notifyListeners();

    try {
      final meetingsData = await _supabase
          .from('meetings')
          .select()
          .order('scheduled_at', ascending: true);
      
      _meetings = List<Map<String, dynamic>>.from(meetingsData);
      await _box.put('meetings', _meetings);

      // Fetch committees and users for meeting creation/management
      if (_committees.isEmpty || forceRefresh) {
        final committeeData = await _supabase.from('committees').select();
        _committees = List<Map<String, dynamic>>.from(committeeData);
        await _box.put('committees', _committees);
      }

      if (loadUsers && (_users.isEmpty || forceRefresh)) {
        dynamic usersData;
        if (userCommitteeId == null) {
          // Admin/Service Director loads all users
          usersData = await _supabase.from('users').select().order('name');
        } else {
          // Normal users load their committee
          usersData = await _supabase
              .from('users')
              .select()
              .eq('committee_id', userCommitteeId)
              .order('name');
        }
        _users = List<Map<String, dynamic>>.from(usersData);
      }
    } catch (e) {
      debugPrint("Meetings fetch failed: $e");
    }

    _isLoadingMeetings = false;
    notifyListeners();
  }
}
