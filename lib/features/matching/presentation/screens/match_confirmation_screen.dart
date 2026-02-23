import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:student_dating_app/features/discovery/domain/profile_card_model.dart';
import 'package:student_dating_app/features/discovery/presentation/widgets/progressive_blur_image.dart';

class MatchConfirmationScreen extends StatelessWidget {
  final ProfileCardModel matchedProfile;

  const MatchConfirmationScreen({super.key, required this.matchedProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background: heavily blurred version of the matched profile's photo
          ProgressiveBlurImage(
            imageUrl:
                matchedProfile.photoUrls.isNotEmpty
                    ? matchedProfile.photoUrls.first
                    : 'https://via.placeholder.com/600x800',
            blurLevel: 1.0,
            maxBlurSigma: 40.0,
          ),

          // Dark overlay to make text pop
          Container(color: Colors.black.withValues(alpha: 0.6)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // "It's a Match!" text with styling
                  Text(
                    "It's a Match!",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppTheme.accentColor,
                      fontSize: 48,
                      fontStyle: FontStyle.italic,
                      shadows: [
                        Shadow(
                          color: AppTheme.accentColor.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You and \${matchedProfile.name} have liked each other.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 48),

                  // Side-by-side circular avatars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Current User (Placeholder for now, in a real app would be the auth user's profile)
                      _buildAvatar(
                        imageUrl:
                            'https://via.placeholder.com/150', // Mock current user
                        blurLevel: 0.0,
                      ),
                      const SizedBox(width: -20), // Overlap them slightly
                      // Matched User (Slightly unblurred compared to discovery feed!)
                      _buildAvatar(
                        imageUrl:
                            matchedProfile.photoUrls.isNotEmpty
                                ? matchedProfile.photoUrls.first
                                : 'https://via.placeholder.com/150',
                        blurLevel:
                            0.6, // Decreased blur from 0.9 to 0.6 to reward the match!
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Action Buttons
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to chat
                      // GoRouter path will be e.g. /chat/:id
                      context.pushReplacement('/chat/\${matchedProfile.id}');
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(60),
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Send a Message'),
                  ),
                  const SizedBox(height: 16),

                  OutlinedButton(
                    onPressed: () {
                      // Return to discovery feed
                      context.pop();
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(60),
                      side: const BorderSide(color: Colors.white70, width: 2),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Keep Swiping'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar({required String imageUrl, required double blurLevel}) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: ProgressiveBlurImage(imageUrl: imageUrl, blurLevel: blurLevel),
      ),
    );
  }
}
