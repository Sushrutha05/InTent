import 'package:flutter/material.dart';
import 'package:student_dating_app/components/my_button.dart';
import 'package:student_dating_app/components/my_textfield.dart';
import 'package:student_dating_app/components/square_tile.dart';
import 'package:student_dating_app/pages/home_page.dart';
import 'package:student_dating_app/pages/signin_page.dart';

class LoginPage extends StatelessWidget{

  LoginPage({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  //signin user method
  void signUserIn(){}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(

        backgroundColor: Colors.grey[300],

        body: SafeArea(

          child: Center(
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                //Welcome
                Text(
                  "Hey there!!",
                  style: TextStyle(fontSize: 30),
                ),
                const SizedBox(height: 25),

                //Username
                MyTextField(
                  hintText: "UserName",
                  controller: usernameController,
                  obscureText: false
                ),

                const SizedBox(height: 25),
                //Password
                MyTextField(
                  hintText: "Password",
                  controller: passwordController,
                  obscureText: true
                ),

                const SizedBox(height: 25),
                //Forgot password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                          "Forgot Password?"),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                //Sign in

                const SizedBox(height: 10,),
                MyButton(
                  onTap: signUserIn,
                ),


                const SizedBox(height: 10),
                const SizedBox(height: 20),
                //Continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      Expanded(child:
                         Divider(
                           thickness:2,
                           color: Colors.grey[400]),
                         ),

                      Padding(padding: const EdgeInsets.symmetric(horizontal:15),
                      child: Text(
                        "or continue with",
                        style: TextStyle(fontSize: 17))
                      ),

                      Expanded(child:
                         Divider(
                           thickness:2,
                           color: Colors.grey[400]),
                      ),
                    ],
                  )

                ),

                const SizedBox(height: 30),
                //Google or apple
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(imagePath: "lib/images/icons8-google-36.png", imageHeight: 58.0),
                    const SizedBox(width: 25),
                    SquareTile(imagePath: "lib/images/icons8-apple-38.png", imageHeight: 58.0)
                  ],
                ),
                const SizedBox(height: 100),
                //Register Now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Not a member?"),
                    const SizedBox(width: 10),
                    GestureDetector(
                        onTap: (){
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => SignInPage()),);
                        },
                        child: Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18)
                        ),
                      ),


                  ],
                )
              ],
            ),

          ),

        ),
      ),
    );
  }
}