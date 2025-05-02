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
  int index = 0; // Track the current selected index for the navigation bar

  // List of pages corresponding to each tab
  final List<Widget> _pages = [
    ConnectPage(),
    SearchPage(),
    ChatsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("InTent"), automaticallyImplyLeading: false),
        body: _pages[index],
        bottomNavigationBar: Container(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Flexible(
              child: GNav(
                rippleColor: Colors.grey,
                hoverColor: Colors.grey,
                activeColor: Colors.white,
                tabBackgroundColor: Colors.grey.shade900,
                color: Colors.white,
                backgroundColor: Colors.black,
                onTabChange: (new_index) {
                  setState(() {
                    index = new_index;
                  });
                },
                haptic: true,

                tabs: [
                  GButton(
                    icon: Icons.link_outlined,
                    text: "Connect",
                    gap: 7,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ConnectPage()));
                    },
                  ),
                  const GButton(
                    icon: Icons.search_outlined,
                    text: "Search",
                    gap: 7,
                  ),
                  const GButton(
                    icon: Icons.chat_outlined,
                    text: "Chats",
                    gap: 7,
                  ),
                  const GButton(
                    icon: Icons.account_circle_outlined,
                    text: "Profile",
                    gap: 7,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
