import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF6C63FF),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: const Text(
        "Made by Harsh Vardhan • W3villa Technical Assignment",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
