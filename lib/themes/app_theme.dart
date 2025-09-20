import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.lightPrimary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightPrimary,
      foregroundColor: AppColors.lightText,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: AppColors.lightPrimary,
      unselectedItemColor: Colors.grey,
      backgroundColor: AppColors.lightBackground,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    primaryColor: AppColors.darkPrimary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: AppColors.darkText,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: AppColors.darkPrimary,
      unselectedItemColor: Colors.grey,
      backgroundColor: AppColors.darkBackground,
    ),
  );
}
