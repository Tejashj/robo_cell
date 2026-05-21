import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScanAttendancePage extends StatefulWidget {

  final Map<String, dynamic> user;

  const ScanAttendancePage({
    super.key,
    required this.user,
  });

  @override
  State<ScanAttendancePage> createState() =>
      _ScanAttendancePageState();
}

class _ScanAttendancePageState
    extends State<ScanAttendancePage> {

  final supabase =
      Supabase.instance.client;

  final codeController =
      TextEditingController();

  bool loading = false;

  bool scanned = false;

  /// PROCESS QR
  Future<void> processQR(
    String raw,
  ) async {

    if (scanned) return;

    scanned = true;

    try {

      final token =
          raw
              .split('"session":"')[1]
              .split('"')[0];

      final session =
          await supabase

              .from(
                'attendance_sessions',
              )

              .select()

              .eq(
                'qr_token',
                token,
              )

              .single();

      await markAttendance(
        session,
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
              Text("Invalid QR"),
        ),
      );

      scanned = false;
    }
  }

  /// PROCESS MANUAL CODE
  Future<void> processCode() async {

    if (codeController.text
        .trim()
        .isEmpty) {

      return;
    }

    setState(() {
      loading = true;
    });

    try {

      final session =
          await supabase

              .from(
                'attendance_sessions',
              )

              .select()

              .eq(
                'attendance_code',
                codeController.text
                    .trim(),
              )

              .single();

      await markAttendance(
        session,
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
              Text("Invalid Code"),
        ),
      );
    }

    setState(() {
      loading = false;
    });
  }

  /// MARK ATTENDANCE
  Future<void> markAttendance(
    Map<String, dynamic>
        session,
  ) async {

    try {

      final expiry =
          DateTime.parse(
        session['expires_at'],
      );

      if (DateTime.now()
          .isAfter(expiry)) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content:
                Text(
              "Attendance Expired",
            ),
          ),
        );

        scanned = false;

        return;
      }

      /// CHECK DUPLICATE
      final existing =
          await supabase

              .from(
                'attendance_records',
              )

              .select()

              .eq(
                'attendance_session_id',
                session['id'],
              )

              .eq(
                'user_id',
                widget.user['id'],
              );

      if (existing.isNotEmpty) {

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(
            content:
                Text(
              "Attendance Already Marked",
            ),
          ),
        );

        scanned = false;

        return;
      }

      /// INSERT
      await supabase

          .from(
            'attendance_records',
          )

          .insert({

        'attendance_session_id':
            session['id'],

        'user_id':
            widget.user['id'],
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
              Text(
            "Attendance Marked Successfully",
          ),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content:
              Text(e.toString()),
        ),
      );

      scanned = false;
    }
  }

  Widget sectionTitle(
    String title,
  ) {

    return Padding(

      padding:
          const EdgeInsets.only(
        bottom: 14,
      ),

      child: Row(

        children: [

          Container(

            width: 4,

            height: 18,

            decoration:
                BoxDecoration(

              color:
                  const Color(
                0xFF16A085,
              ),

              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Text(

            title,

            style:
                const TextStyle(

              color:
                  Color(
                0xFFD8CFB4,
              ),

              fontWeight:
                  FontWeight.bold,

              letterSpacing:
                  1,
            ),
          ),
        ],
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
          "SCAN ATTENDANCE",
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(
          18,
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [

            sectionTitle(
              "SCAN QR CODE",
            ),

            Container(

              height: 320,

              decoration:
                  BoxDecoration(

                borderRadius:
                    BorderRadius.circular(
                  24,
                ),

                border: Border.all(
                  color:
                      Colors.white10,
                ),
              ),

              child: ClipRRect(

                borderRadius:
                    BorderRadius.circular(
                  24,
                ),

                child: MobileScanner(

                  onDetect:
                      (capture) {

                    final barcode =
                        capture
                            .barcodes
                            .first;

                    final raw =
                        barcode.rawValue;

                    if (raw != null) {

                      processQR(raw);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            sectionTitle(
              "ENTER CODE MANUALLY",
            ),

            TextField(

              controller:
                  codeController,

              style:
                  const TextStyle(
                color: Colors.white,
              ),

              keyboardType:
                  TextInputType.number,

              decoration:
                  InputDecoration(

                hintText:
                    "7 Digit Attendance Code",

                hintStyle:
                    const TextStyle(
                  color: Colors.grey,
                ),

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
                    18,
                  ),

                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(
              height: 20,
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
                    loading
                        ? null
                        : processCode,

                child:
                    loading

                        ? const CircularProgressIndicator(
                            color:
                                Colors.black,
                          )

                        : const Text(

                            "MARK ATTENDANCE",

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

            const SizedBox(
              height: 35,
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
                    CrossAxisAlignment
                        .start,

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

                      "Each attendance session is encrypted, time-limited, and duplicate protected.",

                      style:
                          TextStyle(

                        color:
                            Colors.white70,

                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}