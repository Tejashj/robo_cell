import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../constants/app_icons.dart';
import 'committees.dart';

class AboutRoboCellPage extends StatelessWidget {
  const AboutRoboCellPage({
    super.key,
  });

  Future<void> openLink(String url) async {
    final Uri uri = Uri.parse(url);

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> openMail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'robocellbit@gmail.com',
      query: 'subject=Hello Robo Cell&body=Greetings from Robo Cell App.',
    );

    await launchUrl(emailUri);
  }

  Widget infoTile({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(
        26,
      ),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 18,
        ),
        padding: const EdgeInsets.all(
          20,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(
                0.06,
              ),
              Colors.white.withOpacity(
                0.02,
              ),
            ],
          ),
          borderRadius: BorderRadius.circular(
            26,
          ),
          border: Border.all(
            color: Colors.white10,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF16A085,
              ).withOpacity(
                0.08,
              ),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(
                      0xFF16A085,
                    ).withOpacity(
                      0.9,
                    ),
                    const Color(
                      0xFF0E6655,
                    ),
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  18,
                ),
              ),
              child: Icon(
                icon,
                color: Colors.black,
                size: 28,
              ),
            ),
            const SizedBox(
              width: 18,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(
                        0xFFEAE2C6,
                      ),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white38,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget socialButton({
    required String svgPath,
    required Color iconColor,
    required String url,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(
        20,
      ),
      onTap: () {
        openLink(url);
      },
      child: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(
            0.03,
          ),
          borderRadius: BorderRadius.circular(
            20,
          ),
          border: Border.all(
            color: Colors.white10,
          ),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(
                0.18,
              ),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: SvgPicture.asset(
            svgPath,
            width: 36,
            height: 36,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF050505,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF000000),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(
              22,
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 8,
                ),

                /// LOGO
                Container(
                  padding: const EdgeInsets.all(
                    24,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(
                          0xFF16A085,
                        ).withOpacity(
                          0.18,
                        ),
                        Colors.white.withOpacity(
                          0.03,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      34,
                    ),
                    border: Border.all(
                      color: Colors.white10,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFF16A085,
                        ).withOpacity(
                          0.15,
                        ),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      26,
                    ),
                    child: Image.asset(
                      'assets/rcell.jpg',
                      height: 130,
                      width: 130,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 32,
                ),

                ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      colors: [
                        Color(
                          0xFFEAE2C6,
                        ),
                        Color(
                          0xFF16A085,
                        ),
                      ],
                    ).createShader(
                      bounds,
                    );
                  },
                  child: const Text(
                    "ROBO CELL",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                const Text(
                  "DEPARTMENT OF ROBOTICS &\nARTIFICIAL INTELLIGENCE",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 2,
                    height: 1.6,
                  ),
                ),

                const SizedBox(
                  height: 40,
                ),

                /// ABOUT
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(
                    28,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(
                          0xFF16A085,
                        ).withOpacity(
                          0.18,
                        ),
                        Colors.white.withOpacity(
                          0.02,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      30,
                    ),
                    border: Border.all(
                      color: Colors.white10,
                    ),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        "ABOUT ROBO CELL",
                        style: TextStyle(
                          color: Color(
                            0xFF16A085,
                          ),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        height: 22,
                      ),
                      Text(
                        "Robo Cell is the premier club under the Department of Robotics & Artificial Intelligence (RAI) at the Bangalore Institute of Technology. The club bridges academic learning with cutting-edge innovation through workshops, hackathons, research initiatives, industrial collaborations, and real-world engineering projects.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          height: 1.8,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 34,
                ),

                /// LOCATION
                infoTile(
                  icon: Icons.location_on_rounded,
                  title: "LOCATION",
                  value:
                      "Bangalore Institute of Technology, Krishna Rajendra Rd, Bengaluru",
                  onTap: () {
                    openLink(
                      "https://maps.google.com/?q=Bangalore+Institute+of+Technology+Krishna+Rajendra+Road+Bengaluru",
                    );
                  },
                ),

                /// DEPARTMENT
                infoTile(
                  icon: Icons.memory_rounded,
                  title: "DEPARTMENT",
                  value: "Robotics & Artificial Intelligence",
                  onTap: () {
                    openLink(
                      "https://bit-bangalore.edu.in/robotics-about",
                    );
                  },
                ),

                /// EMAIL
                infoTile(
                  icon: Icons.email_rounded,
                  title: "OFFICIAL EMAIL",
                  value: "robocellbit@gmail.com",
                  onTap: () {
                    openMail();
                  },
                ),

                const SizedBox(
                  height: 36,
                ),

                /// SOCIALS
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 28,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(
                          0.05,
                        ),
                        Colors.white.withOpacity(
                          0.02,
                        ),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      30,
                    ),
                    border: Border.all(
                      color: Colors.white10,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "FOLLOW ROBO CELL",
                        style: TextStyle(
                          color: Color(
                            0xFF16A085,
                          ),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          socialButton(
                            svgPath: AppIcons.x,
                            iconColor: Colors.white,
                            url: "https://x.com/bitrobocell",
                          ),
                          socialButton(
                            svgPath: AppIcons.instagram,
                            iconColor: const Color(
                              0xFFE1306C,
                            ),
                            url: "https://www.instagram.com/robo.cell.bit/",
                          ),
                          socialButton(
                            svgPath: AppIcons.linkedin,
                            iconColor: const Color(
                              0xFF0077B5,
                            ),
                            url:
                                "https://www.linkedin.com/in/robo-cell-bit-256975365/",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 36,
                ),

                /// BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF16A085,
                      ),
                      elevation: 12,
                      shadowColor: const Color(
                        0xFF16A085,
                      ).withOpacity(
                        0.4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          22,
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            return const CommitteesPage();
                          },
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.groups_rounded,
                      color: Colors.black,
                    ),
                    label: const Text(
                      "VIEW COMMITTEES",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 50,
                ),

                /// FOOTER
                const Text(
                  "DEVELOPED BY",
                  style: TextStyle(
                    color: Colors.grey,
                    letterSpacing: 2,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                const Text(
                  "TECH TRYANUKA",
                  style: TextStyle(
                    color: Color(
                      0xFF16A085,
                    ),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    fontSize: 17,
                  ),
                ),

                const SizedBox(
                  height: 60,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
