import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../theme/design_system.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/skeleton_loader.dart';

class MeetingsPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const MeetingsPage({super.key, required this.user});

  @override
  State<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage>
    with SingleTickerProviderStateMixin {
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).fetchMeetings(
        loadUsers: true,
        userCommitteeId: isAdmin() || isServiceDirector()
            ? null
            : widget.user['committee_id'],
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

  Future<void> loadData() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.fetchMeetings(
      forceRefresh: true,
      loadUsers: true,
      userCommitteeId: isAdmin() || isServiceDirector()
          ? null
          : widget.user['committee_id'],
    );
  }

  void showSnack(String text, Color accentColor, IconData icon) {
    HapticFeedback.lightImpact();
    AppSnackBar.show(
      context,
      message: text,
      type: accentColor == AppColors.error
          ? SnackBarType.error
          : (accentColor == AppColors.warning
                ? SnackBarType.warning
                : SnackBarType.info),
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
      selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> createMeeting() async {
    if (creatingMeeting) return;
    final title = titleController.text.trim();
    final agenda = agendaController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty ||
        agenda.isEmpty ||
        description.isEmpty ||
        selectedDateTime == null) {
      return showSnack(
        "All meeting details are required.",
        AppColors.warning,
        Icons.warning_amber_rounded,
      );
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

      if (!mounted) return;
      final provider = Provider.of<AppProvider>(context, listen: false);
      final meetingId = response['id'];
      final targetCommitteeIds = isCommitteeHead()
          ? [widget.user['committee_id']]
          : allCommittees
          ? provider.committees.map((c) => c['id']).toList()
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
          finalUserIds.addAll(provider.users.map((u) => u['id']));
        } else if (targetCommitteeIds.isNotEmpty) {
          final targetedUsers = provider.users.where(
            (u) => targetCommitteeIds.contains(u['committee_id']),
          );
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
      showSnack(
        "SESSION CREATED SUCCESSFULLY",
        AppColors.primaryCyan,
        Icons.done,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => creatingMeeting = false);
      showSnack(e.toString(), AppColors.error, Icons.error_outline);
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
    if (typedCode.isEmpty) {
      return showSnack(
        "Enter attendance code.",
        AppColors.warning,
        Icons.dialpad,
      );
    }
    if (typedCode != meeting['attendance_code'].toString()) {
      return showSnack("Invalid code.", AppColors.error, Icons.gpp_bad);
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
        if (mounted) Navigator.pop(context);
        return showSnack(
          "Already marked attendance.",
          AppColors.primaryCyan,
          Icons.verified_user,
        );
      }

      await supabase.from('attendance_records').insert({
        'meeting_id': meeting['id'],
        'user_id': widget.user['id'],
      });
      verifyCodeController.clear();
      setState(() => markingAttendance = false);
      if (mounted) Navigator.pop(context);
      showSnack(
        "ATTENDANCE MARKED SUCCESSFULLY",
        AppColors.success,
        Icons.done,
      );
    } catch (e) {
      setState(() => markingAttendance = false);
      showSnack(e.toString(), AppColors.error, Icons.error_outline);
    }
  }

  Future<void> terminateSession(int id) async {
    try {
      await supabase
          .from('meetings')
          .update({'attendance_enabled': false, 'is_completed': true})
          .eq('id', id);
      await loadData();
      showSnack("SESSION ENDED", AppColors.textMuted, Icons.lock_outline);
    } catch (e) {
      showSnack(e.toString(), AppColors.error, Icons.error_outline);
    }
  }

  Future<void> approveMeeting(int id) async {
    try {
      await supabase
          .from('meetings')
          .update({'approval_status': 'approved'})
          .eq('id', id);
      await loadData();
      showSnack(
        "MEETING APPROVED",
        AppColors.primaryCyan,
        Icons.verified_user_outlined,
      );
    } catch (e) {
      showSnack(e.toString(), AppColors.error, Icons.error_outline);
    }
  }

  Future<void> startAttendance(int id) async {
    try {
      await supabase
          .from('meetings')
          .update({
            'attendance_enabled': true,
            'attendance_code': generateCode(),
          })
          .eq('id', id);
      await loadData();
      showSnack("ATTENDANCE STARTED", AppColors.primaryCyan, Icons.sensors);
    } catch (e) {
      showSnack(e.toString(), AppColors.error, Icons.error_outline);
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
        csv +=
            "${row['users']['name']},${row['users']['usn']},${row['users']['email']}\n";
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/attendance_$meetingId.csv');
      await file.writeAsString(csv);
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Meeting Attendance CSV');
    } catch (e) {
      showSnack("Export failed.", AppColors.error, Icons.warning);
    }
  }

  void showDetailPanel(
    Map<String, dynamic> meeting,
    bool approved,
    bool isCreator,
  ) {
    final bool isSessionOver = meeting['is_completed'] == true;

    AppBottomSheet.show(
      context: context,
      title: meeting['title'].toString().toUpperCase(),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "STATUS",
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSessionOver
                        ? AppColors.surfaceElevated
                        : (approved
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.warning.withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    isSessionOver
                        ? "COMPLETED"
                        : (approved ? "APPROVED" : "PENDING"),
                    style: TextStyle(
                      color: isSessionOver
                          ? AppColors.textMuted
                          : (approved ? AppColors.success : AppColors.warning),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              "AGENDA",
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              meeting['agenda'] ?? '',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
            if (!isSessionOver) ...[
              const SizedBox(height: AppSpacing.lg),
              const Text(
                "DESCRIPTION",
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                meeting['description'] ?? 'N/A',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  color: AppColors.textMuted,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  meeting['scheduled_at']
                          ?.toString()
                          .substring(0, 16)
                          .replaceAll('T', ' • ') ??
                      '',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            if (!isSessionOver) ...[
              if (!approved && isAdmin()) ...[
                AppButton(
                  text: "APPROVE MEETING",
                  width: double.infinity,
                  onPressed: () {
                    Navigator.pop(ctx);
                    approveMeeting(meeting['id']);
                  },
                ),
              ],
              if (approved && (isCreator || isAdmin())) ...[
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: "Export CSV",
                        variant: AppButtonVariant.outlined,
                        onPressed: () => downloadAttendance(meeting['id']),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    if (meeting['attendance_enabled'] == false)
                      Expanded(
                        child: AppButton(
                          text: "Start Attendance",
                          onPressed: () {
                            Navigator.pop(ctx);
                            startAttendance(meeting['id']);
                          },
                        ),
                      )
                    else
                      Expanded(
                        child: AppButton(
                          text: "End Session",
                          variant: AppButtonVariant.secondary,
                          onPressed: () {
                            Navigator.pop(ctx);
                            terminateSession(meeting['id']);
                          },
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    meeting['attendance_enabled'] == true
                        ? meeting['attendance_code']?.toString() ?? '------'
                        : 'ATTENDANCE CLOSED',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: meeting['attendance_enabled'] == true
                          ? AppColors.primaryCyan
                          : AppColors.textMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ],
              if (approved &&
                  !isCreator &&
                  meeting['attendance_enabled'] == true) ...[
                const Divider(color: AppColors.borderSubtle, height: 24),
                TextField(
                  controller: verifyCodeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Enter Attendance Code",
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  text: "MARK ATTENDANCE",
                  width: double.infinity,
                  isLoading: markingAttendance,
                  onPressed: markingAttendance
                      ? null
                      : () => verifyAndMarkAttendance(meeting),
                ),
              ],
            ],
          ],
        );
      },
    );
  }

  void showCreateDialog() {
    AppBottomSheet.show(
      context: context,
      title: "CREATE NEW MEETING",
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: "Meeting Title",
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: agendaController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(labelText: "Agenda"),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    text: selectedDateTime == null
                        ? "Pick Date & Time"
                        : selectedDateTime.toString().substring(0, 16),
                    variant: AppButtonVariant.outlined,
                    icon: Icons.calendar_month_rounded,
                    width: double.infinity,
                    onPressed: () => pickDateTime(setDialogState),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    text: "CREATE MEETING",
                    width: double.infinity,
                    isLoading: creatingMeeting,
                    onPressed: creatingMeeting ? null : createMeeting,
                  ),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          "MEETINGS & SESSIONS",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          dividerColor: AppColors.borderSubtle,
          indicatorColor: AppColors.primaryCyan,
          labelColor: AppColors.primaryCyan,
          unselectedLabelColor: AppColors.textMuted,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: "Live Now"),
            Tab(text: "Scheduled"),
            Tab(text: "Ended"),
          ],
        ),
      ),
      floatingActionButton: canCreateMeeting()
          ? FloatingActionButton(
              backgroundColor: AppColors.primaryCyan,
              foregroundColor: Colors.black,
              onPressed: showCreateDialog,
              child: const Icon(Icons.add_rounded),
            )
          : null,
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingMeetings && provider.meetings.isEmpty) {
            return _buildMeetingsSkeleton();
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
    );
  }

  Widget buildMeetingList(ScopeType type, List<Map<String, dynamic>> meetings) {
    final filtered = meetings.where((m) {
      final isApproved = m['approval_status'] == 'approved';
      final isLive =
          m['attendance_enabled'] == true && m['is_completed'] != true;
      final isCompleted = m['is_completed'] == true;

      if (type == ScopeType.live) return isLive && isApproved;
      if (type == ScopeType.scheduled) return !isLive && !isCompleted;
      return isCompleted;
    }).toList();

    if (filtered.isEmpty) {
      return const AppEmptyState(
        status: AppStateStatus.empty,
        title: "No Meetings Found",
        description: "There are currently no meetings scheduled in this tab.",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        96,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final m = filtered[index];
        final approved = m['approval_status'] == 'approved';
        final isCreator =
            m['created_by'].toString() == widget.user['id'].toString();

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: AppCard(
            onTap: () => showDetailPanel(m, approved, isCreator),
            border: Border.all(
              color: type == ScopeType.live
                  ? AppColors.primaryCyan.withValues(alpha: 0.4)
                  : AppColors.borderSubtle,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        m['title'].toString().toUpperCase(),
                        style: TextStyle(
                          color: type == ScopeType.ended
                              ? AppColors.textMuted
                              : AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (type == ScopeType.live)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Text(
                          "LIVE",
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  m['agenda'] ?? '',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                if (type != ScopeType.ended) ...[
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        m['scheduled_at']?.toString().substring(0, 10) ?? '',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMeetingsSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 4,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 140, height: 20),
                    SkeletonBox(width: 60, height: 20, borderRadius: 6),
                  ],
                ),
                SizedBox(height: 14),
                SkeletonBox(width: double.infinity, height: 14),
                SizedBox(height: 8),
                SkeletonBox(width: 200, height: 14),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum ScopeType { live, scheduled, ended }
