import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';

class ProgressiveBlurImage extends StatelessWidget {
  final String imageUrl;
  final double blurLevel; // 0.0 (clear) to 1.0 (max blur)
  final double maxBlurSigma;

  const ProgressiveBlurImage({
    super.key,
    required this.imageUrl,
    this.blurLevel = 1.0,
    this.maxBlurSigma = 30.0, // High starting blur for personality-first!
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the actual sigma based on the blur level percentage
    // If blurLevel is 0, sigma is 0 (perfectly clear).
    // If blurLevel is 1.0, sigma is maxBlurSigma (very blurry).
    final double sigma = maxBlurSigma * blurLevel.clamp(0.0, 1.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        // The underlying image
        CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => Container(
                color: AppTheme.surfaceColor,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
          errorWidget:
              (context, url, error) => Container(
                color: AppTheme.surfaceColor,
                child: const Center(
                  child: Icon(Icons.error, color: AppTheme.textSecondary),
                ),
              ),
        ),

        // The blur effect, applied if sigma > 0
        if (sigma > 0)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: Container(
              // A slight dark tint to make text readable over the blur
              color: Colors.black.withValues(alpha: 0.2 * blurLevel),
            ),
          ),
      ],
    );
  }
}
