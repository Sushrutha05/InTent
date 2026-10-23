import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:student_dating_app/features/profile/presentation/providers/user_profile_provider.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: profileState.when(
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
        error: (err, st) => Center(child: Text('Error: $err')),
        data: (profile) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Premium App Bar
              SliverAppBar(
                backgroundColor: AppTheme.backgroundColor,
                elevation: 0,
                pinned: true,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(
                    Icons.settings_rounded,
                    color: AppTheme.textPrimary,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push('/settings');
                  },
                ),
                title: const Text(
                  'My Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit_rounded,
                        color: AppTheme.primaryColor,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        context.push('/profile/edit');
                      },
                    ),
                  ),
                ],
              ),

              // Profile Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Clean, rounded card header with drop shadow
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.08,
                              ),
                              blurRadius: 30,
                              spreadRadius: 0,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Profile Image
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Hero(
                                tag: 'profile_image',
                                child: Container(
                                  height: 340,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: AppTheme.surfaceSolid,
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child:
                                      profile.photoUrls.isNotEmpty
                                          ? CachedNetworkImage(
                                            memCacheHeight: 150,
                                            memCacheWidth: 150,
                                            imageUrl: profile.photoUrls.first,
                                            fit: BoxFit.cover,
                                            placeholder:
                                                (context, url) =>
                                                    Shimmer.fromColors(
                                                      baseColor:
                                                          Colors.grey[200]!,
                                                      highlightColor:
                                                          Colors.grey[50]!,
                                                      child: Container(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(
                                                      Icons.error_outline,
                                                      color: AppTheme.textMuted,
                                                    ),
                                          )
                                          : const Center(
                                            child: Icon(
                                              Icons.person_rounded,
                                              size: 100,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                ),
                              ),
                            ),

                            // Basic Info
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                16,
                                20,
                                24,
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${profile.name}, ${profile.age}',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.textPrimary,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.school_rounded,
                                          size: 16,
                                          color: AppTheme.primaryColor,
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            '${profile.major} @ ${profile.university}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: AppTheme.primaryColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Bio Section (Read Only)
                      if (profile.bio.isNotEmpty) ...[
                        const Text(
                          'ABOUT ME',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppTheme.dividerColor.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            profile.bio,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Additional Photos
                      if (profile.photoUrls.length > 1) ...[
                        const Text(
                          'GALLERY',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 240,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: profile.photoUrls.length - 1,
                            itemBuilder: (context, index) {
                              final photoUrl = profile.photoUrls[index + 1];
                              return Padding(
                                padding: const EdgeInsets.only(right: 16.0),
                                child: Container(
                                  width: 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: AppTheme.surfaceSolid,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: CachedNetworkImage(
                                    imageUrl: photoUrl,
                                    fit: BoxFit.cover,
                                    placeholder:
                                        (context, url) => Shimmer.fromColors(
                                          baseColor: Colors.grey[200]!,
                                          highlightColor: Colors.grey[50]!,
                                          child: Container(color: Colors.white),
                                        ),
                                    errorWidget:
                                        (context, url, error) => const Icon(
                                          Icons.error_outline,
                                          color: AppTheme.textMuted,
                                        ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      const SizedBox(
                        height: 120,
                      ), // Bottom padding for navigation bar
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
