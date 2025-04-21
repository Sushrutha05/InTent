import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
  final double imageHeight;

  const SquareTile({
    super.key,
    required this.imagePath,
    required this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(25),
        color: Colors.grey[200],
      ),
      child: Image.asset(imagePath, height: imageHeight),
    );
  }
}
