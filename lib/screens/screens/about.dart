import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../constants/app_icons.dart';
import '../../theme/app_theme.dart';
import 'committees.dart';

class RoboTheme {
  static const primary = Color(0xFF16A085);
  static const secondary = Color(0xFF0E6655);
  static const bg = Color(0xFF030303);
  static const text = Color(0xFFD8CFB4);

  static BoxDecoration glass([double radius = 28]) => BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      );
}

class OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final rect = Rect.fromCircle(
      center: center,
      radius: 76,
    );

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.05);

    canvas.drawCircle(center, 76, bgPaint);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          RoboTheme.primary.withOpacity(0.15),
          RoboTheme.primary,
          Colors.tealAccent,
          RoboTheme.primary,
          Colors.transparent,
        ],
      ).createShader(rect);

    canvas.drawArc(
      rect,
      0,
      6.283,
      false,
      paint,
    );

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        18,
      )
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          RoboTheme.primary.withOpacity(0.6),
          Colors.tealAccent.withOpacity(0.8),
          Colors.transparent,
        ],
      ).createShader(rect);

    canvas.drawArc(
      rect,
      0,
      6.283,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class AboutRoboCellPage extends StatefulWidget {
  const AboutRoboCellPage({super.key});

  @override
  State<AboutRoboCellPage> createState() =>
      _AboutRoboCellPageState();
}

class _AboutRoboCellPageState
    extends State<AboutRoboCellPage>
    with TickerProviderStateMixin {
  late final AnimationController _anim =
      AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.darkTheme,
      child: Scaffold(
        backgroundColor: RoboTheme.bg,
        body: Stack(
          children: [
            _background(),

            SafeArea(
              child: SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 18,
                ),
                child: Column(
                  children: [
                    _hero(),

                    const SizedBox(height: 40),

                    _glass(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: const [
                          _SectionTitle(
                            "ABOUT ROBO CELL",
                          ),
                          SizedBox(height: 18),
                          Text(
                            "Robo Cell is the premier innovation club under the Department of Robotics & Artificial Intelligence at Bangalore Institute of Technology. We build intelligent systems, conduct workshops, organize events, and foster innovation in robotics, AI, automation, and engineering.",
                            textAlign:
                                TextAlign.justify,
                            style: TextStyle(
                              color:
                                  Colors.white70,
                              height: 1.9,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _infoTile(
                      Icons.location_on_rounded,
                      "LOCATION",
                      "BIT, K.R. Road, Bengaluru",
                      () => launchUrl(
                        Uri.parse(
                          "geo:12.9535,77.5724?q=Bangalore+Institute+of+Technology",
                        ),
                        mode: LaunchMode
                            .externalApplication,
                      ),
                    ),

                    _infoTile(
                      Icons.memory_rounded,
                      "DEPARTMENT",
                      "Robotics & Artificial Intelligence",
                      () => launchUrl(
                        Uri.parse(
                          "https://bit-bangalore.edu.in/robotics-about",
                        ),
                        mode: LaunchMode
                            .externalApplication,
                      ),
                    ),

                    _infoTile(
                      Icons.email_rounded,
                      "OFFICIAL EMAIL",
                      "robocellbit@gmail.com",
                      () => launchUrl(
                        Uri(
                          scheme: 'mailto',
                          path:
                              'robocellbit@gmail.com',
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    _socials(),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        style: ElevatedButton
                            .styleFrom(
                          backgroundColor:
                              RoboTheme.primary,
                          foregroundColor:
                              Colors.black,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              22,
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const CommitteesPage(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.groups_rounded,
                        ),
                        label: const Text(
                          "VIEW COMMITTEES",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w900,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 44),

                    const Align(
                      alignment:
                          Alignment.centerLeft,
                      child: Padding(
                        padding:
                            EdgeInsets.only(
                          left: 4,
                        ),
                        child: Text(
                          "EVENT GALLERY",
                          style: TextStyle(
                            color:
                                RoboTheme.primary,
                            fontSize: 15,
                            fontWeight:
                                FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const GalleryHorizontalList(),

                    const SizedBox(height: 70),

                    _builtWithLove(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _background() {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Stack(
          children: [
            Positioned(
              top: -120,
              left: -80 +
                  (_anim.value * 40),
              child: _glow(
                300,
                RoboTheme.primary
                    .withOpacity(0.18),
              ),
            ),
            Positioned(
              bottom: -150,
              right: -80 +
                  (_anim.value * 60),
              child: _glow(
                340,
                Colors.tealAccent
                    .withOpacity(0.08),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _glow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 140,
          sigmaY: 140,
        ),
        child: const SizedBox(),
      ),
    );
  }

  Widget _hero() {
    return Column(
      children: [
        SizedBox(
          width: 170,
          height: 170,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _anim,
                builder: (_, __) {
                  return Transform.rotate(
                    angle:
                        _anim.value * 6.283,
                    child: CustomPaint(
                      size: const Size(
                        170,
                        170,
                      ),
                      painter:
                          OrbitPainter(),
                    ),
                  );
                },
              ),

              Container(
                width: 138,
                height: 138,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: RoboTheme.primary
                          .withOpacity(0.35),
                      blurRadius: 35,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/rcell.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        ShaderMask(
          shaderCallback: (bounds) =>
              const LinearGradient(
            colors: [
              RoboTheme.text,
              RoboTheme.primary,
            ],
          ).createShader(bounds),
          child: const Text(
            "ROBO CELL",
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              letterSpacing: 5,
            ),
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          "DEPARTMENT OF ROBOTICS & ARTIFICIAL INTELLIGENCE",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white60,
            height: 1.7,
            fontSize: 13,
            letterSpacing: 2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _glass({required Widget child}) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 18,
          sigmaY: 18,
        ),
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.all(28),
          decoration:
              RoboTheme.glass(),
          child: child,
        ),
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String title,
    String value,
    VoidCallback onTap,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 18,
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(26),
        onTap: onTap,
        child: _glass(
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration:
                    BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                  gradient:
                      const LinearGradient(
                    colors: [
                      RoboTheme.primary,
                      RoboTheme.secondary,
                    ],
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.black,
                  size: 28,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          const TextStyle(
                        color:
                            Colors.white38,
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style:
                          const TextStyle(
                        color:
                            RoboTheme.text,
                        fontWeight:
                            FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons
                    .arrow_forward_ios_rounded,
                color: Colors.white24,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socials() {
    return _glass(
      child: Column(
        children: [
          const _SectionTitle(
            "FOLLOW ROBO CELL",
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
            children: [
              _social(
                AppIcons.x,
                "https://x.com/bitrobocell",
              ),
              _social(
                AppIcons.instagram,
                "https://www.instagram.com/robo.cell.bit/",
              ),
              _social(
                AppIcons.linkedin,
                "https://www.linkedin.com/in/robo-cell-bit-256975365/",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _social(
    String icon,
    String url,
  ) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(22),
      onTap: () => launchUrl(
        Uri.parse(url),
        mode:
            LaunchMode.externalApplication,
      ),
      child: Container(
        width: 68,
        height: 68,
        decoration:
            RoboTheme.glass(22),
        child: Center(
          child: SvgPicture.asset(
            icon,
            width: 30,
            height: 30,
          ),
        ),
      ),
    );
  }

  Widget _builtWithLove() {
    return InkWell(
      borderRadius:
          BorderRadius.circular(32),
      onTap: () => launchUrl(
        Uri.parse("https://zeyhfgtoujfunlvwfauj.supabase.co/storage/v1/object/public/Creator/Screenshot%202025-07-14%20231346.png"),
        mode:
            LaunchMode.externalApplication,
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 18,
            sigmaY: 18,
          ),
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 20,
            ),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                32,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end:
                    Alignment.bottomRight,
                colors: [
                  Colors.white
                      .withOpacity(0.04),
                  RoboTheme.primary
                      .withOpacity(0.04),
                ],
              ),
              border: Border.all(
                color: Colors.white
                    .withOpacity(0.06),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const Text(
                      "Built with",
                      style: TextStyle(
                        color:
                            Colors.white54,
                        fontSize: 11,
                        letterSpacing: 0.8,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets
                              .all(5),
                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,
                        color: RoboTheme
                            .primary
                            .withOpacity(
                          0.12,
                        ),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color:
                            RoboTheme.primary,
                        size: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ShaderMask(
                  shaderCallback:
                      (bounds) =>
                          const LinearGradient(
                    colors: [
                      RoboTheme.text,
                      RoboTheme.primary,
                      Colors.tealAccent,
                    ],
                  ).createShader(
                    bounds,
                  ),
                  child: const Text(
                    "TECH TRYANUKA",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w900,
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: RoboTheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 3,
        fontSize: 15,
      ),
    );
  }
}

class GalleryHorizontalList
    extends StatefulWidget {
  const GalleryHorizontalList({
    super.key,
  });

  @override
  State<GalleryHorizontalList>
      createState() =>
          _GalleryHorizontalListState();
}

class _GalleryHorizontalListState
    extends State<
        GalleryHorizontalList> {
  late final PageController _controller;

  List<Map<String, dynamic>> _data =
      [];

  bool loading = true;

  final int _initialPage = 1000;

  @override
  void initState() {
    super.initState();

    _controller = PageController(
      viewportFraction: 0.60,
      initialPage: _initialPage,
    );

    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final res =
          await Supabase.instance.client
              .from('event_images')
              .select(
                'event_name, image_url, google_drive_link',
              );

      if (mounted) {
        setState(() {
          _data = List<
              Map<String,
                  dynamic>>.from(
            res as List,
          );
          loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => loading = false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        height: 210,
        child: Center(
          child:
              CircularProgressIndicator(
            color: RoboTheme.primary,
          ),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: PageView.builder(
        controller: _controller,
        physics:
            const BouncingScrollPhysics(),
        itemBuilder: (_, index) {
          final i =
              index % _data.length;

          final currentPage =
              _controller.hasClients
                  ? _controller.page ??
                      _initialPage
                          .toDouble()
                  : _initialPage
                      .toDouble();

          final diff =
              (index - currentPage)
                  .abs();

          final active =
              diff < 0.5;

          return AnimatedContainer(
            duration:
                const Duration(
              milliseconds: 320,
            ),
            curve: Curves.easeOutCubic,
            transform:
                Matrix4.identity()
                  ..translate(
                    0.0,
                    active ? -8.0 : 10.0,
                  )
                  ..scale(
                    active
                        ? 1.0
                        : 0.82,
                  ),
            child: Padding(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 8,
                vertical: 12,
              ),
              child: InkWell(
                borderRadius:
                    BorderRadius.circular(
                  30,
                ),
                onTap: () =>
                    launchUrl(
                  Uri.parse(
                    _data[i]
                        ['google_drive_link'],
                  ),
                  mode: LaunchMode
                      .externalApplication,
                ),
                child:
                    AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds: 320,
                  ),
                  curve:
                      Curves.easeOutCubic,
                  decoration:
                      BoxDecoration(
                    borderRadius:
                        BorderRadius
                            .circular(
                      30,
                    ),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: RoboTheme
                                  .primary
                                  .withOpacity(
                                0.30,
                              ),
                              blurRadius:
                                  45,
                              spreadRadius:
                                  -12,
                              offset:
                                  const Offset(
                                0,
                                26,
                              ),
                            ),
                            BoxShadow(
                              color: Colors
                                  .black
                                  .withOpacity(
                                0.55,
                              ),
                              blurRadius:
                                  28,
                              spreadRadius:
                                  -6,
                              offset:
                                  const Offset(
                                0,
                                18,
                              ),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors
                                  .black
                                  .withOpacity(
                                0.22,
                              ),
                              blurRadius:
                                  14,
                              spreadRadius:
                                  -8,
                              offset:
                                  const Offset(
                                0,
                                10,
                              ),
                            ),
                          ],
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius
                            .circular(
                      30,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl:
                              _data[i]
                                  ['image_url'],
                          fit:
                              BoxFit.cover,
                          memCacheWidth:
                              450,
                        ),
                        Container(
                          decoration:
                              BoxDecoration(
                            gradient:
                                LinearGradient(
                              begin: Alignment
                                  .topCenter,
                              end: Alignment
                                  .bottomCenter,
                              colors: [
                                Colors
                                    .transparent,
                                Colors.black
                                    .withOpacity(
                                  0.84,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 14,
                          right: 14,
                          child:
                              ClipRRect(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              16,
                            ),
                            child:
                                BackdropFilter(
                              filter:
                                  ImageFilter
                                      .blur(
                                sigmaX:
                                    14,
                                sigmaY:
                                    14,
                              ),
                              child:
                                  Container(
                                padding:
                                    const EdgeInsets
                                        .all(
                                  8,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: Colors
                                      .white
                                      .withOpacity(
                                    0.08,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    16,
                                  ),
                                ),
                                child:
                                    const Icon(
                                  Icons
                                      .open_in_new_rounded,
                                  color: Colors
                                      .white,
                                  size:
                                      16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child:
                              ClipRRect(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                            child:
                                BackdropFilter(
                              filter:
                                  ImageFilter
                                      .blur(
                                sigmaX:
                                    16,
                                sigmaY:
                                    16,
                              ),
                              child:
                                  Container(
                                padding:
                                    const EdgeInsets
                                        .all(
                                  15,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: Colors
                                      .black
                                      .withOpacity(
                                    0.24,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    20,
                                  ),
                                  border:
                                      Border
                                          .all(
                                    color:
                                        Colors.white10,
                                  ),
                                ),
                                child:
                                    Text(
                                  _data[i]
                                      [
                                      'event_name'],
                                  maxLines:
                                      1,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white,
                                    fontSize:
                                        13,
                                    fontWeight:
                                        FontWeight.w800,
                                    letterSpacing:
                                        0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}