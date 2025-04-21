import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("The HomePage"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SafeArea(
          child: Text("NOT IMPLEMENTED YET :(", style: TextStyle(fontSize: 52)),
        ),
      ),
    );
  }
}
