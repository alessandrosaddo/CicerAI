import 'package:flutter/material.dart';

class AppColors {

  // ==================== COLORI ====================

  // Tema Chiaro
  static const lightBackground = Color(0xFFFBFBFB);
  static const lightPrimary = Color(0xFF047CDB);
  static const lightSecondary = Colors.white;
  static const lightText = Color(0xFF393838);
  static const lightBorderColor = Color(0xFFBDD4E7);
  static const lightWidgetBackground = Color(0xFFF6F3EB);
  static const lightIconColor = lightPrimary;
  static const lightHintText = Colors.grey;
  static const lightDisabledText = Colors.grey;
  static const lightDelete = lightBackground;
  static const lightTextDelete = Color(0xFFA80000);
  static const lightDivider = lightBorderColor;
  static const lightIconMap = Colors.white;
  static const lightWarning = Color(0xFFF3C102);


  // Tema Scuro
  static const darkBackground = Color(0xFF0F0F0F);
  static const darkPrimary = Color(0xFF047CDB);
  static const darkSecondary = Color(0xFF171717);
  static const darkText = Color(0xFFFFFFFF);
  static const darkBorderColor = Color(0xFF2A2A2A);
  static const darkWidgetBackground = Color(0xFF1A1A1A);
  static const darkIconColor = darkPrimary;
  static const darkHintText = Color(0xFF757575);
  static const darkDisabledText = Color(0xFF616161);
  static const darkDelete = darkBackground;
  static const darkTextDelete = Color(0xFABD3C3C);
  static const darkDivider = darkBorderColor;
  static const darkIconMap = Colors.white;
  static const darkWarning = Color(0xFFF8EC0A);




  // ==================== HELPER ====================

  static Color primary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightPrimary
        : darkPrimary;
  }

  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightBackground
        : darkBackground;
  }

  static Color text(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightText
        : darkText;
  }

  static Color border(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightBorderColor
        : darkBorderColor;
  }

  static Color widgetBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightWidgetBackground
        : darkWidgetBackground;
  }

  static Color icon(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightIconColor
        : darkIconColor;
  }

  static Color hintText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightHintText
        : darkHintText;
  }

  static Color disabledText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightDisabledText
        : darkDisabledText;
  }

  static Color secondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightSecondary
        : darkSecondary;
  }

  static Color divider(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightDivider
        : darkDivider;
  }

  static Color delete(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightDelete
        : darkDelete;
  }

  static Color deleteColorText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightTextDelete
        : darkTextDelete;
  }

  static Color iconColorMap(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightIconMap
        : darkIconMap;
  }

  static Color warningColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightWarning
        : darkWarning;
  }
}