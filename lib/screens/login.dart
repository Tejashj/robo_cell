import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../navigation.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final supabase =
      Supabase.instance.client;

  bool loading = true;

  bool loggingIn = false;

  List<Map<String, dynamic>>
      committees = [];

  List<Map<String, dynamic>>
      members = [];

  Map<String, dynamic>?
      selectedCommittee;

  Map<String, dynamic>?
      selectedMember;

  final passwordController =
      TextEditingController();

  @override
  void initState() {

    super.initState();

    loadCommittees();
  }

  Future<void> loadCommittees()
  async {

    try {

      final data =
          await supabase

              .from('committees')

              .select()

              .order('name');

      committees =
          List<Map<String, dynamic>>
              .from(data);

    } catch (e) {

      debugPrint(e.toString());
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> loadMembers(
    int committeeId,
  ) async {

    setState(() {

      loading = true;

      selectedMember = null;

      members = [];
    });

    try {

      final data =
          await supabase

              .from('users')

              .select()

              .eq(
                'committee_id',
                committeeId,
              )

              .order('role')

              .order('name');

      members =
          List<Map<String, dynamic>>
              .from(data);

    } catch (e) {

      debugPrint(e.toString());
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> login()
  async {

    if (selectedMember == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
              Text(
            "Select Member",
          ),
        ),
      );

      return;
    }

    if (passwordController.text
        .trim()
        .isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
              Text(
            "Enter Password",
          ),
        ),
      );

      return;
    }

    setState(() {
      loggingIn = true;
    });

    try {

      final result =
          await supabase

              .from('users')

              .select('''
                *,
                committees(
                  id,
                  name
                )
              ''')

              .eq(
                'id',
                selectedMember!['id'],
              )

              .eq(
                'password',
                passwordController.text
                    .trim(),
              )

              .single();

      if (!mounted) return;

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (_) {

            return MainNavigation(
              user: result,
            );
          },
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
              Text(
            "Invalid Password",
          ),
        ),
      );
    }

    setState(() {
      loggingIn = false;
    });
  }

  Widget buildCommitteeDropdown() {

    return DropdownButtonFormField<
        Map<String, dynamic>>(

      value: selectedCommittee,

      dropdownColor:
          Colors.black,

      style:
          const TextStyle(
        color: Colors.white,
      ),

      decoration:
          InputDecoration(

        hintText:
            "Select Committee",

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

      items:
          committees.map((c) {

        return DropdownMenuItem(

          value: c,

          child: Text(
            c['name'],
          ),
        );
      }).toList(),

      onChanged: (value) {

        if (value == null) {
          return;
        }

        setState(() {

          selectedCommittee =
              value;
        });

        loadMembers(value['id']);
      },
    );
  }

  Widget buildMemberDropdown() {

    return DropdownButtonFormField<
        Map<String, dynamic>>(

      value: selectedMember,

      dropdownColor:
          Colors.black,

      style:
          const TextStyle(
        color: Colors.white,
      ),

      decoration:
          InputDecoration(

        hintText:
            "Select Member",

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

      items:
          members.map((m) {

        return DropdownMenuItem(

          value: m,

          child: Text(

            "${m['name']} (${m['role'].toString().replaceAll('_', ' ')})",
          ),
        );
      }).toList(),

      onChanged: (value) {

        setState(() {

          selectedMember =
              value;
        });
      },
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

              : SafeArea(

                  child:
                      SingleChildScrollView(

                    padding:
                        const EdgeInsets.all(
                      24,
                    ),

                    child: Column(

                      children: [

                        const SizedBox(
                          height: 20,
                        ),

                        /// LOGO
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
                              30,
                            ),

                            border: Border.all(
                              color:
                                  Colors.white10,
                            ),
                          ),

                          child: ClipRRect(

                            borderRadius:
                                BorderRadius.circular(
                              20,
                            ),

                            child: Image.asset(

                              'assets/rcell.jpg',

                              height: 120,

                              width: 120,

                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        const Text(

                          "ROBO CELL",

                          style:
                              TextStyle(

                            color:
                                Color(
                              0xFFD8CFB4,
                            ),

                            fontSize: 30,

                            fontWeight:
                                FontWeight.bold,

                            letterSpacing:
                                2,
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        const Text(

                          "Bangalore Institute of Technology",

                          textAlign:
                              TextAlign.center,

                          style:
                              TextStyle(

                            color:
                                Colors.white70,

                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(
                          height: 50,
                        ),

                        /// LOGIN CARD
                        Container(

                          width:
                              double.infinity,

                          padding:
                              const EdgeInsets.all(
                            22,
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
                              28,
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

                                "LOGIN",

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

                                  fontSize: 18,
                                ),
                              ),

                              const SizedBox(
                                height: 22,
                              ),

                              buildCommitteeDropdown(),

                              if (members
                                  .isNotEmpty) ...[

                                const SizedBox(
                                  height: 18,
                                ),

                                buildMemberDropdown(),
                              ],

                              if (selectedMember !=
                                  null) ...[

                                const SizedBox(
                                  height: 18,
                                ),

                                TextField(

                                  controller:
                                      passwordController,

                                  obscureText:
                                      true,

                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white,
                                  ),

                                  decoration:
                                      InputDecoration(

                                    hintText:
                                        "Enter Password",

                                    hintStyle:
                                        const TextStyle(
                                      color:
                                          Colors.grey,
                                    ),

                                    prefixIcon:
                                        const Icon(

                                      Icons.lock,

                                      color:
                                          Color(
                                        0xFF16A085,
                                      ),
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
                                  height: 24,
                                ),

                                SizedBox(

                                  width:
                                      double.infinity,

                                  height: 54,

                                  child:
                                      ElevatedButton(

                                    style:
                                        ElevatedButton.styleFrom(

                                      backgroundColor:
                                          const Color(
                                        0xFF16A085,
                                      ),

                                      shape:
                                          RoundedRectangleBorder(

                                        borderRadius:
                                            BorderRadius.circular(
                                          18,
                                        ),
                                      ),
                                    ),

                                    onPressed:
                                        loggingIn
                                            ? null
                                            : login,

                                    child:
                                        loggingIn

                                            ? const CircularProgressIndicator(
                                                color:
                                                    Colors.black,
                                              )

                                            : const Text(

                                                "LOGIN",

                                                style:
                                                    TextStyle(

                                                  color:
                                                      Colors.black,

                                                  fontWeight:
                                                      FontWeight.bold,

                                                  letterSpacing:
                                                      1,
                                                ),
                                              ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 40,
                        ),

                        const Text(

                          "ROBO CELL • 2026",

                          style:
                              TextStyle(

                            color:
                                Colors.grey,

                            letterSpacing:
                                1.5,

                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}