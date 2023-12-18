import 'package:flutter/material.dart';
import 'package:pickers_project/imagepicker_screen.dart';

void main() {
  runApp(const PickerApp());
}

class PickerApp extends StatelessWidget {
  const PickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImagePickerScreen()
    );
  }
}
