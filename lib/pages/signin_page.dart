import 'package:flutter/material.dart';
import 'package:student_dating_app/components/my_textfield.dart';
import 'package:student_dating_app/components/square_tile.dart';
import 'package:student_dating_app/pages/onboard_page.dart';

class SignInPage extends StatelessWidget {
  SignInPage({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          leading: GestureDetector(
            child: Icon(Icons.turn_left_sharp),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.grey[200],
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Text(
                      "Lets Sign you in right now",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                MyTextField(
                  hintText: "Your name",
                  controller: usernameController,
                  obscureText: false,
                ),

                const SizedBox(height: 15),
                MyTextField(
                  hintText: "Your Password",
                  controller: passwordController,
                  obscureText: true,
                ),

                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                  ),

                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OnboardingScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Text("Or Sign in using"),

                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SquareTile(
                        imagePath: "lib/images/icons8-google-36.png",
                        imageHeight: 58.0,
                      ),
                      SquareTile(
                        imagePath: "lib/images/icons8-apple-38.png",
                        imageHeight: 58.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
