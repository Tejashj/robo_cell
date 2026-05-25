import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class MeetingsPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const MeetingsPage({
    super.key,
    required this.user,
  });

  @override
  State<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  List selectedCommittees = [];
  List selectedUsers = [];

  bool allCommittees = false;
  bool creatingMeeting = false;
  bool markingAttendance = false;

  DateTime? selectedDateTime;
  late TabController _tabController;

  final titleController = TextEditingController();
  final agendaController = TextEditingController();
  final descriptionController = TextEditingController();
  final verifyCodeController = TextEditingController();

  static const Color kPrimaryTeal = Color(0xFF148F77);
  static const Color kAccentTeal = Color(0xFF1ABC9C);
  static const Color kBackgroundBg = Color(0xFF09090A);
  static const Color kSurfaceCard = Color(0xFF121214);
  static const Color kSurfaceOverlay = Color(0xFF18181B);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).fetchMeetings(
        loadUsers: true,
        userCommitteeId: isAdmin() || isServiceDirector() ? null : widget.user['committee_id'],
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    titleController.dispose();
    agendaController.dispose();
    descriptionController.dispose();
    verifyCodeController.dispose();
    super.dispose();
  }

  bool isAdmin() {
    final role = widget.user['role'].toString().toLowerCase();
    return role == 'president' || role == 'secretary' || role == 'joint_secretary';
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

  Future<void> loadData() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.fetchMeetings(
      forceRefresh: true,
      loadUsers: true,
      userCommitteeId: isAdmin() || isServiceDirector() ? null : widget.user['committee_id'],
    );
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
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: kSurfaceOverlay,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(icon, color: accentColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  String generateCode() => List.generate(7, (_) => Random().nextInt(10)).join();

  Future<void> pickDateTime(StateSetter setDialogState) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setDialogState(() {
      selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

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
      final response = await supabase.from('meetings').insert({
        'title': title,
        'agenda': agenda,
        'description': description,
        'created_by': widget.user['id'],
        'approval_status': approvalStatus,
        'attendance_enabled': false,
        'attendance_code': generateCode(),
        'scheduled_at': selectedDateTime!.toIso8601String(),
        'is_completed': false,
      }).select().single();

      final provider = Provider.of<AppProvider>(context, listen: false);
      final meetingId = response['id'];
      final targetCommitteeIds = isCommitteeHead()
          ? [widget.user['committee_id']]
          : allCommittees ? provider.committees.map((c) => c['id']).toList() : selectedCommittees;

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
          finalUserIds.addAll(provider.users.map((u) => u['id']));
        } else if (targetCommitteeIds.isNotEmpty) {
          final targetedUsers = provider.users.where((u) => targetCommitteeIds.contains(u['committee_id']));
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
      clearFormFields();
      await loadData();
      showSnack("SESSION STRUCTURAL PROTOCOL LOGGED", kPrimaryTeal, Icons.done);
    } catch (e) {
      if (!mounted) return;
      setState(() => creatingMeeting = false);
      showSnack(e.toString(), const Color(0xFFE74C3C), Icons.error_outline);
    }
  }

  void clearFormFields() {
    titleController.clear();
    agendaController.clear();
    descriptionController.clear();
    selectedCommittees = [];
    selectedUsers = [];
    selectedDateTime = null;
    allCommittees = false;
    creatingMeeting = false;
  }

  Future<void> verifyAndMarkAttendance(Map<String, dynamic> meeting) async {
    final typedCode = verifyCodeController.text.trim();
    if (typedCode.isEmpty) return showSnack("Enter telemetry code matrix.", const Color(0xFFF39C12), Icons.dialpad);
    if (typedCode != meeting['attendance_code'].toString()) return showSnack("Code validation failed.", const Color(0xFFE74C3C), Icons.gpp_bad);

    setState(() => markingAttendance = true);
    try {
      final existing = await supabase.from('attendance_records').select().eq('meeting_id', meeting['id']).eq('user_id', widget.user['id']);
      if (existing.isNotEmpty) {
        verifyCodeController.clear();
        setState(() => markingAttendance = false);
        Navigator.pop(context);
        return showSnack("Signature verification verified.", kAccentTeal, Icons.verified_user);
      }

      await supabase.from('attendance_records').insert({'meeting_id': meeting['id'], 'user_id': widget.user['id']});
      verifyCodeController.clear();
      setState(() => markingAttendance = false);
      Navigator.pop(context);
      showSnack("ATTENDANCE SIGNATURE LOGGED", kPrimaryTeal, Icons.done);
    } catch (e) {
      setState(() => markingAttendance = false);
      showSnack(e.toString(), const Color(0xFFE74C3C), Icons.error_outline);
    }
  }

  Future<void> terminateSession(int id) async {
    try {
      await supabase.from('meetings').update({'attendance_enabled': false, 'is_completed': true}).eq('id', id);
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
      await supabase.from('meetings').update({'attendance_enabled': true, 'attendance_code': generateCode()}).eq('id', id);
      await loadData();
      showSnack("LIVE TELEMETRY BROADCAST ONLINE", kPrimaryTeal, Icons.sensors);
    } catch (e) {
      showSnack(e.toString(), const Color(0xFFE74C3C), Icons.error_outline);
    }
  }

  Future<void> downloadAttendance(int meetingId) async {
    try {
      final data = await supabase.from('attendance_records').select('users(name, usn, email)').eq('meeting_id', meetingId);
      String csv = "NAME,USN,EMAIL\n";
      for (var row in data) {
        csv += "${row['users']['name']},${row['users']['usn']},${row['users']['email']}\n";
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/attendance_$meetingId.csv');
      await file.writeAsString(csv);
      await Share.shareXFiles([XFile(file.path)], text: 'Meeting Attendance Sync');
    } catch (e) {
      showSnack("Export failure.", const Color(0xFFE74C3C), Icons.warning);
    }
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
                padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 32),
                decoration: const BoxDecoration(
                  color: kSurfaceCard,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            meeting['title'].toString().toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSessionOver ? Colors.white10 : (approved ? kPrimaryTeal.withOpacity(0.1) : Colors.orange.withOpacity(0.1)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isSessionOver ? "COMPLETED" : (approved ? "APPROVED" : "PENDING"),
                            style: TextStyle(color: isSessionOver ? Colors.white38 : (approved ? kAccentTeal : Colors.orange), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Align(alignment: Alignment.centerLeft, child: Text("AGENDA CONTEXT", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 4),
                    Align(alignment: Alignment.centerLeft, child: Text(meeting['agenda'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14))),
                    
                    if (!isSessionOver) ...[
                      const SizedBox(height: 16),
                      const Align(alignment: Alignment.centerLeft, child: Text("OPERATIONAL ANALYSIS METRICS DESCRIPTION", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold))),
                      const SizedBox(height: 4),
                      Align(alignment: Alignment.centerLeft, child: Text(meeting['description'] ?? 'N/A', style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.4))),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, color: Colors.white38, size: 16),
                        const SizedBox(width: 8),
                        Text(meeting['scheduled_at']?.toString().substring(0, 16) ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    if (!isSessionOver) ...[
                      if (!approved && isAdmin()) ...[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryTeal, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: () { Navigator.pop(context); approveMeeting(meeting['id']); },
                          child: const Text("EXECUTE MANAGEMENT APPROVAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                      if (approved && (isCreator || isAdmin())) ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.white70, side: const BorderSide(color: Colors.white10), minimumSize: const Size(0, 46), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                onPressed: () => downloadAttendance(meeting['id']),
                                child: const Text("Export CSV", style: TextStyle(fontSize: 13)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (meeting['attendance_enabled'] == false)
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, minimumSize: const Size(0, 46), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                  onPressed: () { Navigator.pop(context); startAttendance(meeting['id']); },
                                  child: const Text("Start Roster", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                              )
                            else
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC0392B), foregroundColor: Colors.white, minimumSize: const Size(0, 46), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                  onPressed: () { Navigator.pop(context); terminateSession(meeting['id']); },
                                  child: const Text("End Session", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            meeting['attendance_enabled'] == true ? meeting['attendance_code']?.toString() ?? '------' : 'BROADCAST LINK OFFLINE',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: meeting['attendance_enabled'] == true ? kAccentTeal : Colors.white24, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 4),
                          ),
                        ),
                      ],
                      if (approved && !isCreator && meeting['attendance_enabled'] == true) ...[
                        const Divider(color: Colors.white10, height: 24),
                        TextField(
                          controller: verifyCodeController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(filled: true, fillColor: Colors.black54, hintText: "Enter Sync Token", hintStyle: const TextStyle(color: Colors.white24)),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: kAccentTeal, foregroundColor: Colors.black, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          onPressed: markingAttendance ? null : () => verifyAndMarkAttendance(meeting),
                          child: const Text("VERIFY SIGNATURE ACCESS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
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

  void showCreateDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(color: kBackgroundBg, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(24),
                      children: [
                        TextField(controller: titleController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Meeting Title")),
                        const SizedBox(height: 14),
                        TextField(controller: agendaController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Agenda")),
                        const SizedBox(height: 14),
                        TextField(controller: descriptionController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Detailed Description")),
                        const SizedBox(height: 20),
                        ElevatedButton(onPressed: () => pickDateTime(setDialogState), child: Text(selectedDateTime == null ? "Pick Date & Time" : selectedDateTime.toString())),
                        const SizedBox(height: 24),
                        ElevatedButton(onPressed: createMeeting, child: const Text("SAVE STRUCTURAL MEETING")),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: const Color(0xFF16A085),
          unselectedItemColor: Colors.grey.shade600,
        ),
      ),
      child: Scaffold(
        backgroundColor: kBackgroundBg,
        appBar: AppBar(
          backgroundColor: kBackgroundBg,
          elevation: 0,
          title: const Text("MEETINGS & SESSIONS", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            indicatorColor: kPrimaryTeal,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white30,
            tabs: const [
              Tab(text: "Live Now"),
              Tab(text: "Scheduled"),
              Tab(text: "Ended"),
            ],
          ),
        ),
        floatingActionButton: canCreateMeeting()
            ? FloatingActionButton(backgroundColor: kPrimaryTeal, foregroundColor: Colors.white, onPressed: showCreateDialog, child: const Icon(Icons.add))
            : null,
        body: Consumer<AppProvider>(
          builder: (context, provider, child) {
            if (provider.isLoadingMeetings && provider.meetings.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: kPrimaryTeal, strokeWidth: 2));
            }
            return TabBarView(
              controller: _tabController,
              children: [
                buildMeetingList(ScopeType.live, provider.meetings),
                buildMeetingList(ScopeType.scheduled, provider.meetings),
                buildMeetingList(ScopeType.ended, provider.meetings),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildMeetingList(ScopeType type, List<Map<String, dynamic>> meetings) {
    final filtered = meetings.where((m) {
      final isApproved = m['approval_status'] == 'approved';
      final isLive = m['attendance_enabled'] == true && m['is_completed'] != true;
      final isCompleted = m['is_completed'] == true;

      if (type == ScopeType.live) return isLive && isApproved;
      if (type == ScopeType.scheduled) return !isLive && !isCompleted;
      return isCompleted;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text("NO MEETINGS LINED UP", style: TextStyle(color: Colors.white24, fontSize: 13)));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final m = filtered[index];
        final approved = m['approval_status'] == 'approved';
        final isCreator = m['created_by'].toString() == widget.user['id'].toString();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: kSurfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: type == ScopeType.live ? kPrimaryTeal.withOpacity(0.4) : Colors.white.withOpacity(0.02)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => showDetailPanel(m, approved, isCreator),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        m['title'].toString().toUpperCase(),
                        style: TextStyle(color: type == ScopeType.ended ? Colors.white60 : Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      if (type == ScopeType.live)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFE74C3C).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                          child: const Text("LIVE", style: TextStyle(color: Color(0xFFE74C3C), fontSize: 8, fontWeight: FontWeight.bold)),
                        )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    m['agenda'] ?? '',
                    style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12),
                  ),
                  if (type != ScopeType.ended) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 12, color: Colors.white24),
                        const SizedBox(width: 6),
                        Text(m['scheduled_at']?.toString().substring(0, 10) ?? '', style: const TextStyle(color: Colors.white24, fontSize: 11)),
                      ],
                    )
                  ]
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

enum ScopeType { live, scheduled, ended }