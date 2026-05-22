import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeContent extends StatefulWidget {

  final Map<String, dynamic> user;

  const HomeContent({
    super.key,
    required this.user,
  });

  @override
  State<HomeContent> createState() =>
      _HomeContentState();
}

class _HomeContentState
    extends State<HomeContent> {

  final supabase =
      Supabase.instance.client;

  List<Map<String, dynamic>>
      latestPosts = [];

  List<Map<String, dynamic>>
      upcomingMeetings = [];

  bool loading = true;

  @override
  void initState() {

    super.initState();

    initialize();
  }

  Future<void> initialize() async {

    await loadPosts();

    await loadMeetings();

    setState(() {
      loading = false;
    });
  }

  /// LOAD POSTS
  Future<void> loadPosts() async {

    try {

      final data = await supabase

          .from('posts')

          .select('''
            *,
            users(
              name,
              photo_url,
              role
            )
          ''')

          .order(
            'created_at',
            ascending: false,
          )

          .limit(5);

      latestPosts =
          List<Map<String, dynamic>>
              .from(data);

    } catch (e) {

      debugPrint(e.toString());
    }
  }

  /// LOAD MEETINGS
  Future<void> loadMeetings() async {

    try {

      final data = await supabase

          .from('meetings')

          .select()

          .gte(
            'scheduled_at',
            DateTime.now()
                .toIso8601String(),
          )

          .order(
            'scheduled_at',
            ascending: true,
          )

          .limit(5);

      upcomingMeetings =
          List<Map<String, dynamic>>
              .from(data);

    } catch (e) {

      debugPrint(e.toString());
    }
  }

  bool isAdmin() {

    final role =
        widget.user['role']
            .toString();

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

  Widget dashboardCard({

    required String title,

    required String value,

    required IconData icon,
  }) {

    return Expanded(

      child: Container(

        padding:
            const EdgeInsets.all(18),

        decoration:
            BoxDecoration(

          color:
              Colors.white
                  .withOpacity(0.03),

          borderRadius:
              BorderRadius.circular(
            18,
          ),

          border: Border.all(
            color: Colors.white10,
          ),
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Icon(

              icon,

              color:
                  const Color(
                0xFF16A085,
              ),

              size: 24,
            ),

            const SizedBox(height: 14),

            Text(

              value,

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

            const SizedBox(height: 6),

            Text(

              title,

              style:
                  const TextStyle(

                color:
                    Colors.grey,

                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
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

              fontSize: 15,

              fontWeight:
                  FontWeight.bold,

              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final committee =
        widget.user['committees']
                ?['name'] ??
            '';

    final photo =
        widget.user['photo_url'];

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

              : RefreshIndicator(

                  color:
                      const Color(
                    0xFF16A085,
                  ),

                  onRefresh:
                      initialize,

                  child:
                      SingleChildScrollView(

                    physics:
                        const AlwaysScrollableScrollPhysics(),

                    padding:
                        const EdgeInsets.all(
                      18,
                    ),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        /// HERO CARD
                        Container(

                          width:
                              double.infinity,

                          padding:
                              const EdgeInsets.all(
                            22,
                          ),

                          decoration:
                              BoxDecoration(

                            gradient:
                                LinearGradient(

                              colors: [

                                const Color(
                                  0xFF16A085,
                                ).withOpacity(
                                  0.22,
                                ),

                                Colors.white
                                    .withOpacity(
                                  0.03,
                                ),
                              ],
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

                              CircleAvatar(

                                radius: 34,

                                backgroundColor:
                                    const Color(
                                  0xFF16A085,
                                ),

                                child:
                                    CircleAvatar(

                                  radius: 31,

                                  backgroundColor:
                                      Colors.black,

                                  backgroundImage:
                                      photo != null &&
                                              photo !=
                                                  ''
                                          ? NetworkImage(
                                              photo,
                                            )
                                          : null,

                                  child:
                                      photo == null ||
                                              photo ==
                                                  ''
                                          ? const Icon(

                                              Icons.person,

                                              color:
                                                  Color(
                                                0xFF16A085,
                                              ),

                                              size: 32,
                                            )
                                          : null,
                                ),
                              ),

                              const SizedBox(
                                width: 18,
                              ),

                              Expanded(

                                child: Column(

                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [

                                    Text(

                                      "Welcome Back",

                                      style:
                                          TextStyle(

                                        color:
                                            Colors.grey.shade400,

                                        fontSize:
                                            12,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 4,
                                    ),

                                    Text(

                                      widget.user['name'],

                                      style:
                                          const TextStyle(

                                        color:
                                            Color(
                                          0xFFD8CFB4,
                                        ),

                                        fontSize:
                                            22,

                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 6,
                                    ),

                                    Text(

                                      "$committee • ${widget.user['role'].toString().replaceAll('_', ' ').toUpperCase()}",

                                      style:
                                          const TextStyle(

                                        color:
                                            Color(
                                          0xFF16A085,
                                        ),

                                        fontSize:
                                            11,

                                        letterSpacing:
                                            1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        /// STATS
                        Row(

                          children: [

                            dashboardCard(

                              title:
                                  "Posts",

                              value:
                                  latestPosts.length
                                      .toString(),

                              icon:
                                  Icons.feed_rounded,
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            dashboardCard(

                              title:
                                  "Meetings",

                              value:
                                  upcomingMeetings
                                      .length
                                      .toString(),

                              icon:
                                  Icons.calendar_month_rounded,
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        /// UPCOMING MEETINGS
                        sectionTitle(
                          "UPCOMING MEETINGS",
                        ),

                        if (upcomingMeetings
                            .isEmpty)

                          const Padding(

                            padding:
                                EdgeInsets.only(
                              top: 20,
                            ),

                            child: Center(

                              child: Text(

                                "No Upcoming Meetings",

                                style:
                                    TextStyle(
                                  color:
                                      Colors.grey,
                                ),
                              ),
                            ),
                          ),

                        ...upcomingMeetings
                            .map((meeting) {

                          return Container(

                            margin:
                                const EdgeInsets.only(
                              bottom: 14,
                            ),

                            padding:
                                const EdgeInsets.all(
                              18,
                            ),

                            decoration:
                                BoxDecoration(

                              color: Colors.white
                                  .withOpacity(
                                0.03,
                              ),

                              borderRadius:
                                  BorderRadius.circular(
                                18,
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

                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,

                                  children: [

                                    Expanded(

                                      child: Text(

                                        meeting['title'],

                                        style:
                                            const TextStyle(

                                          color:
                                              Color(
                                            0xFFD8CFB4,
                                          ),

                                          fontSize:
                                              16,

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
                                          10,
                                        ),
                                      ),

                                      child: Text(

                                        meeting['scheduled_at']
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

                                  meeting['agenda'],

                                  style:
                                      const TextStyle(

                                    color:
                                        Colors.white70,

                                    fontSize:
                                        13,

                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(
                          height: 28,
                        ),

                        /// LATEST POSTS
                        sectionTitle(
                          "LATEST POSTS",
                        ),

                        if (latestPosts
                            .isEmpty)

                          const Padding(

                            padding:
                                EdgeInsets.only(
                              top: 20,
                            ),

                            child: Center(

                              child: Text(

                                "No Posts Yet",

                                style:
                                    TextStyle(
                                  color:
                                      Colors.grey,
                                ),
                              ),
                            ),
                          ),

                        ...latestPosts
                            .map((post) {

                          final creator =
                              post['users'];

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
                                18,
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

                                    CircleAvatar(

                                      radius: 22,

                                      backgroundImage:
                                          creator[
                                                          'photo_url'] !=
                                                      null &&
                                                  creator[
                                                          'photo_url'] !=
                                                      ''

                                              ? NetworkImage(
                                                  creator[
                                                      'photo_url'],
                                                )

                                              : null,

                                      backgroundColor:
                                          const Color(
                                        0xFF16A085,
                                      ),

                                      child:
                                          creator['photo_url'] ==
                                                  null
                                              ? const Icon(
                                                  Icons.person,
                                                  color:
                                                      Colors.black,
                                                )
                                              : null,
                                    ),

                                    const SizedBox(
                                      width: 12,
                                    ),

                                    Expanded(

                                      child: Column(

                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,

                                        children: [

                                          Text(

                                            creator['name'] ??
                                                '',

                                            style:
                                                const TextStyle(

                                              color:
                                                  Color(
                                                0xFFD8CFB4,
                                              ),

                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),

                                          const SizedBox(
                                            height:
                                                3,
                                          ),

                                          Text(

                                            creator['role']
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

                                              fontSize:
                                                  10,

                                              letterSpacing:
                                                  1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                  height: 16,
                                ),

                                Text(

                                  post['title'],

                                  style:
                                      const TextStyle(

                                    color:
                                        Color(
                                      0xFFD8CFB4,
                                    ),

                                    fontSize:
                                        16,

                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 10,
                                ),

                                Text(

                                  post['content'],

                                  style:
                                      const TextStyle(

                                    color:
                                        Colors.white70,

                                    fontSize:
                                        13,

                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(
                          height: 100,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}