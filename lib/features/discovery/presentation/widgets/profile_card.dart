import 'package:flutter/material.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:student_dating_app/features/discovery/domain/profile_card_model.dart';
import 'package:student_dating_app/features/discovery/presentation/widgets/components/intent_badge_widget.dart';
import 'package:student_dating_app/features/discovery/presentation/widgets/components/primary_photo_widget.dart';
import 'package:student_dating_app/features/discovery/presentation/widgets/profile_detail_bottom_sheet.dart';

class ProfileCard extends StatefulWidget {
  final ProfileCardModel profile;

  const ProfileCard({super.key, required this.profile});

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  void _showDetails() {
    ProfileDetailBottomSheet.show(context, widget.profile);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showDetails,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: PrimaryPhotoWidget(
                imageUrl:
                    widget.profile.photoUrls.isNotEmpty
                        ? widget.profile.photoUrls.first
                        : AppTheme.defaultUserImage,
                blurLevel: AppTheme.getRevealBlurLevel(
                    0.0), // Stage 0/1: Significant softness
                onTap: _showDetails,
              ),
            ),
            // Gentle scrim strictly for bottom text readability, not a heavy overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 250,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // Top Left Intent Badge
            Positioned(
              top: 20,
              left: 20,
              child: IntentBadgeWidget(intent: widget.profile.primaryIntent),
            ),
            // Bottom Information
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name, Age, Verified
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.profile.name}, ${widget.profile.age}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.verified_rounded,
                        color: Colors.blueAccent,
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Department & University
                  Text(
                    '${widget.profile.major} @ ${widget.profile.university}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Interests Chips
                  if (widget.profile.interests.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          widget.profile.interests.take(3).map((interest) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                interest,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  const SizedBox(height: 16),
                  // Personality Hook
                  if (widget.profile.bio.isNotEmpty)
                    Text(
                      '"${widget.profile.bio}"',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
