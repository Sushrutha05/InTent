import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(
  const MyApp(
    name: "John",
    age: 5,
    bio:
        "Engineering student by day, aspiring adventurer by weekend. Always up for trying something new – whether it's a new recipe, exploring the outdoors, or diving into deep conversation",
  ),
);

class MyApp extends StatelessWidget {
  final String name;
  final int age;
  final String bio;

  const MyApp({
    super.key,
    required this.name,
    required this.age,
    required this.bio,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MatchCard(name: name, age: age, bio: bio),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MatchCard extends StatelessWidget {
  final String name;
  final int age;
  final String bio;

  const MatchCard({
    super.key,
    required this.name,
    required this.age,
    required this.bio,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Container(
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
                  "https://images.unsplash.com/photo-1527980965255-d3b416303d12",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 450,
                ),
              ),

              SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {},
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
                          onPressed: () {},
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
                          onPressed: () {},
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
                          onPressed: () {},
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
        ),
      ),
    );
  }
}
