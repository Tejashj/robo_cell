import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login.dart';

class ProfilePage extends StatefulWidget {

  final Map<String, dynamic> user;

  const ProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState
    extends State<ProfilePage> {

  late Map<String, dynamic>
      currentUser;

  bool savingLinkedin = false;

  final linkedinController =
      TextEditingController();

  @override
  void initState() {

    super.initState();

    currentUser = widget.user;

    linkedinController.text =
        currentUser['linkedin'] ?? '';
  }

  Future<void> saveLinkedin()
  async {

    if (linkedinController.text
        .trim()
        .isEmpty) {

      return;
    }

    setState(() {
      savingLinkedin = true;
    });

    try {

      await Supabase
          .instance
          .client
          .from('users')
          .update({

        'linkedin':
            linkedinController.text
                .trim(),

        'linkedin_locked':
            true,
      })
          .eq(
            'id',
            currentUser['id'],
          );

      currentUser['linkedin'] =
          linkedinController.text
              .trim();

      currentUser[
          'linkedin_locked'] = true;

      setState(() {});

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
              Text(
            "LinkedIn Saved Successfully",
          ),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content:
              Text(
            e.toString(),
          ),
        ),
      );
    }

    setState(() {
      savingLinkedin = false;
    });
  }

  Widget infoCard({

    required IconData icon,

    required String title,

    required String value,
  }) {

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

        color:
            Colors.white
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

      child: Row(

        children: [

          Container(

            padding:
                const EdgeInsets.all(
              12,
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
                14,
              ),
            ),

            child: Icon(

              icon,

              color:
                  const Color(
                0xFF16A085,
              ),
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(

                  title,

                  style:
                      const TextStyle(

                    color:
                        Colors.grey,

                    fontSize: 11,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(

                  value,

                  style:
                      const TextStyle(

                    color:
                        Color(
                      0xFFD8CFB4,
                    ),

                    fontWeight:
                        FontWeight.bold,

                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final photo =
        currentUser['photo_url'];

    final linkedinLocked =
        currentUser[
                'linkedin_locked'] ==
            true;

    return Scaffold(

      backgroundColor:
          Colors.black,

      appBar: AppBar(

        backgroundColor:
            Colors.black,

        title:
            const Text(
          "PROFILE",
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(

          children: [

            /// TOP PROFILE CARD
            Container(

              width:
                  double.infinity,

              padding:
                  const EdgeInsets.all(
                24,
              ),

              decoration:
                  BoxDecoration(

                gradient:
                    LinearGradient(

                  colors: [

                    const Color(
                      0xFF16A085,
                    ).withOpacity(
                      0.25,
                    ),

                    Colors.white
                        .withOpacity(
                      0.03,
                    ),
                  ],
                ),

                borderRadius:
                    BorderRadius.circular(
                  30,
                ),
              ),

              child: Column(

                children: [

                  CircleAvatar(

                    radius: 60,

                    backgroundColor:
                        const Color(
                      0xFF16A085,
                    ),

                    child: CircleAvatar(

                      radius: 56,

                      backgroundColor:
                          Colors.black,

                      backgroundImage:

                          photo != null &&
                                  photo
                                      .toString()
                                      .isNotEmpty

                              ? NetworkImage(
                                  photo,
                                )

                              : null,

                      child:
                          photo == null ||
                                  photo
                                      .toString()
                                      .isEmpty

                              ? const Icon(

                                  Icons.person,

                                  size: 55,

                                  color:
                                      Color(
                                    0xFF16A085,
                                  ),
                                )

                              : null,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Text(

                    currentUser['name'],

                    textAlign:
                        TextAlign.center,

                    style:
                        const TextStyle(

                      color:
                          Color(
                        0xFFD8CFB4,
                      ),

                      fontSize: 26,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(

                    currentUser['role']
                        .toString()
                        .replaceAll(
                          '_',
                          ' ',
                        )
                        .toUpperCase(),

                    style:
                        const TextStyle(

                      color:
                          Color(
                        0xFF16A085,
                      ),

                      letterSpacing:
                          1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            /// DETAILS
            infoCard(

              icon:
                  Icons.badge,

              title: "USN",

              value:
                  currentUser['usn'],
            ),

            infoCard(

              icon:
                  Icons.groups,

              title:
                  "COMMITTEE",

              value:
                  currentUser[
                          'committees']
                      ?['name'] ??
                  '',
            ),

            infoCard(

              icon:
                  Icons.email,

              title:
                  "EMAIL",

              value:
                  currentUser[
                          'email'] ??
                      '',
            ),

            /// LINKEDIN
            Container(

              width:
                  double.infinity,

              padding:
                  const EdgeInsets.all(
                20,
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
                  24,
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

                    "LINKEDIN PROFILE",

                    style:
                        TextStyle(

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

                  const SizedBox(
                    height: 18,
                  ),

                  if (!linkedinLocked)

                    Column(

                      children: [

                        TextField(

                          controller:
                              linkedinController,

                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                          ),

                          decoration:
                              InputDecoration(

                            hintText:
                                "Enter LinkedIn URL",

                            hintStyle:
                                const TextStyle(
                              color:
                                  Colors.grey,
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
                                savingLinkedin
                                    ? null
                                    : saveLinkedin,

                            child:
                                savingLinkedin

                                    ? const CircularProgressIndicator(
                                        color:
                                            Colors.black,
                                      )

                                    : const Text(

                                        "SAVE LINKEDIN",

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
                    )

                  else

                    Text(

                      currentUser[
                              'linkedin'] ??
                          'No LinkedIn Added',

                      style:
                          const TextStyle(

                        color:
                            Colors.white70,

                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            /// LOGOUT
            SizedBox(

              width:
                  double.infinity,

              height: 55,

              child:
                  ElevatedButton.icon(

                style:
                    ElevatedButton.styleFrom(

                  backgroundColor:
                      Colors.red
                          .withOpacity(
                    0.85,
                  ),
                ),

                onPressed: () {

                  Navigator.pushAndRemoveUntil(

                    context,

                    MaterialPageRoute(

                      builder: (_) {

                        return const LoginScreen();
                      },
                    ),

                    (route) => false,
                  );
                },

                icon:
                    const Icon(
                  Icons.logout,
                  color: Colors.white,
                ),

                label:
                    const Text(

                  "LOGOUT",

                  style:
                      TextStyle(

                    color:
                        Colors.white,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
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