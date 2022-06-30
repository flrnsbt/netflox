import 'package:flutter/material.dart';

class CustomSnackBar extends SnackBar {
  CustomSnackBar({super.key, required String text})
      : super(content: Text(text));
}
