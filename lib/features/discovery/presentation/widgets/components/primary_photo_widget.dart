import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class PrimaryPhotoWidget extends StatelessWidget {
  final String imageUrl;
  final double blurLevel; // 0.0 (clear) to 1.0 (max blur)
  final VoidCallback onTap;

  const PrimaryPhotoWidget({
    super.key,
    required this.imageUrl,
    this.blurLevel = 0.0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // max blur sigma is 30.0 for personality-first consistency
    final blurSigma = blurLevel * 10.0;
    // slight desaturation based on blur level
    final saturation = 1.0 - (blurLevel * 0.4);

    Widget image = CachedNetworkImage(
      memCacheWidth: 800,
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder:
          (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(color: Colors.white),
          ),
      errorWidget:
          (context, url, error) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.person, color: Colors.grey, size: 40),
          ),
    );

    if (blurSigma > 0) {
      image = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: image,
      );
    }

    if (saturation < 0.99) {
      image = ColorFiltered(
        colorFilter: ColorFilter.matrix([
          0.2126 + 0.7874 * saturation,
          0.7152 - 0.7152 * saturation,
          0.0722 - 0.0722 * saturation,
          0,
          0,
          0.2126 - 0.2126 * saturation,
          0.7152 + 0.2848 * saturation,
          0.0722 - 0.0722 * saturation,
          0,
          0,
          0.2126 - 0.2126 * saturation,
          0.7152 - 0.7152 * saturation,
          0.0722 + 0.9278 * saturation,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]),
        child: image,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(borderRadius: BorderRadius.circular(16), child: image),
    );
  }
}
