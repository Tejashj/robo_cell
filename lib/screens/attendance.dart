import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceQRPage extends StatefulWidget {

  final Map<String, dynamic> user;

  final Map<String, dynamic> meeting;

  const AttendanceQRPage({

    super.key,

    required this.user,

    required this.meeting,
  });

  @override
  State<AttendanceQRPage> createState() =>
      _AttendanceQRPageState();
}

class _AttendanceQRPageState
    extends State<AttendanceQRPage> {

  final supabase =
      Supabase.instance.client;

  bool loading = true;

  String attendanceCode = '';

  String qrToken = '';

  int attendanceCount = 0;

  Timer? timer;

  Duration remaining =
      const Duration(minutes: 10);

  int? sessionId;

  @override
  void initState() {

    super.initState();

    initialize();
  }

  Future<void> initialize() async {

    await createSession();

    startTimer();

    await loadAttendanceCount();

    setState(() {
      loading = false;
    });
  }

  Future<void> createSession() async {

    final random =
        Random();

    attendanceCode =
        (1000000 +
                random.nextInt(
                  8999999,
                ))
            .toString();

    qrToken =
        DateTime.now()
            .millisecondsSinceEpoch
            .toString();

    final expiry =
        DateTime.now().add(
      const Duration(
        minutes: 10,
      ),
    );

    final inserted =
        await supabase

            .from(
              'attendance_sessions',
            )

            .insert({

          'meeting_id':
              widget.meeting['id'],

          'created_by':
              widget.user['id'],

          'attendance_code':
              attendanceCode,

          'qr_token':
              qrToken,

          'expires_at':
              expiry.toIso8601String(),
        })

            .select()

            .single();

    sessionId =
        inserted['id'];
  }

  void startTimer() {

    timer = Timer.periodic(

      const Duration(seconds: 1),

      (t) {

        if (remaining.inSeconds <= 0) {

          t.cancel();

          Navigator.pop(context);

          return;
        }

        setState(() {

          remaining = Duration(

            seconds:
                remaining.inSeconds -
                    1,
          );
        });

        loadAttendanceCount();
      },
    );
  }

  Future<void> loadAttendanceCount()
  async {

    if (sessionId == null) {
      return;
    }

    final data =
        await supabase

            .from(
              'attendance_records',
            )

            .select()

            .eq(
              'attendance_session_id',
              sessionId!,
            );

    setState(() {

      attendanceCount =
          data.length;
    });
  }

  @override
  void dispose() {

    timer?.cancel();

    super.dispose();
  }

  Widget statCard({

    required String title,

    required String value,
  }) {

    return Expanded(

      child: Container(

        padding:
            const EdgeInsets.all(
          18,
        ),

        decoration:
            BoxDecoration(

          color:
              Colors.white
                  .withOpacity(
            0.04,
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

          children: [

            Text(

              value,

              style:
                  const TextStyle(

                color:
                    Color(
                  0xFF16A085,
                ),

                fontSize: 24,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(

              title,

              style:
                  const TextStyle(

                color:
                    Colors.grey,

                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.black,

      appBar: AppBar(

        backgroundColor:
            Colors.black,

        title:
            const Text(
          "ATTENDANCE SESSION",
        ),
      ),

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
                    20,
                  ),

                  child: Column(

                    children: [

                      Text(

                        widget.meeting[
                            'title'],

                        textAlign:
                            TextAlign.center,

                        style:
                            const TextStyle(

                          color:
                              Color(
                            0xFFD8CFB4,
                          ),

                          fontSize: 24,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Text(

                        "Secure Attendance Portal",

                        style:
                            TextStyle(

                          color:
                              Colors.grey.shade400,

                          letterSpacing:
                              1,
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      Container(

                        padding:
                            const EdgeInsets.all(
                          25,
                        ),

                        decoration:
                            BoxDecoration(

                          color:
                              Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                            28,
                          ),

                          boxShadow: [

                            BoxShadow(

                              color:
                                  const Color(
                                0xFF16A085,
                              ).withOpacity(
                                0.35,
                              ),

                              blurRadius:
                                  30,
                            ),
                          ],
                        ),

                        child:
                            QrImageView(

                          data:
                              '''
{
"session":"$qrToken",
"meeting":"${widget.meeting['id']}"
}
''',

                          size: 260,
                        ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      Container(

                        width:
                            double.infinity,

                        padding:
                            const EdgeInsets.symmetric(

                          vertical: 22,
                        ),

                        decoration:
                            BoxDecoration(

                          color:
                              Colors.white
                                  .withOpacity(
                            0.04,
                          ),

                          borderRadius:
                              BorderRadius.circular(
                            24,
                          ),

                          border: Border.all(
                            color:
                                const Color(
                              0xFF16A085,
                            ).withOpacity(
                              0.3,
                            ),
                          ),
                        ),

                        child: Column(

                          children: [

                            const Text(

                              "ATTENDANCE CODE",

                              style:
                                  TextStyle(

                                color:
                                    Colors.grey,

                                letterSpacing:
                                    1.5,

                                fontSize: 11,
                              ),
                            ),

                            const SizedBox(
                              height: 14,
                            ),

                            Text(

                              attendanceCode,

                              style:
                                  const TextStyle(

                                color:
                                    Color(
                                  0xFF16A085,
                                ),

                                fontSize: 42,

                                fontWeight:
                                    FontWeight.bold,

                                letterSpacing:
                                    6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      Row(

                        children: [

                          statCard(

                            title:
                                "PRESENT",

                            value:
                                attendanceCount
                                    .toString(),
                          ),

                          const SizedBox(
                            width: 14,
                          ),

                          statCard(

                            title:
                                "TIME LEFT",

                            value:
                                "${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}",
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      Container(

                        padding:
                            const EdgeInsets.all(
                          18,
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
                            20,
                          ),

                          border: Border.all(
                            color:
                                Colors.white10,
                          ),
                        ),

                        child: const Row(

                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Icon(

                              Icons.security,

                              color:
                                  Color(
                                0xFF16A085,
                              ),
                            ),

                            SizedBox(
                              width: 12,
                            ),

                            Expanded(

                              child: Text(

                                "Attendance session expires automatically after 10 minutes.",

                                style:
                                    TextStyle(

                                  color:
                                      Colors.white70,

                                  height:
                                      1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 60,
                      ),
                    ],
                  ),
                ),
    );
  }
}