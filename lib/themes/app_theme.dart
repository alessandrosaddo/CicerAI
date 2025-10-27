import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  // ==================== TEMA CHIARO ====================
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.lightPrimary,
    scaffoldBackgroundColor: AppColors.lightBackground,


    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.lightText,
    ),


    // BottomNavigationBar
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: AppColors.lightPrimary,
      unselectedItemColor: Colors.grey,
      backgroundColor: AppColors.lightBackground,
    ),


    // TextField
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.lightBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.lightBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.lightBorderColor),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.lightDisabledText),
      ),
      prefixIconColor: AppColors.lightIconColor,
      hintStyle: TextStyle(color: AppColors.lightHintText),
    ),

    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.lightPrimary,
      selectionColor: AppColors.lightPrimary,
      selectionHandleColor: AppColors.lightPrimary,
    ),


  );



  // ==================== TEMA SCURO ====================
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkText,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: AppColors.darkPrimary,
      unselectedItemColor: Colors.grey,
      backgroundColor: AppColors.darkBackground,
    ),

    // TextField
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkBorderColor),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.darkDisabledText),
      ),
      prefixIconColor: AppColors.darkIconColor,
      hintStyle: TextStyle(color: AppColors.darkHintText),
    ),

    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.darkPrimary,
      selectionColor: AppColors.darkPrimary,
      selectionHandleColor: AppColors.darkPrimary,
    ),

  );


}
