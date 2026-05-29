import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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

  /// ================= IMAGE URL =================

  String getImageUrl(
    Map<String, dynamic> member,
  ) {
    final role =
        (member['role'] ?? '')
            .toString()
            .toLowerCase();

    final usn =
        (member['usn'] ?? '')
            .toString();

    /// FACULTY IMAGES

    if (role == 'faculty') {
      return supabase.storage
          .from('profile-images')
          .getPublicUrl(
            '$usn.JPG',
          );
    }

    /// STUDENT IMAGES

    return supabase.storage
        .from('profile-images')
        .getPublicUrl(
          '$usn.jpg',
        );
  }

  /// ================= LOAD COMMITTEES =================

  Future<void> loadCommittees()
  async {
    try {
      final data =
          await supabase

              .from('committees')

              .select()

              .order(
                'display_order',
                ascending: true,
              );

      committees =
          List<Map<String, dynamic>>
              .from(data);
    } catch (e) {
      debugPrint(e.toString());
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  /// ================= LOAD MEMBERS =================

  Future<void> loadMembers(
    int committeeId,
  ) async {
    HapticFeedback.selectionClick();

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

              .order(
                'id',
                ascending: true,
              );

      members =
          List<Map<String, dynamic>>
              .from(data);
    } catch (e) {
      debugPrint(e.toString());
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  /// ================= LOGIN =================

  Future<void> login()
  async {
    if (selectedMember == null) {
      showSnack(
        "SELECT MEMBER",
        Colors.redAccent,
      );

      return;
    }

    if (passwordController.text
        .trim()
        .isEmpty) {
      showSnack(
        "ENTER PASSWORD",
        Colors.orange,
      );

      return;
    }

    HapticFeedback.mediumImpact();

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

      // Save session to local storage
      Hive.box('robo_cache').put('logged_in_user', result);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,

        PageRouteBuilder(
          transitionDuration:
              const Duration(
            milliseconds: 900,
          ),

          pageBuilder:
              (
                context,
                animation,
                secondaryAnimation,
              ) {
            return FadeTransition(
              opacity: animation,

              child:
                  MainNavigation(
                user: result,
              ),
            );
          },
        ),
      );
    } catch (e) {
      showSnack(
        "INVALID PASSWORD",
        Colors.redAccent,
      );
    }

    if (!mounted) return;

    setState(() {
      loggingIn = false;
    });
  }

  /// ================= SNACKBAR =================

  void showSnack(
    String text,
    Color color,
  ) {
    ScaffoldMessenger.of(
      context,
    )

      ..hideCurrentSnackBar()

      ..showSnackBar(
        SnackBar(
          behavior:
              SnackBarBehavior.floating,

          margin:
              const EdgeInsets.all(
            16,
          ),

          backgroundColor:
              color,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),

          content: Text(
            text,

            style: const TextStyle(
              color: Colors.white,

              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
      );
  }

  /// ================= COMMITTEE DROPDOWN =================

  Widget buildCommitteeDropdown() {
    return DropdownButtonFormField<
        Map<String, dynamic>>(
      isExpanded: true,

      value: selectedCommittee,

      dropdownColor:
          const Color(
        0xFF111111,
      ),

      style: const TextStyle(
        color: Colors.white,
      ),

      iconEnabledColor:
          const Color(
        0xFF16A085,
      ),

      decoration: InputDecoration(
        hintText:
            "SELECT COMMITTEE",

        hintStyle:
            const TextStyle(
          color: Colors.grey,
        ),

        filled: true,

        fillColor:
            Colors.white.withOpacity(
          0.03,
        ),

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            20,
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
            c['name']
                .toString()
                .toUpperCase(),
          ),
        );
      }).toList(),

      onChanged: (value) {
        if (value == null) return;

        setState(() {
          selectedCommittee =
              value;
        });

        loadMembers(value['id']);
      },
    );
  }

  /// ================= MEMBER DROPDOWN =================

  Widget buildMemberDropdown() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: loading && selectedCommittee != null
          ? Container(
              key: const ValueKey("loading"),
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Color(0xFF16A085),
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          : DropdownButtonFormField<
              Map<String, dynamic>>(
              key: const ValueKey("loaded"),
              isExpanded: true,
      
              value: selectedMember,
      
              dropdownColor:
                  const Color(
                0xFF111111,
              ),
      
              style: const TextStyle(
                color: Colors.white,
              ),
      
              iconEnabledColor:
                  const Color(
                0xFF16A085,
              ),
      
              decoration: InputDecoration(
                hintText:
                    "SELECT MEMBER",
      
                hintStyle:
                    const TextStyle(
                  color: Colors.grey,
                ),
      
                filled: true,
      
                fillColor:
                    Colors.white.withOpacity(
                  0.03,
                ),
      
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
      
                  borderSide:
                      BorderSide.none,
                ),
              ),
      
              items:
                  members.map((m) {
                final imageUrl =
                    getImageUrl(m);
      
                return DropdownMenuItem(
                  value: m,
      
                  child: Row(
                    children: [
                      ClipOval(
                        child: Container(
                          width: 36,
                          height: 36,
                          color: const Color(0xFF16A085),
                          child: imageUrl.isNotEmpty
                              ? FadeInImage(
                                  placeholder: const AssetImage('assets/rcell.jpg'),
                                  image: CachedNetworkImageProvider(imageUrl),
                                  fit: BoxFit.cover,
                                  fadeInDuration: const Duration(milliseconds: 400),
                                  imageErrorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.black, size: 20),
                                )
                              : const Icon(Icons.person, color: Colors.black, size: 20),
                        ),
                      ),
      
                      const SizedBox(
                        width: 12,
                      ),
      
                      Expanded(
                        child: Text(
                          m['name']
                              .toString()
                              .toUpperCase(),
      
                          overflow:
                              TextOverflow
                                  .ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
      
              onChanged: (value) {
                HapticFeedback.selectionClick();
      
                setState(() {
                  selectedMember =
                      value;
                });
              },
            ),
    );
  }

  /// ================= HERO PROFILE =================

  Widget buildHeroProfile() {
    const neon =
        Color(0xFF16A085);

    final imageUrl =
        selectedMember != null
            ? getImageUrl(
                selectedMember!,
              )
            : '';

    return Hero(
      tag: "rcell_logo",

      child:
          AnimatedSwitcher(
        duration:
            const Duration(
          milliseconds: 550,
        ),

        switchInCurve:
            Curves.easeOutCubic,

        switchOutCurve:
            Curves.easeInOutCubic,

        transitionBuilder:
            (
              child,
              animation,
            ) {
          return FadeTransition(
            opacity:
                animation,

            child:
                ScaleTransition(
              scale:
                  Tween<double>(
                begin: 0.92,
                end: 1,
              ).animate(
                animation,
              ),

              child: child,
            ),
          );
        },

        child:
            selectedMember == null
                ? Container(
                    key:
                        const ValueKey(
                      "logo",
                    ),

                    padding:
                        const EdgeInsets.all(
                      5,
                    ),

                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,

                      border:
                          Border.all(
                        color: neon,
                        width: 3,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color:
                              neon.withOpacity(
                            0.25,
                          ),

                          blurRadius:
                              30,
                        ),
                      ],
                    ),

                    child:
                        const CircleAvatar(
                      radius: 72,

                      backgroundColor:
                          Colors.black,

                      backgroundImage:
                          AssetImage(
                        'assets/rcell.jpg',
                      ),
                    ),
                  )
                : Container(
                    key: ValueKey(
                      selectedMember![
                          'id'],
                    ),

                    padding:
                        const EdgeInsets.all(
                      5,
                    ),

                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,

                      border:
                          Border.all(
                        color: neon,
                        width: 3,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color:
                              neon.withOpacity(
                            0.25,
                          ),

                          blurRadius:
                              30,
                        ),
                      ],
                    ),

                    child:
                        CircleAvatar(
                      radius: 76,

                      backgroundColor:
                          Colors.black,

                      child:
                          ClipOval(
                        child:
                            FadeInImage(
                          placeholder: const AssetImage('assets/rcell.jpg'),
                          image: CachedNetworkImageProvider(imageUrl),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          fadeInDuration: const Duration(milliseconds: 500),
                          imageErrorBuilder:
                              (
                                context,
                                error,
                                stackTrace,
                              ) {
                            return Container(
                              color:
                                  Colors.black,

                              child:
                                  Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,

                                children: [

                                  const Icon(
                                    Icons
                                        .broken_image_rounded,

                                    color:
                                        Colors.white54,

                                    size:
                                        42,
                                  ),

                                  const SizedBox(
                                    height:
                                        8,
                                  ),

                                  const Text(
                                    "IMAGE\nNOT FOUND",

                                    textAlign:
                                        TextAlign.center,

                                    style:
                                        TextStyle(
                                      color:
                                          Colors.white54,

                                      fontSize:
                                          10,

                                      fontWeight:
                                          FontWeight.bold,

                                      letterSpacing:
                                          1.2,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const neon =
        Color(0xFF16A085);

    return Scaffold(
      backgroundColor:
          const Color(
        0xFF030303,
      ),

      body: SizedBox.expand(
        child: Stack(
          children: [

          Positioned(
            top: -150,
            right: -100,

            child: Container(
              width: 350,
              height: 350,

              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,

                gradient:
                    RadialGradient(
                  colors: [
                    neon.withOpacity(
                      0.18,
                    ),

                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -180,
            left: -120,

            child: Container(
              width: 420,
              height: 420,

              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,

                gradient:
                    RadialGradient(
                  colors: [
                    Colors.blueGrey
                        .withOpacity(
                      0.18,
                    ),

                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child:
                loading
                    ? const Center(
                        child:
                            CircularProgressIndicator(
                          color:
                              neon,
                        ),
                      )
                    : SingleChildScrollView(
                        physics:
                            const BouncingScrollPhysics(),

                        padding:
                            const EdgeInsets.all(
                          24,
                        ),

                        child: Column(
                          children: [

                            const SizedBox(
                              height: 20,
                            ),

                            buildHeroProfile(),

                            const SizedBox(
                              height: 28,
                            ),

                            const Text(
                              "ROBO CELL",

                              style:
                                  TextStyle(
                                color:
                                    Color(
                                  0xFFE2E8F0,
                                ),

                                fontSize:
                                    34,

                                fontWeight:
                                    FontWeight.w900,

                                letterSpacing:
                                    8,
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            AnimatedSwitcher(
                              duration:
                                  const Duration(
                                milliseconds:
                                    400,
                              ),

                              child:
                                  selectedMember ==
                                          null
                                      ? const Text(
                                          "LOGIN PORTAL",

                                          key:
                                              ValueKey(
                                            "default",
                                          ),

                                          style:
                                              TextStyle(
                                            color:
                                                Colors.grey,

                                            fontSize:
                                                13,

                                            letterSpacing:
                                                1.5,
                                          ),
                                        )
                                      : Text(
                                          selectedMember![
                                                  'role']
                                              .toString()
                                              .replaceAll(
                                                "_",
                                                " ",
                                              )
                                              .toUpperCase(),

                                          key:
                                              const ValueKey(
                                            "role",
                                          ),

                                          style:
                                              const TextStyle(
                                            color:
                                                neon,

                                            fontSize:
                                                14,

                                            fontWeight:
                                                FontWeight.bold,

                                            letterSpacing:
                                                2,
                                          ),
                                        ),
                            ),

                            const SizedBox(
                              height: 42,
                            ),

                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(
                                32,
                              ),

                              child:
                                  BackdropFilter(
                                filter:
                                    ImageFilter.blur(
                                  sigmaX: 18,
                                  sigmaY: 18,
                                ),

                                child:
                                    Container(
                                  width:
                                      double.infinity,

                                  padding:
                                      const EdgeInsets.all(
                                    24,
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
                                      32,
                                    ),

                                    border:
                                        Border.all(
                                      color:
                                          Colors.white
                                              .withOpacity(
                                        0.08,
                                      ),
                                    ),
                                  ),

                                  child:
                                      Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [

                                      const Text(
                                        "LOGIN HERE",

                                        style:
                                            TextStyle(
                                          color:
                                              Color(
                                            0xFFD8CFB4,
                                          ),

                                          fontWeight:
                                              FontWeight.bold,

                                          fontSize:
                                              17,

                                          letterSpacing:
                                              1.5,
                                        ),
                                      ),

                                      const SizedBox(
                                        height:
                                            24,
                                      ),

                                      buildCommitteeDropdown(),

                                      if (members
                                          .isNotEmpty) ...[

                                        const SizedBox(
                                          height:
                                              20,
                                        ),

                                        buildMemberDropdown(),
                                      ],

                                      if (selectedMember !=
                                          null) ...[

                                        const SizedBox(
                                          height:
                                              24,
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
                                                "ENTER PASSWORD",

                                            hintStyle:
                                                const TextStyle(
                                              color:
                                                  Colors.grey,
                                            ),

                                            prefixIcon:
                                                const Icon(
                                              Icons.lock,

                                              color:
                                                  neon,
                                            ),

                                            filled:
                                                true,

                                            fillColor:
                                                Colors.white
                                                    .withOpacity(
                                              0.03,
                                            ),

                                            border:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                20,
                                              ),

                                              borderSide:
                                                  BorderSide.none,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(
                                          height:
                                              28,
                                        ),

                                        SizedBox(
                                          width:
                                              double.infinity,

                                          height:
                                              58,

                                          child:
                                              ElevatedButton(
                                            style:
                                                ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  neon,

                                              shape:
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  20,
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
                                                              2,

                                                          fontSize:
                                                              15,
                                                        ),
                                                      ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 40,
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
      ),
    );
  }
}  