import 'package:flutter/material.dart';

const kOrange = Color(0xFFFF6A00);   // orange principal (déjà utilisé chez toi)
const kOrangeDark = Color(0xFFE05F00); // orange repos (légèrement plus sobre)
const kGreyDisabled = Color(0xFFBDBDBD); // gris pour steps non validés

ThemeData buildAppTheme() {
  final baseBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: kOrangeDark, width: 1.2),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kOrange,
      brightness: Brightness.light,
      primary: kOrange,          // utilisé par Stepper pour actif/validé
      onPrimary: Colors.white,
      secondary: kOrange,
    ),
    // Champs de formulaire (TextFormField, DropdownButtonFormField)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(fontSize: 14),
      hintStyle: const TextStyle(color: Colors.black54),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: baseBorder,
      enabledBorder: baseBorder, // repos = orange foncé
      focusedBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: kOrange, width: 1.8), // focus = orange vif
      ),
      errorBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: baseBorder.copyWith(
        borderSide: const BorderSide(color: Colors.red, width: 1.8),
      ),
    ),
    // Dropdown (menu)
    dropdownMenuTheme: const DropdownMenuThemeData(
      menuStyle: MenuStyle(
        visualDensity: VisualDensity.compact,
      ),
    ),
    // Boutons Filled (tu utilises FilledButton dans le wizard)
    // filledButtonTheme: FilledButtonThemeData(
    //   style: ButtonStyle(
    //     backgroundColor: const WidgetStatePropertyAll(Colors.white),//const WidgetStatePropertyAll(kOrange),
    //     foregroundColor: const WidgetStatePropertyAll(Colors.white),
    //     shape: WidgetStatePropertyAll(
    //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    //     ),
    //     padding: const WidgetStatePropertyAll(
    //       EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    //     ),
    //   ),
    // ),
    // Boutons Outlined (bordure orange)
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        side: const WidgetStatePropertyAll(BorderSide(color: kOrange, width: 1.4)),
        foregroundColor: const WidgetStatePropertyAll(kOrange),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    ),
    // Boutons Elevated (si tu en utilises)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll(kOrange),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    ),
    // Spinners & barres de progression -> orange
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: kOrange,
      linearTrackColor: Color(0xFFFFE3CC),
    ),
    // AppBar blanc + texte orange (si souhaité)
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: kOrange,
      elevation: 0,
      centerTitle: true,
    ),
    // Couleur des éléments "désactivés" (steps non validés)
    disabledColor: kGreyDisabled,
  );
}
