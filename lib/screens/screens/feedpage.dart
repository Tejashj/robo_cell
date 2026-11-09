import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/app_provider.dart';
import '../../theme/design_system.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/skeleton_loader.dart';

class FeedPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const FeedPage({super.key, required this.user});

  static void showPostDetails(BuildContext context, Map<String, dynamic> post) {
    final creator = post['users'] ?? {};
    final photo = creator['photo_url'];
    final String imageUrl = post['image_url'] ?? post['photo_url'] ?? '';

    AppBottomSheet.show(
      context: context,
      title: post['title']?.toString().toUpperCase() ?? 'ANNOUNCEMENT',
      builder: (ctx) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryEmerald.withValues(
                      alpha: 0.15,
                    ),
                    backgroundImage:
                        photo != null && photo.toString().isNotEmpty
                        ? CachedNetworkImageProvider(photo.toString())
                        : null,
                    child: photo == null || photo.toString().isEmpty
                        ? const Icon(
                            Icons.person_rounded,
                            color: AppColors.primaryEmerald,
                            size: 20,
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          creator['name'] ?? 'Robo Cell Member',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          (creator['role'] ?? 'MEMBER')
                              .toString()
                              .replaceAll('_', ' ')
                              .toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primaryEmerald,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    post['created_at'] != null
                        ? post['created_at'].toString().substring(0, 10)
                        : '',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                post['content'] ?? post['description'] ?? '',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              if (imageUrl.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (c, u) =>
                        const SkeletonBox(height: 200, borderRadius: 14),
                    errorWidget: (c, u, e) => const SizedBox(),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                text: "CLOSE",
                variant: AppButtonVariant.outlined,
                width: double.infinity,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final supabase = Supabase.instance.client;
  bool posting = false;
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final Set<int> _likedPosts = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).fetchPosts();
    });
  }

  bool canPost() {
    final role = widget.user['role'].toString().toLowerCase();
    return role == 'president' ||
        role == 'vice_president' ||
        role == 'secretary' ||
        role == 'treasurer' ||
        role == 'head' ||
        role == 'co_head';
  }

  Future<void> loadPosts() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.fetchPosts(forceRefresh: true);
  }

  Future<void> createPost() async {
    if (!canPost()) {
      AppSnackBar.show(
        context,
        message:
            "Guest Mode (View Only). Log in with a Robo Cell account to post announcements.",
        type: SnackBarType.warning,
      );
      return;
    }

    if (titleController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty) {
      AppSnackBar.show(
        context,
        message: "Please enter title and content",
        type: SnackBarType.warning,
      );
      return;
    }

    setState(() {
      posting = true;
    });

    try {
      await supabase.from('posts').insert({
        'creator_id': widget.user['id'],
        'title': titleController.text.trim(),
        'content': contentController.text.trim(),
      });

      titleController.clear();
      contentController.clear();

      await loadPosts();

      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: "Post Published Successfully",
        type: SnackBarType.success,
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: e.toString(),
        type: SnackBarType.error,
      );
    }

    setState(() {
      posting = false;
    });
  }

  Widget postCard(Map<String, dynamic> post) {
    final creator = post['users'] ?? {};
    final photo = creator['photo_url'];
    final int postId = post['id'] is int ? post['id'] : post['id'].hashCode;
    final bool isLiked = _likedPosts.contains(postId);
    final String imageUrl = post['image_url'] ?? post['photo_url'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: AppCard(
        isGlass: true,
        onTap: () => FeedPage.showPostDetails(context, post),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// AUTHOR HEADER
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primaryEmerald.withValues(
                    alpha: 0.15,
                  ),
                  backgroundImage: photo != null && photo.toString().isNotEmpty
                      ? CachedNetworkImageProvider(photo.toString())
                      : null,
                  child: photo == null || photo.toString().isEmpty
                      ? const Icon(
                          Icons.person_rounded,
                          color: AppColors.primaryEmerald,
                          size: 22,
                        )
                      : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        creator['name'] ?? 'Robo Cell Member',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryEmerald.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                        ),
                        child: Text(
                          (creator['role'] ?? 'MEMBER')
                              .toString()
                              .replaceAll('_', ' ')
                              .toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primaryEmerald,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  post['created_at'] != null
                      ? post['created_at'].toString().substring(0, 10)
                      : '',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            /// TITLE & CONTENT
            if (post['title'] != null &&
                post['title'].toString().isNotEmpty) ...[
              Text(
                post['title'].toString(),
                style: const TextStyle(
                  color: AppColors.headingGold,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            Text(
              post['content'] ?? post['description'] ?? '',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),

            /// IMAGE ATTACHMENT (IF ANY)
            if (imageUrl.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card - 4),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (c, u) =>
                      const SkeletonBox(height: 200, borderRadius: 14),
                  errorWidget: (c, u, e) => const SizedBox(),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.lg),
            const Divider(color: AppColors.borderSubtle, height: 1),
            const SizedBox(height: AppSpacing.sm),

            /// LIKE, COMMENT, SHARE ACTIONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      if (isLiked) {
                        _likedPosts.remove(postId);
                      } else {
                        _likedPosts.add(postId);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isLiked
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18,
                          color: isLiked
                              ? AppColors.error
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isLiked ? "1" : "0",
                          style: TextStyle(
                            color: isLiked
                                ? AppColors.error
                                : AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    AppSnackBar.show(
                      context,
                      message: "Comments matrix active",
                      type: SnackBarType.info,
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Comment",
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    AppSnackBar.show(
                      context,
                      message: "Link copied to clipboard",
                      type: SnackBarType.info,
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.share_outlined,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Share",
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final loading = provider.isLoadingPosts;
    final posts = provider.posts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text("ROBO CELL FEED"),
        elevation: 0,
      ),
      body: loading
          ? _buildFeedSkeleton()
          : RefreshIndicator(
              color: AppColors.primaryEmerald,
              backgroundColor: AppColors.surface,
              onRefresh: loadPosts,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// CREATE POST CARD
                    if (canPost())
                      AppCard(
                        isGlass: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "ANNOUNCE TO CLUB",
                              style: TextStyle(
                                color: AppColors.headingGold,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextField(
                              controller: titleController,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                labelText: "Post Title",
                                hintText: "Title...",
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextField(
                              controller: contentController,
                              maxLines: 3,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                              decoration: const InputDecoration(
                                labelText: "Content",
                                hintText:
                                    "Write announcement or opportunity update...",
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppButton(
                              text: "PUBLISH POST",
                              width: double.infinity,
                              isLoading: posting,
                              icon: Icons.send_rounded,
                              onPressed: posting ? null : createPost,
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: AppSpacing.xl),

                    const Text(
                      "ALL POSTS",
                      style: TextStyle(
                        color: AppColors.headingGold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    if (posts.isEmpty)
                      const AppEmptyState(
                        status: AppStateStatus.empty,
                        title: "No Posts Available",
                        description:
                            "Check back later for updates and announcements.",
                      )
                    else
                      ...posts.map(postCard),

                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFeedSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 4,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SkeletonCircle(radius: 20),
                    SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 100, height: 12),
                        SizedBox(height: 6),
                        SkeletonBox(width: 60, height: 10),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
                SkeletonBox(width: double.infinity, height: 14),
                SizedBox(height: AppSpacing.sm),
                SkeletonBox(width: double.infinity, height: 14),
              ],
            ),
          ),
        );
      },
    );
  }
}
