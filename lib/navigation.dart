import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'screens/screens/feedpage.dart';
import 'screens/screens/home.dart';
import 'screens/screens/meetings.dart';
import 'screens/screens/about.dart';
import 'screens/screens/profile.dart';
import 'theme/design_system.dart';
import 'widgets/app_snackbar.dart';

class _NavItemData {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  const _NavItemData({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}

class MainNavigation extends StatefulWidget {
  final Map<String, dynamic> user;

  const MainNavigation({super.key, required this.user});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;
  late final bool isGuest;
  late final List<Widget> pages;
  late final List<_NavItemData> navItems;

  @override
  void initState() {
    super.initState();
    isGuest =
        widget.user['role']?.toString().toUpperCase() == 'GUEST' ||
        widget.user['id'] == 'guest_user';

    if (isGuest) {
      pages = [
        HomeContent(
          user: widget.user,
          onNavigateToMeetings: () {
            AppSnackBar.show(
              context,
              message:
                  "Meetings are restricted to registered Robo Cell members.",
              type: SnackBarType.info,
            );
          },
          onNavigateToFeed: () {
            setState(() {
              currentIndex = 1;
            });
          },
        ),
        FeedPage(user: widget.user),
        const AboutRoboCellPage(),
      ];

      navItems = const [
        _NavItemData(
          activeIcon: Icons.home_rounded,
          inactiveIcon: Icons.home_outlined,
          label: "Home",
        ),
        _NavItemData(
          activeIcon: Icons.newspaper_rounded,
          inactiveIcon: Icons.newspaper_outlined,
          label: "Feed",
        ),
        _NavItemData(
          activeIcon: Icons.info_rounded,
          inactiveIcon: Icons.info_outline_rounded,
          label: "About",
        ),
      ];
    } else {
      pages = [
        HomeContent(
          user: widget.user,
          onNavigateToMeetings: () {
            setState(() {
              currentIndex = 2;
            });
          },
          onNavigateToFeed: () {
            setState(() {
              currentIndex = 1;
            });
          },
        ),
        FeedPage(user: widget.user),
        MeetingsPage(user: widget.user),
        const AboutRoboCellPage(),
      ];

      navItems = const [
        _NavItemData(
          activeIcon: Icons.home_rounded,
          inactiveIcon: Icons.home_outlined,
          label: "Home",
        ),
        _NavItemData(
          activeIcon: Icons.newspaper_rounded,
          inactiveIcon: Icons.newspaper_outlined,
          label: "Feed",
        ),
        _NavItemData(
          activeIcon: Icons.groups_rounded,
          inactiveIcon: Icons.groups_outlined,
          label: "Meetings",
        ),
        _NavItemData(
          activeIcon: Icons.info_rounded,
          inactiveIcon: Icons.info_outline_rounded,
          label: "About",
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.user['photo_url'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.chip),
              border: Border.all(
                color: AppColors.primaryEmerald.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryEmerald.withValues(alpha: 0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.chip - 1),
              child: Image.asset('assets/rcell.jpg', fit: BoxFit.cover),
            ),
          ),
        ),
        title: const Text(
          "ROBO CELL",
          style: TextStyle(
            color: AppColors.headingGold,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(user: widget.user),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryEmerald, AppColors.secondaryTeal],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryEmerald.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.surface,
                  backgroundImage: photo != null && photo.toString().isNotEmpty
                      ? CachedNetworkImageProvider(photo.toString())
                      : null,
                  child: photo == null || photo.toString().isEmpty
                      ? const Icon(
                          Icons.person_rounded,
                          size: 18,
                          color: AppColors.primaryEmerald,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryEmerald.withValues(alpha: 0.35),
                  AppColors.secondaryTeal.withValues(alpha: 0.15),
                  AppColors.primaryEmerald.withValues(alpha: 0.2),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryEmerald.withValues(alpha: 0.25),
                  blurRadius: 24,
                  spreadRadius: -2,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.85),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(27),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    height: 68,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F13).withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(27),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(navItems.length, (index) {
                        final item = navItems[index];
                        return _navItem(
                          index,
                          item.activeIcon,
                          item.inactiveIcon,
                          item.label,
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => currentIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.fastOutSlowIn,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryEmerald.withValues(alpha: 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryEmerald.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryEmerald.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: -1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected
                    ? AppColors.primaryEmerald
                    : AppColors.textMuted,
                size: 22,
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 220),
              firstCurve: Curves.easeOutCubic,
              secondCurve: Curves.easeInCubic,
              crossFadeState: isSelected
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.primaryEmerald,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
