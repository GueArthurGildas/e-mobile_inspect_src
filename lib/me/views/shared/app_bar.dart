import 'package:flutter/material.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({
    super.key,
    Color backgroundColor = const Color(0xFFFF6A00),
    Color foregroundColor = Colors.white,
    double? elevation,
    Brightness? brightness,
    IconThemeData? iconTheme,
    String? title,
    List<Widget>? customActions,
    bool centerTitle = true,
    super.automaticallyImplyLeading,
  }) : super(
         backgroundColor: backgroundColor,
         elevation: elevation ?? 0,
         title: title != null
             ? Text(title, style: TextStyle(fontSize: 19.0))
             : const SizedBox(),
         iconTheme: iconTheme ?? const IconThemeData(color: Colors.white),
         actions: customActions,
         centerTitle: centerTitle,
         foregroundColor: foregroundColor,
       );
}
