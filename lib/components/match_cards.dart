import 'package:flutter/material.dart';

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
            child: Image.network(
              image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 450,
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
                    IconButton(
                      onPressed: onLike,
                      icon: Icon(Icons.favorite, color: Colors.black),
                      iconSize: 30,
                    ),
                    const Text(
                      'Romantic',
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: onNope,
                      icon: Icon(Icons.people, color: Colors.black),
                      iconSize: 30,
                    ),
                    const Text(
                      'Friendship',
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: onSuperLike,
                      icon: Icon(Icons.handshake, color: Colors.black),
                      iconSize: 30,
                    ),
                    const Text(
                      'Collaboration',
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: onNope,
                      icon: Icon(Icons.close, color: Colors.black),
                      iconSize: 30,
                    ),
                    const Text(
                      'Not Interested',
                      style: TextStyle(color: Colors.black, fontSize: 14),
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
