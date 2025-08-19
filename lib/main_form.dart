import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/views/form_managing_test/state/inspection_wizard_ctrl.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/inspection_list_screen.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/app_theme.dart';

void main() {
  runApp( MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    home: InspectionListScreen(),
  ));
}


