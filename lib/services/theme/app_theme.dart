import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData appTheme(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDarkTheme ? Colors.red : Colors.black,
          side: BorderSide(
            color: isDarkTheme ? Colors.white : Colors.black,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDarkTheme ? Colors.red : Colors.black,
      ),
      scaffoldBackgroundColor:
          isDarkTheme ? const Color(0xFF121212) : Colors.white,
      textTheme: Theme.of(context).textTheme.apply(
            bodyColor: isDarkTheme ? Colors.white : Colors.black,
            displayColor: isDarkTheme ? Colors.white : Colors.black,
          ),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      iconTheme: IconThemeData(
        color: isDarkTheme ? Colors.white : Colors.black,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: isDarkTheme ? Colors.white : Colors.black,
      ),
      appBarTheme: AppBarTheme(
        foregroundColor: isDarkTheme ? Colors.white : Colors.black,
      ),
      colorSchemeSeed: const Color(0xFFEA5455),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDarkTheme ? Colors.white : Colors.black,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        helperStyle: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
        hintStyle: TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
