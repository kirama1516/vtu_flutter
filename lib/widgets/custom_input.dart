import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final TextEditingController controller;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.indigo[900]),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.indigo),
        ),
      ),
    );
  }
}
