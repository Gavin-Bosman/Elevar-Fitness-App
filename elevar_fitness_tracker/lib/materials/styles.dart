import 'package:flutter/material.dart';

// class will contain various methods to make it easy to access styles throughout the project
class AppStyles {

  static TextStyle getHeadingStyle(bool darkmode, [Color? textColor]) {
    return TextStyle(
      fontFamily: 'Geologica',
   
      fontWeight: FontWeight.w800,
      color: textColor ?? AppStyles.textColor(darkmode)
    );
  }

  static TextStyle getSubHeadingStyle(bool darkmode, [Color? textColor]) {
    return TextStyle(
      fontFamily: 'Geologica',

      fontWeight: FontWeight.w500,
      color: textColor ?? AppStyles.textColor(darkmode)
    );
  }

  static TextStyle getMainTextStyle(bool darkmode, [Color? textColor]) {
    return TextStyle(
      fontFamily: 'Geologica',
 
      fontWeight: FontWeight.w400,
      color: textColor ?? AppStyles.textColor(darkmode)
    );
  }

  static EdgeInsetsGeometry getDefaultInsets() {
    return const EdgeInsets.all(10);
  }

  // Note about these colour codes:
  // If you ever need to change the opacity, USE THE withOpacity() method!
  // Example: AppStyles.accentColor(isDarkMode).withOpacity(0.5) for accentColor
  // with half opacity.

  static Color highlightColor(bool darkMode) {
    return const Color(0xFF00CCFF);
  }

  static Color objectColor(bool darkMode) {
    return const Color(0xFF444444);
  }

  static Color textColor(bool darkMode) {
    return darkMode ? const Color(0xfffbf4f6) : const Color(0xff0b0406);
  }

  static Color backgroundColor(bool darkMode) {
    return darkMode ? const Color(0xff040102) : const Color(0xfffefbfc);
  }

  static Color primaryColor(bool darkMode) {
    return darkMode ? const Color(0xff30917b) : const Color(0xff6ecfb8);
  }

  static Color secondaryColor(bool darkMode) {
    return darkMode ? const Color(0xff4b4425) : const Color(0xfff9ebbe);
  }

  static Color accentColor(bool darkMode) {
    return darkMode ? const Color(0xff788e9b) : const Color(0xff647a87);
  }
}

// This method lets you create a color from a string representing a hex code,
// I honestly don't remember what I was using it for, but maybe it'll be useful
// to someone else eventually.
// If a hex code without alpha is provided, it defaults to 255.
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "ff$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}