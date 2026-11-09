import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/app_provider.dart';
import '../../theme/design_system.dart';
import '../../widgets/app_card.dart';
import '../../widgets/skeleton_loader.dart';
import 'feedpage.dart';

class HomeContent extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onNavigateToMeetings;
  final VoidCallback? onNavigateToFeed;

  const HomeContent({
    super.key,
    required this.user,
    required this.onNavigateToMeetings,
    this.onNavigateToFeed,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      provider.fetchPosts();
      provider.fetchMeetings();
    });
  }

  Future<void> initialize() async {
    if (!mounted) return;
    final provider = Provider.of<AppProvider>(context, listen: false);
    await Future.wait([
      provider.fetchPosts(forceRefresh: true),
      provider.fetchMeetings(forceRefresh: true),
    ]);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  bool _isAdmin() {
    final role = widget.user['role'].toString().toLowerCase();
    return role == 'president' ||
        role == 'secretary' ||
        role == 'joint_secretary' ||
        role == 'head';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final loading = provider.isLoadingPosts || provider.isLoadingMeetings;
    final latestPosts = provider.latestPosts;
    final meetings = provider.meetings;
    final liveMeetings = provider.liveMeetings;

    final photo = widget.user['photo_url'];
    final roleString = widget.user['role']
        .toString()
        .replaceAll('_', ' ')
        .toUpperCase();
    final firstName = (widget.user['name'] ?? 'Member')
        .toString()
        .split(' ')
        .first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: loading
          ? _buildHomeSkeleton()
          : RefreshIndicator(
              color: AppColors.primaryEmerald,
              backgroundColor: AppColors.surface,
              onRefresh: initialize,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xxxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// USER HEADER & BADGE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${_getGreeting()},",
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "$firstName 👋",
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryEmerald.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.chip,
                                ),
                                border: Border.all(
                                  color: AppColors.primaryEmerald.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                              child: Text(
                                _isAdmin() ? "ADMIN • $roleString" : roleString,
                                style: const TextStyle(
                                  color: AppColors.primaryEmerald,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.surfaceElevated,
                              backgroundImage:
                                  photo != null && photo.toString().isNotEmpty
                                  ? CachedNetworkImageProvider(photo.toString())
                                  : null,
                              child: photo == null || photo.toString().isEmpty
                                  ? const Icon(
                                      Icons.person_rounded,
                                      size: 20,
                                      color: AppColors.primaryEmerald,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    /// UPCOMING / LIVE MEETING CARD
                    const Text(
                      "UPCOMING MEETING",
                      style: TextStyle(
                        color: AppColors.headingGold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    if (meetings.isEmpty)
                      AppCard(
                        onTap: widget.onNavigateToMeetings,
                        child: const Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            SizedBox(width: AppSpacing.md),
                            Text(
                              "No meetings scheduled today",
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      () {
                        final targetMeeting = liveMeetings.isNotEmpty
                            ? liveMeetings.first
                            : meetings.first;
                        final isLive =
                            targetMeeting['attendance_enabled'] == true;
                        final timeStr =
                            targetMeeting['scheduled_at']?.toString().substring(
                              11,
                              16,
                            ) ??
                            'Scheduled';

                        return AppCard(
                          onTap: widget.onNavigateToMeetings,
                          backgroundColor: AppColors.surfaceElevated,
                          border: Border.all(
                            color: isLive
                                ? AppColors.error.withValues(alpha: 0.6)
                                : AppColors.primaryEmerald.withValues(
                                    alpha: 0.3,
                                  ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isLive
                                          ? AppColors.error.withValues(
                                              alpha: 0.15,
                                            )
                                          : AppColors.primaryEmerald.withValues(
                                              alpha: 0.15,
                                            ),
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.chip,
                                      ),
                                    ),
                                    child: Text(
                                      isLive ? "LIVE NOW" : timeStr,
                                      style: TextStyle(
                                        color: isLive
                                            ? AppColors.error
                                            : AppColors.primaryEmerald,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: AppColors.textMuted,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                targetMeeting['title']
                                        ?.toString()
                                        .toUpperCase() ??
                                    'CLUB SESSION',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                targetMeeting['agenda'] ??
                                    'Discussion and updates',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      }(),
                    ],

                    const SizedBox(height: AppSpacing.xl),

                    /// RECENT ACTIVITY FEED (Directly opens post details modal)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "RECENT ACTIVITY",
                          style: TextStyle(
                            color: AppColors.headingGold,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        if (widget.onNavigateToFeed != null)
                          GestureDetector(
                            onTap: widget.onNavigateToFeed,
                            child: const Row(
                              children: [
                                Text(
                                  "View Feed",
                                  style: TextStyle(
                                    color: AppColors.primaryEmerald,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_right_rounded,
                                  size: 16,
                                  color: AppColors.primaryEmerald,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    if (latestPosts.isEmpty)
                      const AppCard(
                        child: Center(
                          child: Text(
                            "No recent announcements available.",
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    else
                      ...latestPosts.map((post) {
                        final creator = post['users'] ?? {};

                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: AppCard(
                            onTap: () =>
                                FeedPage.showPostDetails(context, post),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppColors.primaryEmerald
                                          .withValues(alpha: 0.2),
                                      backgroundImage:
                                          creator['photo_url'] != null &&
                                              creator['photo_url']
                                                  .toString()
                                                  .isNotEmpty
                                          ? CachedNetworkImageProvider(
                                              creator['photo_url'],
                                            )
                                          : null,
                                      child:
                                          creator['photo_url'] == null ||
                                              creator['photo_url']
                                                  .toString()
                                                  .isEmpty
                                          ? const Icon(
                                              Icons.person_rounded,
                                              size: 16,
                                              color: AppColors.primaryEmerald,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            creator['name'] ??
                                                'Robo Cell Member',
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            post['category'] ?? 'ANNOUNCEMENT',
                                            style: const TextStyle(
                                              color: AppColors.primaryEmerald,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.open_in_new_rounded,
                                      size: 14,
                                      color: AppColors.textMuted,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                if (post['title'] != null &&
                                    post['title'].toString().isNotEmpty) ...[
                                  Text(
                                    post['title'].toString(),
                                    style: const TextStyle(
                                      color: AppColors.headingGold,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                                Text(
                                  post['description'] ?? post['content'] ?? '',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHomeSkeleton() {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 90, height: 12),
                  SizedBox(height: 6),
                  SkeletonBox(width: 140, height: 22),
                ],
              ),
              SkeletonCircle(radius: 20),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          SkeletonBox(width: 120, height: 14),
          SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 80, height: 14),
                SizedBox(height: 12),
                SkeletonBox(width: 180, height: 18),
                SizedBox(height: 8),
                SkeletonBox(width: double.infinity, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
