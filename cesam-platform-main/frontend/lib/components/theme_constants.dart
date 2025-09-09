import 'package:flutter/material.dart';
import '../constants/colors.dart'; // ton fichier CesamColors

// Couleurs globales pour les pages avec appBar
class CesamTheme {
  // Fond général des pages
  static Color backgroundColor = CesamColors.background;

  // Couleur AppBar
  static Color appBarBackgroundColor = CesamColors.background;

  // Couleur texte dans AppBar
  static Color appBarTextColor = Colors.black;

  // Style Text pour le titre AppBar
  static TextStyle appBarTitleTextStyle = TextStyle(
    color: appBarTextColor,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
}
