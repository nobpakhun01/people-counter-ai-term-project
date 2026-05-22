import 'package:flutter/material.dart';

class AppTheme {
  static const bg = Color(0xff120f1f);
  static const card = Color(0xff241b35);
  static const card2 = Color(0xff2f2445);
  static const primary = Color(0xff8e5cff);
  static const cyan = Color(0xff35c9ff);
  static const pink = Color(0xffff5ca8);
  static const orange = Color(0xffffb347);

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff211832),
      centerTitle: true,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xff15111f),
      selectedItemColor: primary,
      unselectedItemColor: Colors.white54,
      type: BottomNavigationBarType.fixed,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}
