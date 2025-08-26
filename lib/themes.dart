import 'package:flutter/material.dart';

final Map<String, ThemeData> themes = {
  'dark_mode': ThemeData.dark(),
  'cyberpunk': ThemeData(
    primarySwatch: Colors.purple,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF2A0A5E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A0A3E),
    ),
  ),
  'nature': ThemeData(
    primarySwatch: Colors.green,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFE8F5E9),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF66BB6A),
    ),
  ),
};
