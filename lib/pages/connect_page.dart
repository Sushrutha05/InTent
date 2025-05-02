import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';  // Correct import for card_swiper

class ConnectPage extends StatelessWidget {
  final List<Map<String, String>> users = [
    {
      "name": "Aisha",
      "university": "XYZ University",
      "bio": "Love music and late-night coding",
      "image": "https://images.pexels.com/photos/733853/pexels-photo-733853.jpeg?auto=compress&cs=tinysrgb&w=600"  // Neutral object image
    },
    {
      "name": "Rahul",
      "university": "ABC College",
      "bio": "Looking for study buddies and UI/UX partners",
      "image": "https://images.pexels.com/photos/746496/pexels-photo-746496.jpeg?auto=compress&cs=tinysrgb&w=600"  // Neutral object image
    },
    // Add more sample users with neutral object images
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connections"),
      ),
      body: Center(
        child: Swiper(
          itemCount: users.length,
          scrollDirection: Axis.vertical,  // Set vertical scroll direction
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 4,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      users[index]['image']!,  // Use neutral object image
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(users[index]['name']!, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(users[index]['university']!),
                        SizedBox(height: 8),
                        Text(users[index]['bio']!),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loop: true,
          autoplay: false,
          pagination: SwiperPagination(),
        ),
      ),
    );
  }
}
