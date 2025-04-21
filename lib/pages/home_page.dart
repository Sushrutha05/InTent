import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:student_dating_app/pages/chats_page.dart';
import 'package:student_dating_app/pages/connect_page.dart';
import 'package:student_dating_app/pages/search_page.dart';
import 'package:student_dating_app/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: Container(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: GNav(
              rippleColor: Colors.grey,
              hoverColor: Colors.grey,
              activeColor: Colors.white,
              tabBackgroundColor: Colors.grey.shade900,
              color: Colors.white,
              backgroundColor: Colors.black,
              onTabChange: (index) {
                switch (index) {
                  case 0:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ConnectPage()),
                    );
                  case 1:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchPage()),
                    );
                  case 2:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatsPage()),
                    );
                  case 3:
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                }
              },
              haptic: true,
              gap: 5,
              tabs: const [
                GButton(icon: Icons.link_outlined, text: "Connect"),
                GButton(icon: Icons.search_outlined, text: "Search"),
                GButton(icon: Icons.chat_outlined, text: "Chats"),
                GButton(icon: Icons.account_circle_outlined, text: "Profile"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
