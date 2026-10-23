import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:student_dating_app/core/theme/app_theme.dart';

class ProgressiveBlurImage extends StatelessWidget {
  final String imageUrl;
  final double blurLevel; // 0.0 (clear) to 1.0 (max blur)
  final double maxBlurSigma;

  const ProgressiveBlurImage({
    super.key,
    required this.imageUrl,
    this.blurLevel = 1.0,
    this.maxBlurSigma = 45.0, // High starting blur for personality-first!
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the actual sigma based on the blur level percentage
    // If blurLevel is 0, sigma is 0 (perfectly clear).
    // If blurLevel is 1.0, sigma is maxBlurSigma (very blurry).
    final double sigma = maxBlurSigma * blurLevel.clamp(0.0, 1.0);

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      memCacheHeight: 400,
      memCacheWidth: 400,
      placeholder:
          (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(color: Colors.white),
          ),
      errorWidget:
          (context, url, error) => Container(
            color: AppTheme.surfaceColor,
            child: const Center(
              child: Icon(Icons.error, color: AppTheme.textSecondary),
            ),
          ),
    );

    if (sigma > 0) {
      image = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: image,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        image,
        if (sigma > 0)
          Container(
            // A slight dark tint to make text readable over the blur
            color: Colors.black.withValues(alpha: 0.2 * blurLevel),
          ),
      ],
    );
  }
}
