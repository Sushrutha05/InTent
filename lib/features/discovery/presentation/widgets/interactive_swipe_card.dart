import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';
import 'package:student_dating_app/features/discovery/domain/profile_card_model.dart';
import 'package:student_dating_app/features/discovery/presentation/widgets/profile_card.dart';

class InteractiveSwipeCard extends StatelessWidget {
  final ProfileCardModel profile;
  final int dx;
  final int dy;

  const InteractiveSwipeCard({
    super.key,
    required this.profile,
    required this.dx,
    required this.dy,
  });

  IconData _getIntentIcon(String intent) {
    if (intent == "Feels Right") return Icons.favorite_rounded;
    if (intent == "Not My Vibe") return Icons.close_rounded;
    if (intent == "Let's Build") return Icons.bolt_rounded;
    if (intent == "Good Energy") return Icons.handshake_rounded;
    return Icons.circle;
  }

  @override
  Widget build(BuildContext context) {
    final double xPercent = dx / 100.0;
    final double yPercent = dy / 100.0;

    final double absX = xPercent.abs();
    final double absY = yPercent.abs();
    final double rawIntensity = (absX > absY ? absX : absY);
    final double intensity = rawIntensity.clamp(0.0, 1.0);

    final bool isHorizontal = absX > absY;
    
    Color overlayColor = Colors.transparent;
    String finalIntentText = "";
    Alignment lightBegin = Alignment.center;
    Alignment lightEnd = Alignment.center;

    if (isHorizontal) {
      if (xPercent > 0) {
        // Romantic - Right
        overlayColor = AppTheme.intentRomantic;
        finalIntentText = "Feels Right";
        lightBegin = Alignment.centerRight;
        lightEnd = Alignment.centerLeft;
      } else {
        // Pass - Left
        overlayColor = Colors.grey.shade400;
        finalIntentText = "Not My Vibe";
        lightBegin = Alignment.centerLeft;
        lightEnd = Alignment.centerRight;
      }
    } else {
      if (yPercent < 0) {
        // Collaborate - Up
        overlayColor = Colors.cyan;
        finalIntentText = "Let's Build";
        lightBegin = Alignment.topCenter;
        lightEnd = Alignment.bottomCenter;
      } else {
        // Friendship - Down
        overlayColor = Colors.deepPurpleAccent;
        finalIntentText = "Good Energy";
        lightBegin = Alignment.bottomCenter;
        lightEnd = Alignment.topCenter;
      }
    }

    // Dynamic Microcopy
    String displayText = "";
    if (intensity < 0.25) {
      displayText = "Hmm...";
    } else if (intensity < 0.55) {
      displayText = "Interesting";
    } else {
      displayText = finalIntentText;
    }

    // Continuous piecewise function for elastic pulling
    double pullRatio = 0.0;
    if (intensity < 0.5) {
      // Moves outward from 0 to max at 50% swipe
      pullRatio = (intensity / 0.5); 
    } else if (intensity < 0.6) {
      // Snaps back smoothly to center between 50% and 60%
      pullRatio = 1.0 - ((intensity - 0.5) / 0.1);
    } else {
      // Locked in center
      pullRatio = 0.0;
    }

    double alignX = 0;
    double alignY = 0;
    if (isHorizontal) {
      alignX = xPercent.sign * pullRatio * 1.6; // Moves aggressively
    } else {
      alignY = yPercent.sign * pullRatio * 1.6;
    }

    // Progressive scale & opacity
    double pillScale = 0.8;
    if (intensity < 0.5) {
      pillScale = 0.8 + 0.3 * (intensity / 0.5);
    } else if (intensity < 0.6) {
      pillScale = 1.1 + 0.05 * ((intensity - 0.5) / 0.1);
    } else {
      pillScale = 1.15; // Popped size
    }

    double overlayOpacity = 0.0;
    if (intensity > 0.01) {
      if (intensity < 0.5) {
         overlayOpacity = 0.05 + 0.95 * (intensity / 0.5);
      } else {
         overlayOpacity = 1.0;
      }
    }

    final double gradientOpacity = (0.22 * (intensity / 0.5).clamp(0.0, 1.0));

    // Subtle 3D tilt based on swipe (reduced to keep it subtle)
    final Matrix4 tiltTransform = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective
      ..rotateX(yPercent * -0.2) // tilt up/down
      ..rotateY(xPercent * 0.2); // tilt left/right

    return Transform(
      transform: tiltTransform,
      alignment: FractionalOffset.center,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Base Card
          ProfileCard(profile: profile),

          // 2. Soft Controlled Gradient Lighting
          if (intensity > 0.01)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      overlayColor.withValues(alpha: gradientOpacity),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.25], // Hard falloff so it's only edge light
                    begin: lightBegin,
                    end: lightEnd,
                  ),
                ),
              ),
            ),

          // 3. Direction-aware Glassmorphism Pill
          if (intensity > 0.01)
            Align(
              alignment: Alignment(alignX, alignY),
              child: Transform.scale(
                scale: pillScale,
                child: Opacity(
                  opacity: overlayOpacity,
                  child: IntrinsicWidth(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24), // Stronger blur
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: overlayColor.withValues(alpha: 0.08), // Barely visible tint for depth
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12), // Very subtle line
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getIntentIcon(finalIntentText),
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                displayText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
