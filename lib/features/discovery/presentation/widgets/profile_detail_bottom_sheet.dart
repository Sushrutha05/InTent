import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:student_dating_app/features/discovery/domain/profile_card_model.dart';
import 'package:student_dating_app/features/discovery/presentation/providers/discovery_provider.dart';

import 'package:student_dating_app/features/discovery/presentation/widgets/components/primary_photo_widget.dart';

class ProfileDetailBottomSheet extends ConsumerStatefulWidget {
  final ProfileCardModel profile;
  final double unblurProgress;

  const ProfileDetailBottomSheet({
    super.key,
    required this.profile,
    this.unblurProgress = 0.0,
  });

  @override
  ConsumerState<ProfileDetailBottomSheet> createState() =>
      _ProfileDetailBottomSheetState();

  static void show(
    BuildContext context,
    ProfileCardModel profile, {
    double unblurProgress = 0.0,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ProfileDetailBottomSheet(
            profile: profile,
            unblurProgress: unblurProgress,
          ),
    );
  }
}

class _ProfileDetailBottomSheetState
    extends ConsumerState<ProfileDetailBottomSheet> {
  double _currentExtent = 0.75;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        setState(() {
          _currentExtent = notification.extent;
        });
        return true;
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        expand: false,
        builder: (context, scrollController) {
          final isFullScreen = _currentExtent > 0.95;
          final borderRadius =
              (1.0 - ((_currentExtent - 0.75) / 0.25).clamp(0.0, 1.0)) * 32;
          final handleOpacity =
              (1.0 - ((_currentExtent - 0.75) / 0.15).clamp(0.0, 1.0));

          return Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(borderRadius),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    // Dynamic Photo Header
                    SliverAppBar(
                      expandedHeight: 400,
                      automaticallyImplyLeading: false,
                      backgroundColor: AppTheme.backgroundColor,
                      elevation: 0,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: PrimaryPhotoWidget(
                          imageUrl:
                              widget.profile.photoUrls.isNotEmpty
                                  ? widget.profile.photoUrls.first
                                  : AppTheme.defaultUserImage,
                          blurLevel: AppTheme.getRevealBlurLevel(
                            widget.unblurProgress,
                          ),
                          onTap: () {}, // No action needed here
                        ),
                      ),
                    ),

                    // Profile Content
                    SliverList(
                      delegate: SliverChildListDelegate([
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header: Name & Uni
                              Text(
                                '${widget.profile.name}, ${widget.profile.age}',
                                style: Theme.of(
                                  context,
                                ).textTheme.displayLarge?.copyWith(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.profile.major} @ ${widget.profile.university}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Bio Section
                              _buildSectionTitle('About Me'),
                              const SizedBox(height: 8),
                              Text(
                                widget.profile.bio.isNotEmpty
                                    ? widget.profile.bio
                                    : "No bio provided yet.",
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(
                                  height: 1.5,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Vibe Prompt Section
                              if (widget.profile.vibePrompt.isNotEmpty) ...[
                                _buildSectionTitle('The Vibe'),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppTheme.dividerColor,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.profile.vibePrompt,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        widget.profile.vibeAnswer.isNotEmpty
                                            ? widget.profile.vibeAnswer
                                            : "No answer yet...",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.textPrimary,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],

                              // Interests Section
                              _buildSectionTitle('Interests'),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    widget.profile.interests.map((interest) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: AppTheme.dividerColor,
                                          ),
                                        ),
                                        child: Text(
                                          interest,
                                          style: const TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                              const SizedBox(height: 32),

                              // Gallery Section (Unified)
                              if (widget.unblurProgress >= 1.0 &&
                                  widget.profile.photoUrls.length > 1) ...[
                                _buildSectionTitle('Gallery'),
                                const SizedBox(height: 12),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: 0.75,
                                      ),
                                  itemCount: widget.profile.photoUrls.length,
                                  itemBuilder: (context, index) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.profile.photoUrls[index],
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(color: Colors.white),
                                      ),
                                      errorWidget: (context, url, error) => const Icon(
                                        Icons.broken_image,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    );
                                  },
                                ),
                              ] else ...[
                                // Locked Gallery Indicator
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceSolid.withValues(
                                      alpha: 0.5,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.lock_outline_rounded,
                                        color: AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 16),
                                      const Expanded(
                                        child: Text(
                                          'Photos become clearer as conversations grow.',
                                          style: TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 32),
                              // Report / Block Section
                              const Divider(),
                              const SizedBox(height: 16),
                              Center(
                                child: TextButton.icon(
                                  onPressed: () => _showBlockDialog(context),
                                  icon: const Icon(
                                    Icons.report_problem_outlined,
                                    color: Colors.redAccent,
                                    size: 20,
                                  ),
                                  label: const Text(
                                    'Block & Report User',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 48),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),

                // Handle (Visual indicator for dragging) - Fades out on expand
                if (handleOpacity > 0.05)
                  IgnorePointer(
                    child: Opacity(
                      opacity: handleOpacity,
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.textMuted.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Close Button - Appears on expand
                if (isFullScreen)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    right: 20,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showBlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Block & Report'),
            content: const Text(
              'Are you sure you want to block this user? They will no longer see your profile and you will no longer see theirs. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await ref
                        .read(discoveryNotifierProvider.notifier)
                        .blockUser(widget.profile.id);

                    if (context.mounted) {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Close bottom sheet
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'User blocked and reported successfully',
                          ),
                          backgroundColor: Colors.black87,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  }
                },
                child: const Text(
                  'Block User',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: AppTheme.textMuted,
      ),
    );
  }
}
