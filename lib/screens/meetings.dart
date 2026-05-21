import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetingsPage extends StatefulWidget {

  final Map<String, dynamic> user;

  const MeetingsPage({
    super.key,
    required this.user,
  });

  @override
  State<MeetingsPage> createState() =>
      _MeetingsPageState();
}

class _MeetingsPageState
    extends State<MeetingsPage> {

  final supabase =
      Supabase.instance.client;

  bool loading = true;

  bool creating = false;

  List<Map<String, dynamic>>
      meetings = [];

  List<Map<String, dynamic>>
      users = [];

  List<Map<String, dynamic>>
      committees = [];

  final titleController =
      TextEditingController();

  final agendaController =
      TextEditingController();

  final linkController =
      TextEditingController();

  DateTime? selectedDate;

  TimeOfDay? selectedTime;

  Map<String, dynamic>?
      selectedCommittee;

  List<int> selectedUsers = [];

  @override
  void initState() {

    super.initState();

    initialize();
  }

  Future<void> initialize() async {

    await loadCommittees();

    await loadUsers();

    await loadMeetings();

    setState(() {
      loading = false;
    });
  }

  bool canCreateMeeting() {

    final role =
        widget.user['role'];

    return role ==
            'president' ||

        role ==
            'vice_president' ||

        role ==
            'secretary' ||

        role ==
            'treasurer' ||

        role ==
            'head' ||

        role ==
            'co_head';
  }

  bool isOfficeBearer() {

    final role =
        widget.user['role'];

    return role ==
            'president' ||

        role ==
            'vice_president' ||

        role ==
            'secretary' ||

        role ==
            'treasurer';
  }

  Future<void> loadCommittees() async {

    final data =
        await supabase

            .from('committees')

            .select()

            .order('name');

    committees =
        List<Map<String, dynamic>>
            .from(data);
  }

  Future<void> loadUsers() async {

    final data =
        await supabase

            .from('users')

            .select('''
              *,
              committees(name)
            ''')

            .order('name');

    users =
        List<Map<String, dynamic>>
            .from(data);
  }

  Future<void> loadMeetings() async {

    final userId =
        widget.user['id'];

    final committeeId =
        widget.user['committee_id'];

    final role =
        widget.user['role'];

    List data = [];

    if (isOfficeBearer()) {

      data = await supabase

          .from('meetings')

          .select('''
            *,
            committees(name)
          ''')

          .order(
            'scheduled_at',
            ascending: true,
          );

    } else {

      final attendeeData =
          await supabase

              .from(
                'meeting_attendees',
              )

              .select(
                'meeting_id',
              )

              .eq(
                'user_id',
                userId,
              );

      final ids =
          attendeeData
              .map(
                (e) =>
                    e['meeting_id'],
              )
              .toList();

      data = await supabase

          .from('meetings')

          .select('''
            *,
            committees(name)
          ''')

          .or(
            'committee_id.eq.$committeeId,id.in.(${ids.join(',')})',
          )

          .order(
            'scheduled_at',
            ascending: true,
          );
    }

    meetings =
        List<Map<String, dynamic>>
            .from(data);
  }

  Future<void> pickDateTime() async {

    final pickedDate =
        await showDatePicker(

      context: context,

      firstDate: DateTime.now(),

      lastDate:
          DateTime.now().add(
        const Duration(days: 365),
      ),

      initialDate:
          DateTime.now(),
    );

    if (pickedDate == null) {
      return;
    }

    final pickedTime =
        await showTimePicker(

      context: context,

      initialTime:
          TimeOfDay.now(),
    );

    if (pickedTime == null) {
      return;
    }

    setState(() {

      selectedDate = pickedDate;

      selectedTime = pickedTime;
    });
  }

  Future<void> createMeeting() async {

    if (titleController.text
            .trim()
            .isEmpty ||

        agendaController.text
            .trim()
            .isEmpty ||

        selectedCommittee ==
            null ||

        selectedDate ==
            null ||

        selectedTime ==
            null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
              Text("Fill all fields"),
        ),
      );

      return;
    }

    setState(() {
      creating = true;
    });

    try {

      final meetingDate =
          DateTime(

        selectedDate!.year,

        selectedDate!.month,

        selectedDate!.day,

        selectedTime!.hour,

        selectedTime!.minute,
      );

      final inserted =
          await supabase

              .from('meetings')

              .insert({

            'creator_id':
                widget.user['id'],

            'committee_id':
                selectedCommittee![
                    'id'],

            'title':
                titleController.text
                    .trim(),

            'agenda':
                agendaController.text
                    .trim(),

            'meeting_link':
                linkController.text
                        .trim()
                        .isEmpty

                    ? null

                    : linkController
                        .text
                        .trim(),

            'scheduled_at':
                meetingDate
                    .toIso8601String(),
          })

              .select()

              .single();

      final meetingId =
          inserted['id'];

      for (final userId
          in selectedUsers) {

        await supabase

            .from(
              'meeting_attendees',
            )

            .insert({

          'meeting_id':
              meetingId,

          'user_id': userId,
        });
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
              Text("Meeting Created"),
        ),
      );

      titleController.clear();

      agendaController.clear();

      linkController.clear();

      selectedUsers.clear();

      selectedCommittee =
          null;

      selectedDate = null;

      selectedTime = null;

      await loadMeetings();

      setState(() {});

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content:
              Text(e.toString()),
        ),
      );
    }

    setState(() {
      creating = false;
    });
  }

  Widget input({

    required String hint,

    required TextEditingController
        controller,

    int maxLines = 1,
  }) {

    return TextField(

      controller: controller,

      maxLines: maxLines,

      style:
          const TextStyle(
        color: Colors.white,
      ),

      decoration:
          InputDecoration(

        hintText: hint,

        hintStyle:
            const TextStyle(
          color: Colors.grey,
        ),

        filled: true,

        fillColor:
            Colors.white
                .withOpacity(0.03),

        border:
            OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(
            16,
          ),

          borderSide:
              BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.black,

      body:
          loading

              ? const Center(

                  child:
                      CircularProgressIndicator(
                    color:
                        Color(
                      0xFF16A085,
                    ),
                  ),
                )

              : SingleChildScrollView(

                  padding:
                      const EdgeInsets.all(
                    18,
                  ),

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      /// CREATE SECTION
                      if (canCreateMeeting())

                        Container(

                          padding:
                              const EdgeInsets.all(
                            18,
                          ),

                          decoration:
                              BoxDecoration(

                            color: Colors
                                .white
                                .withOpacity(
                              0.03,
                            ),

                            borderRadius:
                                BorderRadius.circular(
                              22,
                            ),

                            border: Border.all(
                              color:
                                  Colors.white10,
                            ),
                          ),

                          child: Column(

                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              const Text(

                                "CREATE MEETING",

                                style:
                                    TextStyle(

                                  color:
                                      Color(
                                    0xFFD8CFB4,
                                  ),

                                  fontSize:
                                      16,

                                  fontWeight:
                                      FontWeight.bold,

                                  letterSpacing:
                                      1,
                                ),
                              ),

                              const SizedBox(
                                height: 20,
                              ),

                              input(

                                hint:
                                    "Meeting Title",

                                controller:
                                    titleController,
                              ),

                              const SizedBox(
                                height: 14,
                              ),

                              input(

                                hint:
                                    "Agenda",

                                controller:
                                    agendaController,

                                maxLines: 4,
                              ),

                              const SizedBox(
                                height: 14,
                              ),

                              input(

                                hint:
                                    "Meeting Link (Optional)",

                                controller:
                                    linkController,
                              ),

                              const SizedBox(
                                height: 14,
                              ),

                              DropdownButtonFormField<
                                  Map<String, dynamic>>(

                                value:
                                    selectedCommittee,

                                dropdownColor:
                                    Colors.grey
                                        .shade900,

                                decoration:
                                    InputDecoration(

                                  filled: true,

                                  fillColor:
                                      Colors.white
                                          .withOpacity(
                                    0.03,
                                  ),

                                  border:
                                      OutlineInputBorder(

                                    borderRadius:
                                        BorderRadius.circular(
                                      16,
                                    ),

                                    borderSide:
                                        BorderSide.none,
                                  ),
                                ),

                                items:
                                    committees
                                        .map((c) {

                                  return DropdownMenuItem(

                                    value: c,

                                    child: Text(

                                      c['name'],

                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.white,
                                      ),
                                    ),
                                  );
                                }).toList(),

                                onChanged: (v) {

                                  setState(() {

                                    selectedCommittee =
                                        v;
                                  });
                                },
                              ),

                              const SizedBox(
                                height: 14,
                              ),

                              GestureDetector(

                                onTap:
                                    pickDateTime,

                                child:
                                    Container(

                                  width:
                                      double.infinity,

                                  padding:
                                      const EdgeInsets.all(
                                    16,
                                  ),

                                  decoration:
                                      BoxDecoration(

                                    color:
                                        Colors.white
                                            .withOpacity(
                                      0.03,
                                    ),

                                    borderRadius:
                                        BorderRadius.circular(
                                      16,
                                    ),
                                  ),

                                  child: Text(

                                    selectedDate ==
                                            null

                                        ? "Select Date & Time"

                                        : "${selectedDate.toString().substring(0, 10)} • ${selectedTime!.format(context)}",

                                    style:
                                        TextStyle(

                                      color:
                                          selectedDate ==
                                                  null

                                              ? Colors
                                                  .grey

                                              : Colors
                                                  .white,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 18,
                              ),

                              const Text(

                                "ASSIGN MEMBERS",

                                style:
                                    TextStyle(

                                  color:
                                      Color(
                                    0xFFD8CFB4,
                                  ),

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(
                                height: 12,
                              ),

                              SizedBox(

                                height: 220,

                                child:
                                    ListView.builder(

                                  itemCount:
                                      users.length,

                                  itemBuilder:
                                      (context,
                                          index) {

                                    final user =
                                        users[
                                            index];

                                    final selected =
                                        selectedUsers
                                            .contains(
                                      user['id'],
                                    );

                                    return CheckboxListTile(

                                      value:
                                          selected,

                                      activeColor:
                                          const Color(
                                        0xFF16A085,
                                      ),

                                      title:
                                          Text(

                                        user[
                                            'name'],

                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white,
                                        ),
                                      ),

                                      subtitle:
                                          Text(

                                        user[
                                            'usn'],

                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.grey,
                                        ),
                                      ),

                                      onChanged:
                                          (v) {

                                        setState(() {

                                          if (selected) {

                                            selectedUsers
                                                .remove(
                                              user[
                                                  'id'],
                                            );

                                          } else {

                                            selectedUsers
                                                .add(
                                              user[
                                                  'id'],
                                            );
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(
                                height: 18,
                              ),

                              SizedBox(

                                width:
                                    double.infinity,

                                height: 52,

                                child:
                                    ElevatedButton(

                                  style:
                                      ElevatedButton.styleFrom(

                                    backgroundColor:
                                        const Color(
                                      0xFF16A085,
                                    ),
                                  ),

                                  onPressed:
                                      creating

                                          ? null

                                          : createMeeting,

                                  child:
                                      creating

                                          ? const CircularProgressIndicator(
                                              color:
                                                  Colors.black,
                                            )

                                          : const Text(

                                              "CREATE MEETING",

                                              style:
                                                  TextStyle(

                                                color:
                                                    Colors.black,

                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(
                        height: 28,
                      ),

                      const Text(

                        "UPCOMING MEETINGS",

                        style:
                            TextStyle(

                          color:
                              Color(
                            0xFFD8CFB4,
                          ),

                          fontWeight:
                              FontWeight.bold,

                          fontSize: 16,

                          letterSpacing:
                              1,
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      if (meetings.isEmpty)

                        const Center(

                          child: Padding(

                            padding:
                                EdgeInsets.only(
                              top: 80,
                            ),

                            child: Text(

                              "No Meetings Available",

                              style:
                                  TextStyle(
                                color:
                                    Colors.grey,
                              ),
                            ),
                          ),
                        ),

                      ...meetings.map((m) {

                        final committee =
                            m['committees']
                                    ?['name'] ??
                                '';

                        return Container(

                          margin:
                              const EdgeInsets.only(
                            bottom: 16,
                          ),

                          padding:
                              const EdgeInsets.all(
                            18,
                          ),

                          decoration:
                              BoxDecoration(

                            color: Colors
                                .white
                                .withOpacity(
                              0.03,
                            ),

                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),

                            border: Border.all(
                              color:
                                  Colors.white10,
                            ),
                          ),

                          child: Column(

                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              Row(

                                children: [

                                  Expanded(

                                    child:
                                        Text(

                                      m['title'],

                                      style:
                                          const TextStyle(

                                        color:
                                            Color(
                                          0xFFD8CFB4,
                                        ),

                                        fontSize:
                                            18,

                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  Container(

                                    padding:
                                        const EdgeInsets.symmetric(

                                      horizontal:
                                          10,

                                      vertical:
                                          6,
                                    ),

                                    decoration:
                                        BoxDecoration(

                                      color:
                                          const Color(
                                        0xFF16A085,
                                      ).withOpacity(
                                        0.15,
                                      ),

                                      borderRadius:
                                          BorderRadius.circular(
                                        12,
                                      ),
                                    ),

                                    child:
                                        Text(

                                      committee,

                                      style:
                                          const TextStyle(

                                        color:
                                            Color(
                                          0xFF16A085,
                                        ),

                                        fontSize:
                                            10,

                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: 12,
                              ),

                              Text(

                                m['agenda'],

                                style:
                                    const TextStyle(

                                  color:
                                      Colors.white70,

                                  height:
                                      1.5,
                                ),
                              ),

                              const SizedBox(
                                height: 16,
                              ),

                              Row(

                                children: [

                                  const Icon(

                                    Icons
                                        .calendar_month_rounded,

                                    color:
                                        Color(
                                      0xFF16A085,
                                    ),

                                    size: 18,
                                  ),

                                  const SizedBox(
                                    width: 8,
                                  ),

                                  Text(

                                    m['scheduled_at']
                                        .toString()
                                        .substring(
                                          0,
                                          16,
                                        )
                                        .replaceAll(
                                          'T',
                                          ' • ',
                                        ),

                                    style:
                                        const TextStyle(

                                      color:
                                          Colors.white,
                                    ),
                                  ),
                                ],
                              ),

                              if (m['meeting_link'] !=
                                      null &&
                                  m['meeting_link'] !=
                                      '')

                                Padding(

                                  padding:
                                      const EdgeInsets.only(
                                    top: 18,
                                  ),

                                  child:
                                      SizedBox(

                                    width:
                                        double.infinity,

                                    height:
                                        48,

                                    child:
                                        ElevatedButton.icon(

                                      style:
                                          ElevatedButton.styleFrom(

                                        backgroundColor:
                                            const Color(
                                          0xFF16A085,
                                        ),
                                      ),

                                      onPressed:
                                          () async {

                                        final url =
                                            Uri.parse(
                                          m['meeting_link'],
                                        );

                                        await launchUrl(
                                          url,
                                        );
                                      },

                                      icon:
                                          const Icon(

                                        Icons
                                            .video_call_rounded,

                                        color:
                                            Colors.black,
                                      ),

                                      label:
                                          const Text(

                                        "JOIN MEETING",

                                        style:
                                            TextStyle(

                                          color:
                                              Colors.black,

                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}