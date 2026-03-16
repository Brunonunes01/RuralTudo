import 'package:flutter/material.dart';

class AppFormTextField extends StatelessWidget {
  const AppFormTextField({
    required this.controller,
    required this.label,
    super.key,
    this.keyboardType,
    this.maxLines = 1,
    this.hintText,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, hintText: hintText),
    );
  }
}
