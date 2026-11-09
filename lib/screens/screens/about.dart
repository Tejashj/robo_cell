import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../constants/app_icons.dart';
import '../../theme/app_theme.dart';
import '../../theme/design_system.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/skeleton_loader.dart';
import 'committees.dart';

class RoboTheme {
  static const primary = AppColors.primaryCyan;
  static const secondary = AppColors.secondaryTeal;
  static const bg = AppColors.background;
  static const text = AppColors.accentGold;

  static BoxDecoration glass([double radius = 28]) => BoxDecoration(
    color: AppColors.surfaceGlass,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.borderSubtle),
  );
}

class OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final rect = Rect.fromCircle(center: center, radius: 76);

    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.05);

    canvas.drawCircle(center, 76, bgPaint);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          RoboTheme.primary.withValues(alpha: 0.15),
          RoboTheme.primary,
          Colors.tealAccent,
          RoboTheme.primary,
          Colors.transparent,
        ],
      ).createShader(rect);

    canvas.drawArc(rect, 0, 6.283, false, paint);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          RoboTheme.primary.withValues(alpha: 0.6),
          Colors.tealAccent.withValues(alpha: 0.8),
          Colors.transparent,
        ],
      ).createShader(rect);

    canvas.drawArc(rect, 0, 6.283, false, glowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class AboutRoboCellPage extends StatefulWidget {
  const AboutRoboCellPage({super.key});

  @override
  State<AboutRoboCellPage> createState() => _AboutRoboCellPageState();
}

class _AboutRoboCellPageState extends State<AboutRoboCellPage>
    with TickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
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
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  children: [
                    _hero(),
                    const SizedBox(height: AppSpacing.xxl),
                    _glass(
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionTitle("ABOUT ROBO CELL"),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            "Robo Cell is the premier innovation club under the Department of Robotics & Artificial Intelligence at Bangalore Institute of Technology. We build intelligent systems, conduct workshops, organize events, and foster innovation in robotics, AI, automation, and engineering.",
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.8,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _infoTile(
                      Icons.location_on_rounded,
                      "LOCATION",
                      "BIT, K.R. Road, Bengaluru",
                      () => launchUrl(
                        Uri.parse(
                          "geo:12.9535,77.5724?q=Bangalore+Institute+of+Technology",
                        ),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                    _infoTile(
                      Icons.precision_manufacturing_rounded,
                      "DEPARTMENT",
                      "Robotics & Artificial Intelligence",
                      () => launchUrl(
                        Uri.parse(
                          "https://bit-bangalore.edu.in/robotics-about",
                        ),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                    _infoTile(
                      Icons.alternate_email_rounded,
                      "OFFICIAL EMAIL",
                      "robocellbit@gmail.com",
                      () => launchUrl(
                        Uri(scheme: 'mailto', path: 'robocellbit@gmail.com'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _socials(),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      text: "VIEW COMMITTEES",
                      width: double.infinity,
                      icon: Icons.groups_rounded,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CommitteesPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Text(
                          "EVENT GALLERY",
                          style: TextStyle(
                            color: RoboTheme.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const GalleryHorizontalList(),
                    const SizedBox(height: AppSpacing.xxxl),
                    _builtWithLove(),
                    const SizedBox(height: AppSpacing.xxl),
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
              left: -80 + (_anim.value * 40),
              child: _glow(300, RoboTheme.primary.withValues(alpha: 0.18)),
            ),
            Positioned(
              bottom: -150,
              right: -80 + (_anim.value * 60),
              child: _glow(340, Colors.tealAccent.withValues(alpha: 0.08)),
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
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 140, sigmaY: 140),
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
                    angle: _anim.value * 6.283,
                    child: CustomPaint(
                      size: const Size(170, 170),
                      painter: OrbitPainter(),
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
                      color: RoboTheme.primary.withValues(alpha: 0.35),
                      blurRadius: 35,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset('assets/rcell.jpg', fit: BoxFit.cover),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [RoboTheme.text, RoboTheme.primary],
          ).createShader(bounds),
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
        const SizedBox(height: AppSpacing.md),
        const Text(
          "DEPARTMENT OF ROBOTICS & ARTIFICIAL INTELLIGENCE",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            height: 1.6,
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _glass({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: RoboTheme.glass(),
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
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: _glass(
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  color: RoboTheme.primary.withValues(alpha: 0.12),
                  border: Border.all(
                    color: RoboTheme.primary.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: RoboTheme.primary, size: 22),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: RoboTheme.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textMuted,
                size: 13,
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
          const _SectionTitle("FOLLOW ROBO CELL"),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _social(AppIcons.x, "https://x.com/bitrobocell"),
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

  Widget _social(String icon, String url) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: () =>
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Container(
        width: 64,
        height: 64,
        decoration: RoboTheme.glass(AppRadius.lg),
        child: Center(child: SvgPicture.asset(icon, width: 28, height: 28)),
      ),
    );
  }

  Widget _builtWithLove() {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      onTap: () => launchUrl(
        Uri.parse(
          "https://zeyhfgtoujfunlvwfauj.supabase.co/storage/v1/object/public/Creator/Screenshot%202025-07-14%20231346.png",
        ),
        mode: LaunchMode.externalApplication,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.04),
                  RoboTheme.primary.withValues(alpha: 0.04),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Built with",
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: RoboTheme.primary.withValues(alpha: 0.12),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: RoboTheme.primary,
                        size: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      RoboTheme.text,
                      RoboTheme.primary,
                      Colors.tealAccent,
                    ],
                  ).createShader(bounds),
                  child: const Text(
                    "TECH TRYANUKA",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
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
        fontSize: 14,
      ),
    );
  }
}

class GalleryHorizontalList extends StatefulWidget {
  const GalleryHorizontalList({super.key});

  @override
  State<GalleryHorizontalList> createState() => _GalleryHorizontalListState();
}

class _GalleryHorizontalListState extends State<GalleryHorizontalList> {
  late final PageController _controller;
  List<Map<String, dynamic>> _data = [];
  bool loading = true;
  final int _initialPage = 1000;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: 0.65,
      initialPage: _initialPage,
    );
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final res = await Supabase.instance.client
          .from('event_images')
          .select('event_name, image_url, google_drive_link');

      if (mounted) {
        setState(() {
          _data = List<Map<String, dynamic>>.from(res as List);
          loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        height: 210,
        child: Center(
          child: CircularProgressIndicator(color: RoboTheme.primary),
        ),
      );
    }

    if (_data.isEmpty) {
      return const AppEmptyState(
        status: AppStateStatus.empty,
        title: "No Gallery Images",
        description: "Event gallery photos will appear here.",
      );
    }

    return SizedBox(
      height: 250,
      child: PageView.builder(
        controller: _controller,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (_, index) {
          final i = index % _data.length;
          final currentPage = _controller.hasClients
              ? _controller.page ?? _initialPage.toDouble()
              : _initialPage.toDouble();
          final diff = (index - currentPage).abs();
          final active = diff < 0.5;

          final matrix = Matrix4.identity();
          matrix.setEntry(1, 3, active ? -8.0 : 10.0);
          final scaleFactor = active ? 1.0 : 0.82;
          matrix.scaleByDouble(scaleFactor, scaleFactor, 1.0, 1.0);

          return AnimatedContainer(
            duration: AppDurations.normal,
            curve: AppCurves.easeOut,
            transform: matrix,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                onTap: () => launchUrl(
                  Uri.parse(_data[i]['google_drive_link'] ?? ''),
                  mode: LaunchMode.externalApplication,
                ),
                child: AnimatedContainer(
                  duration: AppDurations.normal,
                  curve: AppCurves.easeOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: RoboTheme.primary.withValues(alpha: 0.30),
                              blurRadius: 45,
                              spreadRadius: -12,
                              offset: const Offset(0, 26),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.55),
                              blurRadius: 28,
                              spreadRadius: -6,
                              offset: const Offset(0, 18),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.22),
                              blurRadius: 14,
                              spreadRadius: -8,
                              offset: const Offset(0, 10),
                            ),
                          ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: _data[i]['image_url'] ?? '',
                          fit: BoxFit.cover,
                          memCacheWidth: 450,
                          placeholder: (c, u) => const SkeletonBox(
                            height: double.infinity,
                            borderRadius: 24,
                          ),
                          errorWidget: (c, u, e) => const Icon(
                            Icons.broken_image_rounded,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.84),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 14,
                          right: 14,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.open_in_new_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                  border: Border.all(
                                    color: AppColors.borderSubtle,
                                  ),
                                ),
                                child: Text(
                                  _data[i]['event_name'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
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
