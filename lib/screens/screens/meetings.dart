import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MeetingsPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const MeetingsPage({
    super.key,
    required this.user,
  });

  @override
  State<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  List meetings = [];
  List committees = [];
  List users = [];

  List selectedCommittees = [];
  List selectedUsers = [];

  bool allCommittees = false;
  bool loading = true;
  bool creatingMeeting = false;
  bool markingAttendance = false;

  DateTime? selectedDateTime;
  late TabController _tabController;

  final titleController = TextEditingController();
  final agendaController = TextEditingController();
  final descriptionController = TextEditingController();
  final attendanceController = TextEditingController();
  final verifyCodeController = TextEditingController();

  // Low-Profile Minimalist Palette
  static const Color kPrimaryTeal = Color(0xFF148F77);
  static const Color kAccentTeal = Color(0xFF1ABC9C);
  static const Color kBackgroundBg = Color(0xFF09090A);
  static const Color kSurfaceCard = Color(0xFF121214);
  static const Color kSurfaceOverlay = Color(0xFF18181B);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    titleController.dispose();
    agendaController.dispose();
    descriptionController.dispose();
    attendanceController.dispose();
    verifyCodeController.dispose();
    super.dispose();
  }

  /// =========================
  /// ROLE SECURITY CHECKS
  /// =========================

  bool isAdmin() {
    final role = widget.user['role'].toString().toLowerCase();
    return role == 'president' ||
        role == 'secretary' ||
        role == 'joint_secretary';
  }

  bool isServiceDirector() {
    return widget.user['role'].toString().toLowerCase() == 'service_director';
  }

  bool isCommitteeHead() {
    final role = widget.user['role'].toString().toLowerCase();
    return role == 'head' || role == 'co_head';
  }

  bool canCreateMeeting() {
    return isAdmin() || isServiceDirector() || isCommitteeHead();
  }

  /// =========================
  /// CORE DATA PIPELINES
  /// =========================

  Future<void> loadData() async {
    try {
      final meetingsData = await supabase
          .from('meetings')
          .select()
          .order('scheduled_at', ascending: true);

      final committeeData = await supabase.from('committees').select();

      dynamic usersData;
      if (isAdmin() || isServiceDirector()) {
        usersData = await supabase.from('users').select().order('name');
      } else {
        usersData = await supabase
            .from('users')
            .select()
            .eq('committee_id', widget.user['committee_id'])
            .order('name');
      }

      if (!mounted) return;

      setState(() {
        meetings = meetingsData;
        committees = committeeData;
        users = usersData;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
      showSnack(e.toString(), const Color(0xFFE74C3C), Icons.error_outline);
    }
  }

  void showSnack(String text, Color accentColor, IconData icon) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: Colors.transparent,
          duration: const Duration(seconds: 3),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: kSurfaceOverlay,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withOpacity(0.2), width: 1),
            ),
            child: Row(
              children: [
                Icon(icon, color: accentColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  String generateCode() {
    final random = Random();
    return List.generate(7, (_) => random.nextInt(10)).join();
  }

  Future<void> pickDateTime(StateSetter setDialogState) async {
    HapticFeedback.selectionClick();
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: kPrimaryTeal,
            onPrimary: Colors.black,
            surface: kSurfaceCard,
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: kBackgroundBg,
        ),
        child: child!,
      ),
    );

    if (date == null) return;

    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: kPrimaryTeal,
            onPrimary: Colors.black,
            surface: kSurfaceCard,
            onSurface: Colors.white,
          ),
          dialogBackgroundColor: kBackgroundBg,
        ),
        child: child!,
      ),
    );

    if (time == null) return;

    setDialogState(() {
      selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  /// =========================
  /// BACKEND OPERATIONS
  /// =========================

  Future<void> createMeeting() async {
    if (creatingMeeting) return;

    final title = titleController.text.trim();
    final agenda = agendaController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || agenda.isEmpty || description.isEmpty || selectedDateTime == null) {
      return showSnack("All validation metrics fields required.", const Color(0xFFE74C3C), Icons.warning_amber_rounded);
    }

    setState(() => creatingMeeting = true);
    final approvalStatus = isAdmin() ? 'approved' : 'pending';

    try {
      final response = await supabase
          .from('meetings')
          .insert({
            'title': title,
            'agenda': agenda,
            'description': description,
            'created_by': widget.user['id'],
            'approval_status': approvalStatus,
            'attendance_enabled': false,
            'attendance_code': generateCode(),
            'scheduled_at': selectedDateTime!.toIso8601String(),
            'is_completed': false,
          })
          .select()
          .single();

      final meetingId = response['id'];
      final targetCommitteeIds = isCommitteeHead()
          ? [widget.user['committee_id']]
          : allCommittees
              ? committees.map((c) => c['id']).toList()
              : selectedCommittees;

      for (final committeeId in targetCommitteeIds) {
        await supabase.from('meeting_committees').insert({
          'meeting_id': meetingId,
          'committee_id': committeeId,
        });
      }

      Set<dynamic> finalUserIds = {};
      if (selectedUsers.isNotEmpty) {
        finalUserIds.addAll(selectedUsers);
      } else {
        if (allCommittees) {
          finalUserIds.addAll(users.map((u) => u['id']));
        } else if (targetCommitteeIds.isNotEmpty) {
          final targetedUsers = users.where((u) => targetCommitteeIds.contains(u['committee_id']));
          finalUserIds.addAll(targetedUsers.map((u) => u['id']));
        }
      }

      for (final userId in finalUserIds) {
        await supabase.from('meeting_participants').insert({
          'meeting_id': meetingId,
          'user_id': userId,
        });
      }

      if (!mounted) return;
      Navigator.of(context).pop();

      titleController.clear();
      agendaController.clear();
      descriptionController.clear();
      selectedCommittees = [];
      selectedUsers = [];
      selectedDateTime = null;
      allCommittees = false;

      setState(() => creatingMeeting = false);
      await loadData();
      showSnack("SESSION STRUCTURAL PROTOCOL LOGGED", kPrimaryTeal, Icons.done);
    } catch (e) {
      if (!mounted) return;
      setState(() => creatingMeeting = false);
      showSnack(e.toString(), const Color(0xFFE74C3C), Icons.error_outline);
    }
  }

  Future<void> verifyAndMarkAttendance(Map<String, dynamic> meeting) async {
    final typedCode = verifyCodeController.text.trim();
    if (typedCode.isEmpty) {
      return showSnack("Enter telemetry code matrix.", const Color(0xFFF39C12), Icons.dialpad);
    }

    if (typedCode != meeting['attendance_code'].toString()) {
      return showSnack("Code validation failed.", const Color(0xFFE74C3C), Icons.gpp_bad);
    }

    setState(() => markingAttendance = true);
    try {
      final existing = await supabase
          .from('attendance_records')
          .select()
          .eq('meeting_id', meeting['id'])
          .eq('user_id', widget.user['id']);

      if (existing.isNotEmpty) {
        verifyCodeController.clear();
        setState(() => markingAttendance = false);
        if (!mounted) return;
        Navigator.pop(context);
        return showSnack("Signature verification verified.", kAccentTeal, Icons.verified_user);
      }

      await supabase.from('attendance_records').insert({
        'meeting_id': meeting['id'],
        'user_id': widget.user['id'],
      });

      verifyCodeController.clear();
      setState(() => markingAttendance = false);
      if (!mounted) return;
      Navigator.pop(context);
      showSnack("ATTENDANCE SIGNATURE LOGGED", kPrimaryTeal, Icons.done);
    } catch (e) {
      setState(() => markingAttendance = false);
      showSnack(e.toString(), const Color(0xFFE74C3C), Icons.error_outline);
    }
  }

  Future<void> terminateSession(int id) async {
    try {
      await supabase.from('meetings').update({
        'attendance_enabled': false,
        'is_completed': true,
      }).eq('id', id);
      await loadData();
      showSnack("SESSION TERMINATED AND LOCKED", Colors.white54, Icons.lock_outline);
    } catch (e) {
      showSnack(e.toString(), const Color(0xFFE74C3C), Icons.error_outline);
    }
  }

  Future<void> approveMeeting(int id) async {
    try {
      await supabase.from('meetings').update({'approval_status': 'approved'}).eq('id', id);
      await loadData();
      showSnack("MEETING STATUS AUTHORIZED", kPrimaryTeal, Icons.verified_user_outlined);
    } catch (e) {
      showSnack(e.toString(), const Color(0xFFE74C3C), Icons.error_outline);
    }
  }

  Future<void> startAttendance(int id) async {
    try {
      await supabase.from('meetings').update({
        'attendance_enabled': true,
        'attendance_code': generateCode(),
      }).eq('id', id);
      await loadData();
      showSnack("LIVE TELEMETRY BROADCAST ONLINE", kPrimaryTeal, Icons.sensors);
    } catch (e) {
      showSnack(e.toString(), const Color(0xFFE74C3C), Icons.error_outline);
    }
  }

  Future<void> downloadAttendance(int meetingId) async {
    try {
      final data = await supabase
          .from('attendance_records')
          .select('users(name, usn, email)')
          .eq('meeting_id', meetingId);

      String csv = "NAME,USN,EMAIL\n";
      for (var row in data) {
        csv += "${row['users']['name']},${row['users']['usn']},${row['users']['email']}\n";
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/attendance_$meetingId.csv');
      await file.writeAsString(csv);
      await Share.shareXFiles([XFile(file.path)], text: 'Meeting Attendance Data File');
    } catch (e) {
      showSnack("Export failure.", const Color(0xFFE74C3C), Icons.warning);
    }
  }

  InputDecoration premiumInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.white24, size: 18),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
      filled: true,
      fillColor: Colors.white.withOpacity(0.01),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.04), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kPrimaryTeal, width: 1.2),
      ),
    );
  }

  /// =========================
  /// DIALOG PRESENTATION SPEC
  /// =========================

  void showCreateDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.88,
                decoration: const BoxDecoration(
                  color: kBackgroundBg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(top: BorderSide(color: Colors.white10, width: 1)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Schedule Meeting",
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: Colors.white38, size: 20),
                          )
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white10, height: 16),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.only(left: 24, right: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 32),
                        children: [
                          const AlignmentHelper(child: Text("MEETING TITLE", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                          const SizedBox(height: 8),
                          TextField(
                            controller: titleController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: premiumInputDecoration("E.g., Quarterly Review Alignment", Icons.title),
                          ),
                          const SizedBox(height: 18),
                          const AlignmentHelper(child: Text("AGENDA SUMMARY", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                          const SizedBox(height: 8),
                          TextField(
                            controller: agendaController,
                            maxLines: 2,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: premiumInputDecoration("Key elements to dissect...", Icons.list_alt),
                          ),
                          const SizedBox(height: 18),
                          const AlignmentHelper(child: Text("DETAILED DESCRIPTION", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1))),
                          const SizedBox(height: 8),
                          TextField(
                            controller: descriptionController,
                            maxLines: 3,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: premiumInputDecoration("Context background metrics...", Icons.description_outlined),
                          ),
                          const SizedBox(height: 20),
                          InkWell(
                            onTap: () => pickDateTime(setDialogState),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.01),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white10, width: 1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.calendar_today_rounded, color: kPrimaryTeal, size: 18),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text("SCHEDULE BASE PROTOCOL TIME", style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 2),
                                      Text(
                                        selectedDateTime == null ? "Select Timeline Matrix" : selectedDateTime.toString().substring(0, 16),
                                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (isAdmin() || isServiceDirector()) ...[
                            SwitchListTile.adaptive(
                              value: allCommittees,
                              activeColor: kPrimaryTeal,
                              contentPadding: EdgeInsets.zero,
                              title: const Text("Broadcast to All Board Committees", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                              onChanged: (val) => setDialogState(() {
                                allCommittees = val;
                                if (val) selectedUsers = [];
                              }),
                            ),
                          ],
                          if (!allCommittees) ...[
                            const SizedBox(height: 12),
                            const AlignmentHelper(child: Text("TARGET AUDIENCE LAYERS", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold))),
                            const SizedBox(height: 10),
                            AlignmentHelper(
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                alignment: WrapAlignment.center,
                                children: (isAdmin() || isServiceDirector()
                                        ? committees
                                        : committees.where((c) => c['id'].toString() == widget.user['committee_id'].toString()).toList())
                                    .map((c) {
                                  final isSelected = selectedCommittees.contains(c['id']);
                                  return ChoiceChip(
                                    label: Text(c['name'].toString().toUpperCase(), style: const TextStyle(fontSize: 11)),
                                    selected: isSelected,
                                    selectedColor: kPrimaryTeal.withOpacity(0.3),
                                    backgroundColor: kSurfaceCard,
                                    labelStyle: TextStyle(color: isSelected ? kAccentTeal : Colors.white60, fontWeight: FontWeight.w600),
                                    onSelected: (selected) => setDialogState(() {
                                      selected ? selectedCommittees.add(c['id']) : selectedCommittees.remove(c['id']);
                                    }),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const AlignmentHelper(child: Text("PARTICIPANT SCOPE OVERRIDE", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold))),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: kSurfaceCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.02))),
                              child: AlignmentHelper(
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  alignment: WrapAlignment.center,
                                  children: users.map((u) {
                                    final isSelected = selectedUsers.contains(u['id']);
                                    return FilterChip(
                                      selected: isSelected,
                                      backgroundColor: kBackgroundBg,
                                      selectedColor: kPrimaryTeal.withOpacity(0.15),
                                      checkmarkColor: kAccentTeal,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(color: isSelected ? kPrimaryTeal.withOpacity(0.4) : Colors.white.withOpacity(0.05)),
                                      ),
                                      label: Text(u['name'].toString(), style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                      onSelected: (selected) => setDialogState(() {
                                        selected ? selectedUsers.add(u['id']) : selectedUsers.remove(u['id']);
                                      }),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 28),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryTeal,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: creatingMeeting ? null : createMeeting,
                            child: creatingMeeting
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text("SAVE STRUCTURAL MEETING", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showDetailPanel(Map<String, dynamic> meeting, bool approved, bool isCreator) {
    final bool isSessionOver = meeting['is_completed'] == true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setPanelState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
                decoration: const BoxDecoration(
                  color: kSurfaceCard,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            meeting['title'].toString().toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSessionOver 
                                ? Colors.white10 
                                : (approved ? kPrimaryTeal.withOpacity(0.1) : Colors.orange.withOpacity(0.1)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isSessionOver ? "COMPLETED" : (approved ? "APPROVED" : "PENDING"),
                            style: TextStyle(
                              color: isSessionOver ? Colors.white38 : (approved ? kAccentTeal : Colors.orange), 
                              fontSize: 10, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text("AGENDA CONTEXT", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(meeting['agenda'] ?? '', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 14)),
                    const SizedBox(height: 16),
                    const Text("SUMMARY PROTOCOL MATRIX DESCRIPTION", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(meeting['description'] ?? 'N/A', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.4)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time_rounded, color: Colors.white38, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          meeting['scheduled_at']?.toString().substring(0, 16) ?? '',
                          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    if (!approved && isAdmin()) ...[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryTeal,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          approveMeeting(meeting['id']);
                        },
                        child: const Text("EXECUTE MANAGEMENT APPROVAL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],

                    if (approved && (isCreator || isAdmin()) && !isSessionOver) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white70,
                                side: const BorderSide(color: Colors.white10),
                                minimumSize: const Size(0, 46),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => downloadAttendance(meeting['id']),
                              child: const Text("Export CSV", style: TextStyle(fontSize: 13)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (meeting['attendance_enabled'] == false)
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  minimumSize: const Size(0, 46),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  startAttendance(meeting['id']);
                                },
                                child: const Text("Start Roster", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ),
                          if (meeting['attendance_enabled'] == true)
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC0392B),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 46),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  terminateSession(meeting['id']);
                                },
                                child: const Text("End Session", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text("LIVE BROADCAST RUNTIME CODE", style: TextStyle(color: Colors.white24, fontSize: 9, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.02))),
                        child: Text(
                          meeting['attendance_enabled'] == true ? meeting['attendance_code']?.toString() ?? '------' : 'BROADCAST LINK OFFLINE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: meeting['attendance_enabled'] == true ? kAccentTeal : Colors.white24,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ],

                    if (approved && !isCreator && meeting['attendance_enabled'] == true && !isSessionOver) ...[
                      const Divider(color: Colors.white10, height: 24),
                      TextField(
                        controller: verifyCodeController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
                        decoration: premiumInputDecoration("Enter 7-Digit Telemetry Sync Token Code", Icons.pin),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccentTeal,
                          foregroundColor: Colors.black,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: markingAttendance ? null : () => verifyAndMarkAttendance(meeting),
                        child: markingAttendance
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                            : const Text("VERIFY SIGNATURE ACCESS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// =========================
  /// CORE FRAMEWORK STACK
  /// =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundBg,
      appBar: AppBar(
        backgroundColor: kBackgroundBg,
        elevation: 0,
        title: const AlignmentHelper(
          child: Text(
            "MEETINGS & SESSIONS",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.2),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Align(
            alignment: Alignment.center,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              dividerColor: Colors.transparent,
              indicatorColor: kPrimaryTeal,
              indicatorWeight: 2,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white30,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(text: "Active Operations"),
                Tab(text: "Pending Authorization"),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: canCreateMeeting()
          ? FloatingActionButton.extended(
              backgroundColor: kPrimaryTeal,
              foregroundColor: Colors.white,
              elevation: 2,
              icon: const Icon(Icons.add, size: 18),
              label: const Text("NEW MEETING", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              onPressed: showCreateDialog,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: loading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryTeal, strokeWidth: 2))
          : TabBarView(
              controller: _tabController,
              children: [
                buildMeetingList(true),
                buildMeetingList(false),
              ],
            ),
    );
  }

  Widget buildMeetingList(bool filterApproved) {
    final filtered = meetings.where((m) {
      final isApproved = m['approval_status'] == 'approved';
      return filterApproved ? isApproved : !isApproved;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          filterApproved ? "No active sessions logged." : "Clear verification queues.",
          style: const TextStyle(color: Colors.white24, fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final m = filtered[index];
        final approved = m['approval_status'] == 'approved';
        final isCreator = m['created_by'].toString() == widget.user['id'].toString();
        final isLive = m['attendance_enabled'] == true && m['is_completed'] != true;

        String dayStr = "??";
        String monthStr = "UNK";
        String timeStr = "00:00";
        try {
          DateTime dt = DateTime.parse(m['scheduled_at']);
          dayStr = dt.day.toString().padLeft(2, '0');
          const months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
          monthStr = months[dt.month - 1];
          String period = dt.hour >= 12 ? "PM" : "AM";
          int hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
          timeStr = "$hour:${dt.minute.toString().padLeft(2, '0')} $period";
        } catch (_) {}

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: kSurfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLive ? kPrimaryTeal.withOpacity(0.4) : Colors.white.withOpacity(0.03),
              width: isLive ? 1.2 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => showDetailPanel(m, approved, isCreator),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("$dayStr $monthStr", style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                      if (isLive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: kPrimaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: const Text("LIVE", style: TextStyle(color: kAccentTeal, fontSize: 8, fontWeight: FontWeight.bold)),
                        )
                      ],
                      if (m['is_completed'] == true) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(4)),
                          child: const Text("CLOSED", style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
                        )
                      ]
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    m['title'].toString().toUpperCase(),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    m['agenda'] ?? '',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.schedule, size: 12, color: Colors.white24),
                      const SizedBox(width: 4),
                      Text(timeStr, style: const TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.w500)),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class AlignmentHelper extends StatelessWidget {
  final Widget child;
  const AlignmentHelper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(alignment: Alignment.center, child: child);
  }
}