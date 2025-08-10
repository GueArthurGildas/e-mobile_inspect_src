import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/views/shared/app_bar.dart';

class FormInspectionSoumissionScreen extends StatefulWidget {
  const FormInspectionSoumissionScreen({super.key});

  @override
  State<FormInspectionSoumissionScreen> createState() =>
      _FormInspectionSoumissionScreenState();
}

class _FormInspectionSoumissionScreenState
    extends State<FormInspectionSoumissionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Soumission des détails de l'inspection"),
      body: SafeArea(child: Container()),
    );
  }
}
