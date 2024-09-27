import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: Colors.grey.shade300,
    primary: Color.fromARGB(255, 99, 7, 7),
    secondary:  Colors.grey.shade400,
    inversePrimary: Colors.grey.shade600,
  ),

  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: Colors.grey[800],
    displayColor: Color.fromARGB(255, 99, 7, 7),
    ),
);