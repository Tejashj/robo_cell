import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/app_provider.dart';
import '../../theme/design_system.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/skeleton_loader.dart';

class CommitteesPage extends StatefulWidget {
  const CommitteesPage({super.key});

  @override
  State<CommitteesPage> createState() => _CommitteesPageState();
}

class _CommitteesPageState extends State<CommitteesPage> {
  int? flippedCardId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).fetchHierarchy();
    });
  }

  Color committeeColor(String committee) {
    switch (committee.toLowerCase()) {
      case 'faculty':
        return AppColors.textPrimary;
      case 'office bearers':
        return AppColors.accentGold;
      default:
        return AppColors.primaryCyan;
    }
  }

  Map<String, List<Map<String, dynamic>>> groupMembersByCommittee(
    List<Map<String, dynamic>> data,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var row in data) {
      final String committeeName = row['committee_name'] ?? 'Other';
      if (!grouped.containsKey(committeeName)) {
        grouped[committeeName] = [];
      }
      grouped[committeeName]!.add(row);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "ROBO CELL HERITAGE",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            fontSize: 18,
          ),
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingHierarchy && provider.hierarchyData.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryCyan),
            );
          }
          if (provider.hierarchyData.isEmpty) {
            return const AppEmptyState(
              status: AppStateStatus.empty,
              title: "No Hierarchy Data",
              description:
                  "Member hierarchy profiles could not be loaded at this time.",
            );
          }

          final groupedData = groupMembersByCommittee(provider.hierarchyData);

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            itemCount: groupedData.keys.length,
            itemBuilder: (context, index) {
              final String committeeName = groupedData.keys.elementAt(index);
              final List<Map<String, dynamic>> members =
                  groupedData[committeeName]!;
              final Color accentColor = committeeColor(committeeName);

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
                child: Column(
                  children: [
                    Text(
                      committeeName.toUpperCase(),
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 48,
                      height: 3,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    ...buildGeometricLayout(members, accentColor),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> buildGeometricLayout(
    List<Map<String, dynamic>> members,
    Color color,
  ) {
    final bool isOdd = members.length % 2 != 0;
    final List<Map<String, dynamic>> gridItems = isOdd
        ? members.sublist(1)
        : members;

    return [
      if (isOdd)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          child: Center(
            child: SizedBox(
              width: 165,
              height: 255,
              child: buildCard(members[0], color),
            ),
          ),
        ),
      if (gridItems.isNotEmpty)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: gridItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 16,
            childAspectRatio: 165 / 255,
          ),
          itemBuilder: (context, gridIndex) {
            return Center(
              child: SizedBox(
                width: 165,
                height: 255,
                child: buildCard(gridItems[gridIndex], color),
              ),
            );
          },
        ),
    ];
  }

  Widget buildCard(Map<String, dynamic> member, Color color) {
    final int memberId = member['id'] is int
        ? member['id']
        : member['id'].hashCode;

    return MemberCard(
      member: member,
      color: color,
      isFlipped: flippedCardId == memberId,
      onTap: () {
        setState(() {
          flippedCardId = (flippedCardId == memberId) ? null : memberId;
        });
      },
    );
  }
}

class MemberCard extends StatefulWidget {
  final Map<String, dynamic> member;
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
  State<MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<MemberCard>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: AppDurations.normal,
    );

    animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: controller, curve: AppCurves.easeInOut));
  }

  @override
  void didUpdateWidget(covariant MemberCard oldWidget) {
    super.didUpdateWidget(oldWidget);
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

  bool _isLaunchingLinkedin = false;

  Future<void> openLinkedin() async {
    if (_isLaunchingLinkedin) return;
    _isLaunchingLinkedin = true;
    HapticFeedback.lightImpact();

    try {
      String url = (widget.member['linkedin'] ?? '').toString().trim();

      if (url.isEmpty) {
        if (mounted) {
          AppSnackBar.show(
            context,
            message:
                "${widget.member['name']} HAS NOT ADDED A LINKEDIN PROFILE",
            type: SnackBarType.warning,
          );
        }
        return;
      }

      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      final Uri? uri = Uri.tryParse(url);
      if (uri == null) {
        if (mounted) {
          AppSnackBar.show(
            context,
            message: "INVALID LINKEDIN URL",
            type: SnackBarType.error,
          );
        }
        return;
      }

      final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: "FAILED TO OPEN LINKEDIN",
          type: SnackBarType.error,
        );
      }
    } finally {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        setState(() => _isLaunchingLinkedin = false);
      } else {
        _isLaunchingLinkedin = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.member['photo_url'] ?? '';
    final role = widget.member['role'] ?? 'MEMBER';
    final name = widget.member['name'] ?? '';
    final usn = widget.member['usn'] ?? 'FACULTY';

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final angle = animation.value * 3.1415926535;
        final isFront = angle < (3.1415926535 / 2);

        return GestureDetector(
          onTap: widget.onTap,
          onDoubleTap: () {
            if (!isFront) {
              openLinkedin();
            }
          },
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateY(angle),
            child: isFront
                ? frontCard(image, name, role)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(3.1415926535),
                    child: backCard(name, role, usn),
                  ),
          ),
        );
      },
    );
  }

  Widget frontCard(String image, String name, String role) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: widget.color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: AppShadows.cardElevation,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg - 1),
        child: Column(
          children: [
            Expanded(
              flex: 66,
              child: image.toString().isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (c, u) => const SkeletonBox(
                        height: double.infinity,
                        borderRadius: 16,
                      ),
                      errorWidget: (c, u, e) => fallbackAvatar(),
                    )
                  : fallbackAvatar(),
            ),
            Expanded(
              flex: 34,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                width: double.infinity,
                color: AppColors.surfaceElevated,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      name.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        role.replaceAll('_', ' ').toUpperCase(),
                        style: TextStyle(
                          color: widget.color,
                          fontWeight: FontWeight.w900,
                          fontSize: 8.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget fallbackAvatar() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.color.withValues(alpha: 0.18),
            AppColors.surface,
            AppColors.background,
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withValues(alpha: 0.08),
            ),
          ),
          Icon(
            Icons.person_rounded,
            size: 100,
            color: AppColors.textPrimary.withValues(alpha: 0.9),
          ),
          Positioned(
            top: 18,
            right: 18,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget backCard(String name, String role, String usn) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [widget.color.withValues(alpha: 0.12), AppColors.surface],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: widget.color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 4),
          CircleAvatar(
            radius: 20,
            backgroundColor: widget.color.withValues(alpha: 0.1),
            child: Icon(Icons.bolt_rounded, color: widget.color, size: 20),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            name.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            role.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              color: widget.color,
              fontWeight: FontWeight.bold,
              fontSize: 9,
            ),
          ),
          const Spacer(),
          Text(
            usn,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app_outlined, size: 10, color: widget.color),
                const SizedBox(width: 4),
                Text(
                  "DOUBLE TAP FOR LINKEDIN",
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
