import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';  // Correct import for swipe_cards

import 'dart:developer'; // For logging

class ConnectPage extends StatefulWidget {
  @override
  _ConnectPageState createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  final List<Map<String, String>> users = [
    {
      "name": "Aisha",
      "university": "XYZ University",
      "bio": "Love music and late-night coding",
      "image": "https://images.unsplash.com/photo-1527980965255-d3b416303d12" // Neutral object image
    },
    {
      "name": "Rahul",
      "university": "ABC College",
      "bio": "Looking for study buddies and UI/UX partners",
      "image": "https://images.unsplash.com/photo-1527980965255-d3b416303d12" // Neutral object image
    },
  ];

  // Create a list of SwipeItems based on users data
  List<SwipeItem> get swipeItems {
    return users.map((user) {
      return SwipeItem(
        content: user['name']!,  // Set content to user's name
        likeAction: () {
          log("Liked ${user['name']}");
        },
        nopeAction: () {
          log("Nope ${user['name']}");
        },
        superlikeAction: () {
          log("Superliked ${user['name']}");
        },
      );
    }).toList();
  }

  late MatchEngine matchEngine;

  @override
  void initState() {
    super.initState();
    matchEngine = MatchEngine(swipeItems: swipeItems);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SwipeCards(
            matchEngine: matchEngine, // Use the matchEngine here
            itemBuilder: (BuildContext context, int index) {
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.network(
                        users[index]['image']!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                          );
                        },
                      )

                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(users[index]['name']!, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          SizedBox(height: 5),
                          Text(users[index]['university']!, style: TextStyle(fontSize: 16, color: Colors.grey)),
                          SizedBox(height: 8),
                          Text(users[index]['bio']!),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            onStackFinished: () {
              log("All items swiped.");
              // Reset the matchEngine to loop
              setState(() {
                matchEngine = MatchEngine(swipeItems: swipeItems);  // Reset to the first item
              });
            },
            itemChanged: (SwipeItem item, int index) {
              log("Item changed: ${item.content}");
            },
            upSwipeAllowed: true,
            rightSwipeAllowed: true,
            leftSwipeAllowed: true,
          ),
        ),
    );
  }
}
