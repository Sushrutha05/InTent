//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/signin_page.dart';
import 'pages/onboard_page.dart';


void main() async {
  //WidgetsFlutterBinding.ensureInitialized(); // Ensures the app is initialized
  //await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
      return MaterialApp(
          debugShowCheckedModeBanner: false,
          //home: OnboardingScreen(),
          home: LoginPage()
          //home: SignInPage()

      );
  }
}