import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:student_dating_app/core/widgets/bouncy_button.dart';

class MatchCard extends StatelessWidget {
  final String name;
  final int age;
  final String bio;
  final String image;
  final VoidCallback onLike;
  final VoidCallback onNope;
  final VoidCallback onSuperLike;

  const MatchCard({
    super.key,
    required this.name,
    required this.age,
    required this.bio,
    required this.image,
    required this.onLike,
    required this.onNope,
    required this.onSuperLike,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(25),
      ),
      height: 700,
      width: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: GestureDetector(
              onTap: () {
                context.push('/image', extra: {
                  'imageUrl': image,
                  'heroTag': 'discovery_image_$image',
                });
              },
              child: Hero(
                tag: 'discovery_image_$image',
                child: CachedNetworkImage(
                  imageUrl: image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 450,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      color: Colors.white,
                      width: double.infinity,
                      height: 450,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: double.infinity,
                    height: 450,
                    color: Colors.grey[200],
                    child: const Icon(Icons.error, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name, $age',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  bio,
                  style: const TextStyle(color: Colors.black, fontSize: 19),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    BouncyButton(
                      onPressed: onLike,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(Icons.favorite, color: Colors.pinkAccent, size: 32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Romantic',
                      style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Column(
                  children: [
                    BouncyButton(
                      onPressed: onNope,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(Icons.people, color: Colors.blueAccent, size: 32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Friendship',
                      style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Column(
                  children: [
                    BouncyButton(
                      onPressed: onSuperLike,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(Icons.handshake, color: Colors.green, size: 32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Collaboration',
                      style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Column(
                  children: [
                    BouncyButton(
                      onPressed: onNope,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(Icons.close, color: Colors.redAccent, size: 32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pass',
                      style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
