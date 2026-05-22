import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CommitteesPage extends StatefulWidget {
  const CommitteesPage({super.key});

  @override
  State<CommitteesPage> createState() =>
      _CommitteesPageState();
}

class _CommitteesPageState
    extends State<CommitteesPage> {
  final supabase =
      Supabase.instance.client;

  int? flippedCard;

  final List<String>
      committeeOrder = [
    "Faculty",
    "Office Bearers",
    "Management",
    "Marketing",
    "Content",
    "Design",
    "Creative",
    "Media",
    "Newsletter",
    "Service",
    "Sports",
    "Cultural",
    "Industrial",
    "Student Welfare",
    "Disciplinary",
  ];

  Color committeeColor(
    String committee,
  ) {
    switch (
        committee.toLowerCase()) {
      case 'faculty':
        return const Color(0xFF16A085);

      case 'office bearers':
        return const Color(0xFF16A085);

      case 'management':
        return const Color(0xFF16A085);

      case 'marketing':
        return const Color(0xFF16A085);

      case 'content':
        return const Color(0xFF16A085);

      case 'design':
        return const Color(0xFF16A085);

      case 'creative':
        return const Color(0xFF16A085);

      case 'media':
        return const Color(0xFF16A085);

      case 'newsletter':
        return const Color(0xFF16A085);

      case 'service':
        return const Color(0xFF16A085);

      case 'sports':
        return const Color(0xFF16A085);
      case 'cultural':
        return const Color(0xFF16A085);

      case 'industrial':
        return const Color(0xFF16A085);

      case 'student welfare':
        return const Color(0xFF16A085);

      case 'disciplinary':
        return const Color(0xFF16A085);

      default:
        return const Color(
          0xFF16A085,
        );
    }
  }

  int rolePriority(
    String role,
  ) {
    final r =
        role.toLowerCase();

    if (r.contains(
      'faculty in charge',
    )) return 0;

    if (r.contains(
      'faculty coordinator',
    )) return 1;

    if (r.contains(
      'president',
    )) return 2;

    if (r.contains(
      'vice president',
    )) return 3;

    if (r.contains(
      'secretary',
    )) return 4;

    if (r.contains(
      'joint secretary',
    )) return 5;

    if (r.contains(
      'treasurer',
    )) return 6;

    if (r.contains(
      'director',
    )) return 7;

    if (r == 'head') return 8;

    if (r.contains(
      'co-head',
    )) return 9;

    return 10;
  }

  Future<Map<String, List<dynamic>>>
      fetchCommittees() async {
    final response =
        await supabase
            .from('users')
            .select('''
              id,
              name,
              usn,
              email,
              role,
              linkedin,
              photo_url,
              committees(name)
            ''');

    Map<String, List<dynamic>>
        grouped = {};

    for (var committee
        in committeeOrder) {
      grouped[committee] = [];
    }

    for (var user in response) {
      final committee =
          user['committees']
                  ?['name'] ??
              '';

      final matchedCommittee =
          committeeOrder.firstWhere(
        (c) =>
            c.toLowerCase() ==
            committee.toLowerCase(),
        orElse: () => '',
      );

      if (matchedCommittee
          .isNotEmpty) {
        grouped[
                matchedCommittee]!
            .add(user);
      }
    }

    for (var committee
        in committeeOrder) {
      grouped[committee]!.sort(
        (a, b) {
          return rolePriority(
            a['role'] ?? '',
          ).compareTo(
            rolePriority(
              b['role'] ?? '',
            ),
          );
        },
      );
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.black,

      appBar: AppBar(
        backgroundColor:
            Colors.black,

        centerTitle: true,

        elevation: 0,

        title: const Text(
          "ROBO CELL HERITAGE",
          style: TextStyle(
            color: Color(
              0xFFD8CFB4,
            ),
            fontWeight:
                FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),

      body: FutureBuilder<
          Map<String,
              List<dynamic>>>(
        future:
            fetchCommittees(),

        builder:
            (
              context,
              snapshot,
            ) {
          if (!snapshot
              .hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(
                color: Color(
                  0xFF16A085,
                ),
              ),
            );
          }

          final committees =
              snapshot.data!;

          return ListView.builder(
            padding:
                const EdgeInsets.all(
              18,
            ),

            itemCount:
                committeeOrder.length,

            itemBuilder:
                (
                  context,
                  index,
                ) {
              final committee =
                  committeeOrder[
                      index];

              final members =
                  committees[
                      committee]!;

              if (members
                  .isEmpty) {
                return const SizedBox();
              }

              final color =
                  committeeColor(
                committee,
              );

              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 45,
                ),

                child: Column(
                  children: [
                    Text(
                      committee
                          .toUpperCase(),

                      style:
                          TextStyle(
                        color: color,
                        fontWeight:
                            FontWeight
                                .bold,
                        fontSize: 16,
                        letterSpacing:
                            3,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Container(
                      width: 90,
                      height: 2,
                      color: color,
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    Wrap(
                      alignment:
                          WrapAlignment
                              .center,

                      spacing: 16,

                      runSpacing: 16,

                      children:
                          members.map(
                        (member) {
                          return SizedBox(
                            width: 170,
                            height: 280,

                            child:
                                MemberCard(
                              member:
                                  member,

                              color:
                                  color,

                              isFlipped:
                                  flippedCard ==
                                      member[
                                          'id'],

                              onTap:
                                  () {
                                setState(
                                  () {
                                    if (flippedCard ==
                                        member[
                                            'id']) {
                                      flippedCard =
                                          null;
                                    } else {
                                      flippedCard =
                                          member[
                                              'id'];
                                    }
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MemberCard
    extends StatefulWidget {
  final dynamic member;

  final bool isFlipped;

  final VoidCallback onTap;

  final Color color;

  const MemberCard({
    super.key,
    required this.member,
    required this.isFlipped,
    required this.onTap,
    required this.color,
  });

  @override
  State<MemberCard> createState() =>
      _MemberCardState();
}

class _MemberCardState
    extends State<MemberCard>
    with
        SingleTickerProviderStateMixin {
  late AnimationController
      controller;

  late Animation<double>
      animation;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(
      vsync: this,
      duration:
          const Duration(
        milliseconds: 500,
      ),
    );

    animation =
        Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve:
            Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(
    covariant MemberCard oldWidget,
  ) {
    super.didUpdateWidget(
      oldWidget,
    );

    if (widget.isFlipped) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void>
      openLinkedin() async {
    String url =
        widget.member[
            'linkedin'] ??
            '';

    if (url.isEmpty) return;

    if (!url.startsWith(
      'http',
    )) {
      url = 'https://$url';
    }

    final uri =
        Uri.parse(url);

    if (await canLaunchUrl(
      uri,
    )) {
      await launchUrl(
        uri,
        mode: LaunchMode
            .externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final image =
        widget.member[
                'photo_url'] ??
            '';

    final role =
        widget.member[
                'role'] ??
            '';

    final name =
        widget.member[
                'name'] ??
            '';

    final usn =
        widget.member[
                'usn'] ??
            'FACULTY';

    final email =
        widget.member[
                'email'] ??
            '';

    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTap:
          openLinkedin,

      child:
          AnimatedBuilder(
        animation:
            animation,

        builder:
            (
              context,
              child,
            ) {
          final angle =
              animation.value *
                  3.1416;

          return Transform(
            alignment:
                Alignment.center,

            transform:
                Matrix4.identity()
                  ..setEntry(
                    3,
                    2,
                    0.001,
                  )
                  ..rotateY(
                    angle,
                  ),

            child:
                animation.value <
                        0.5
                    ? frontCard(
                        image,
                        name,
                        role,
                      )
                    : Transform(
                        alignment:
                            Alignment
                                .center,

                        transform:
                            Matrix4
                                .identity()
                              ..rotateY(
                                3.1416,
                              ),

                        child:
                            backCard(
                          name,
                          role,
                          usn,
                          email,
                        ),
                      ),
          );
        },
      ),
    );
  }

  Widget frontCard(
    String image,
    String name,
    String role,
  ) {
    return Container(
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
              widget.color,
          width: 1.5,
        ),
      ),

      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(
                top:
                    Radius.circular(
                  28,
                ),
              ),

              child: image
                      .isNotEmpty
                  ? Image.network(
                      image,
                      width: double
                          .infinity,
                      fit:
                          BoxFit.cover,

                      errorBuilder:
                          (
                            context,
                            error,
                            stackTrace,
                          ) {
                        return fallbackAvatar();
                      },
                    )
                  : fallbackAvatar(),
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.all(
              12,
            ),

            child: Column(
              children: [
                Text(
                  name
                      .toUpperCase(),

                  textAlign:
                      TextAlign.center,

                  maxLines: 2,

                  overflow:
                      TextOverflow
                          .ellipsis,

                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontWeight:
                        FontWeight
                            .bold,
                    fontSize: 12,
                    letterSpacing:
                        1,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Container(
                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        widget.color
                            .withOpacity(
                      0.2,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      30,
                    ),
                  ),

                  child: Text(
                    role
                        .replaceAll(
                          '_',
                          ' ',
                        )
                        .toUpperCase(),

                    textAlign:
                        TextAlign.center,

                    style:
                        TextStyle(
                      color:
                          widget.color,
                      fontWeight:
                          FontWeight
                              .bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget fallbackAvatar() {
    return Container(
      color:
          Colors.grey.shade900,

      child: const Center(
        child: CircleAvatar(
          radius: 45,

          backgroundColor:
              Color(
            0xFF1E1E1E,
          ),

          child: Icon(
            Icons.person,
            size: 50,
            color:
                Colors.white54,
          ),
        ),
      ),
    );
  }

  Widget backCard(
    String name,
    String role,
    String usn,
    String email,
  ) {
    return Container(
      decoration:
          BoxDecoration(
        gradient:
            LinearGradient(
          colors: [
            widget.color
                .withOpacity(
              0.25,
            ),
            Colors.black,
          ],
        ),

        borderRadius:
            BorderRadius.circular(
          28,
        ),

        border: Border.all(
          color:
              widget.color,
        ),
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,

          children: [
            Icon(
              Icons.person,
              color:
                  widget.color,
              size: 44,
            ),

            const SizedBox(
              height: 18,
            ),

            Text(
              name.toUpperCase(),

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    Colors.white,
                fontWeight:
                    FontWeight.bold,
                fontSize: 15,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              role
                  .replaceAll(
                    '_',
                    ' ',
                  )
                  .toUpperCase(),

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                color:
                    widget.color,
                fontWeight:
                    FontWeight.bold,
                fontSize: 11,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              usn.toUpperCase(),

              style:
                  const TextStyle(
                color:
                    Colors.white70,
                fontSize: 11,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              email.toUpperCase(),

              textAlign:
                  TextAlign.center,

              maxLines: 2,

              overflow:
                  TextOverflow
                      .ellipsis,

              style:
                  const TextStyle(
                color:
                    Colors.grey,
                fontSize: 10,
              ),
            ),

            const Spacer(),

            Text(
              "DOUBLE TAP FOR LINKEDIN",

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                color:
                    widget.color,
                fontSize: 8,
                letterSpacing:
                    1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}