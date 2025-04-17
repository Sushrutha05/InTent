import 'package:flutter/material.dart';

class MyButton extends StatelessWidget{

  final Function()? onTap;

  const MyButton({super.key, required this.onTap });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      child:Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),color: Colors.black,),
        height: 50,
        width: 400,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Log In",
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),const SizedBox(width: 20),
              Icon(Icons.login, color: Colors.white,)
            ],
          ),
        ),

      )
    );
  }
}