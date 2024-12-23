import 'package:flutter/material.dart';

/// Converts a hex color string (e.g., "7766c6") to a [Color] object.
Color hexStringToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll('#', '');
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor";
  }
  return Color(int.parse(hexColor, radix: 16));
}
 
 /*
 hexStringToColor("46467A"),
 hexStringToColor("7766C6"),
 hexStringToColor("EODFFD"),
 hexStringToColor("FFC212"),
 hexStringToColor("F9B0C3)
 */
