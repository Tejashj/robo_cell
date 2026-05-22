import 'package:flutter/material.dart';
import 'package:robo_cell/screens/screens/feedpage.dart';
import 'package:robo_cell/screens/screens/home.dart';
import 'package:robo_cell/screens/screens/meetings.dart';
import 'package:robo_cell/screens/screens/about.dart';
import 'package:robo_cell/screens/screens/profile.dart';

class MainNavigation extends StatefulWidget {

  final Map<String, dynamic> user;

  const MainNavigation({
    super.key,
    required this.user,
  });

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}

class _MainNavigationState
    extends State<MainNavigation> {

  int currentIndex = 0;

  late List<Widget> pages;

  @override
  void initState() {

    super.initState();

    pages = [

      HomeContent(
        user: widget.user, onNavigateToMeetings: () {  },
      ),

      FeedPage(
        user: widget.user,
      ),

      MeetingsPage(
        user: widget.user,
      ),

      const AboutRoboCellPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {

    final photo =
        widget.user['photo_url'];

    return Scaffold(

      backgroundColor:
          Colors.black,

      appBar: AppBar(

        backgroundColor:
            Colors.black,

        elevation: 0,

        leading: Padding(

          padding:
              const EdgeInsets.all(
            8,
          ),

          child: ClipRRect(

            borderRadius:
                BorderRadius.circular(
              12,
            ),

            child: Image.asset(
              'assets/rcell.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),

        title: const Text(

          "ROBO CELL",

          style: TextStyle(

            color:
                Color(
              0xFFD8CFB4,
            ),

            fontWeight:
                FontWeight.bold,

            letterSpacing:
                1.5,
          ),
        ),

        centerTitle: true,

        actions: [

          Padding(

            padding:
                const EdgeInsets.only(
              right: 14,
            ),

            child: GestureDetector(

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) {

                      return ProfilePage(
                        user: widget.user,
                      );
                    },
                  ),
                );
              },

              child: CircleAvatar(

                radius: 19,

                backgroundColor:
                    const Color(
                  0xFF16A085,
                ),

                child: CircleAvatar(

                  radius: 17,

                  backgroundColor:
                      Colors.black,

                  backgroundImage:
                      photo != null &&
                              photo != ''
                          ? NetworkImage(
                              photo,
                            )
                          : null,

                  child:
                      photo == null ||
                              photo == ''
                          ? const Icon(

                              Icons.person,

                              size: 18,

                              color:
                                  Color(
                                0xFF16A085,
                              ),
                            )
                          : null,
                ),
              ),
            ),
          ),
        ],
      ),

      body: IndexedStack(

        index: currentIndex,

        children: pages,
      ),

      bottomNavigationBar:
          Container(

        decoration:
            BoxDecoration(

          color: Colors.black,

          boxShadow: [

            BoxShadow(

              color:
                  Colors.black
                      .withOpacity(
                0.6,
              ),

              blurRadius: 20,
            ),
          ],
        ),

        child: BottomNavigationBar(

          currentIndex:
              currentIndex,

          onTap: (index) {

            setState(() {

              currentIndex =
                  index;
            });
          },

          backgroundColor:
              Colors.black,

          type:
              BottomNavigationBarType.fixed,

          selectedItemColor:
              const Color(
            0xFF16A085,
          ),

          unselectedItemColor:
              Colors.grey,

          selectedLabelStyle:
              const TextStyle(

            fontWeight:
                FontWeight.bold,

            fontSize: 11,
          ),

          unselectedLabelStyle:
              const TextStyle(
            fontSize: 10,
          ),

          items: const [

            BottomNavigationBarItem(

              icon: Icon(
                Icons.dashboard_rounded,
              ),

              label: "Home",
            ),

            BottomNavigationBarItem(

              icon: Icon(
                Icons.feed_rounded,
              ),

              label: "Feed",
            ),

            BottomNavigationBarItem(

              icon: Icon(
                Icons.calendar_month_rounded,
              ),

              label: "Meetings",
            ),

            BottomNavigationBarItem(

              icon: Icon(
                Icons.info_outline_rounded,
              ),

              label: "About",
            ),
          ],
        ),
      ),
    );
  }
}