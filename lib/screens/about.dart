import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AboutRoboCellPage extends StatefulWidget {

  const AboutRoboCellPage({
    super.key,
  });

  @override
  State<AboutRoboCellPage> createState() =>
      _AboutRoboCellPageState();
}

class _AboutRoboCellPageState
    extends State<AboutRoboCellPage> {

  final supabase =
      Supabase.instance.client;

  bool loading = true;

  List<Map<String, dynamic>>
      committees = [];

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

  Widget sectionTitle(
    String title,
  ) {

    return Padding(

      padding:
          const EdgeInsets.only(
        bottom: 16,
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

              letterSpacing:
                  1,
            ),
          ),
        ],
      ),
    );
  }

  Widget statCard({

    required String title,

    required String value,

    required IconData icon,
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

            Icon(

              icon,

              color:
                  const Color(
                0xFF16A085,
              ),

              size: 26,
            ),

            const SizedBox(
              height: 16,
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

                fontSize: 24,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

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

  Widget committeeCard(
    Map<String, dynamic>
        committee,
  ) {

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
              14,
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
                16,
              ),
            ),

            child: const Icon(

              Icons.groups_rounded,

              color:
                  Color(
                0xFF16A085,
              ),

              size: 26,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(

                  committee['name'],

                  style:
                      const TextStyle(

                    color:
                        Color(
                      0xFFD8CFB4,
                    ),

                    fontWeight:
                        FontWeight.bold,

                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(

                  committee['description'] ??
                      "ROBO CELL Committee",

                  style:
                      const TextStyle(

                    color:
                        Colors.white70,

                    height:
                        1.5,

                    fontSize: 12,
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

                      /// HERO
                      Container(

                        width:
                            double.infinity,

                        padding:
                            const EdgeInsets.all(
                          26,
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
                            30,
                          ),

                          border: Border.all(
                            color:
                                Colors.white10,
                          ),
                        ),

                        child: Column(

                          children: [

                            ClipRRect(

                              borderRadius:
                                  BorderRadius.circular(
                                22,
                              ),

                              child: Image.asset(

                                'assets/rcell.jpg',

                                height: 120,

                                width: 120,

                                fit: BoxFit.cover,
                              ),
                            ),

                            const SizedBox(
                              height: 22,
                            ),

                            const Text(

                              "ROBO CELL",

                              style:
                                  TextStyle(

                                color:
                                    Color(
                                  0xFFD8CFB4,
                                ),

                                fontSize: 28,

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

                              "Department of Robotics & Artificial Intelligence\nBangalore Institute of Technology",

                              textAlign:
                                  TextAlign.center,

                              style:
                                  TextStyle(

                                color:
                                    Colors.white70,

                                height:
                                    1.6,

                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      /// STATS
                      Row(

                        children: [

                          statCard(

                            title:
                                "COMMITTEES",

                            value:
                                committees
                                    .length
                                    .toString(),

                            icon:
                                Icons.groups_rounded,
                          ),

                          const SizedBox(
                            width: 14,
                          ),

                          statCard(

                            title:
                                "ACTIVE CLUB",

                            value:
                                "2026",

                            icon:
                                Icons.rocket_launch_rounded,
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      sectionTitle(
                        "ABOUT ROBO CELL",
                      ),

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

                        child:
                            const Text(

                          "ROBO CELL is the official technical and innovation club of the Department of Robotics & Artificial Intelligence at Bangalore Institute of Technology. The organization drives technical excellence through hackathons, workshops, industrial collaborations, innovation activities, project development, competitions, media operations, and student engagement initiatives.",

                          style:
                              TextStyle(

                            color:
                                Colors.white70,

                            height:
                                1.8,

                            fontSize: 14,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      sectionTitle(
                        "COMMITTEES",
                      ),

                      ...committees.map(
                        committeeCard,
                      ),

                      const SizedBox(
                        height: 80,
                      ),
                    ],
                  ),
                ),
    );
  }
}