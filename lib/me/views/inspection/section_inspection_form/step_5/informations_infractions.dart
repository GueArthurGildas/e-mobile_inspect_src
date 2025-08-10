import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/views/shared/app_bar.dart';

class FormInfosInfractionsScreen extends StatefulWidget {
  const FormInfosInfractionsScreen({super.key});

  @override
  State<FormInfosInfractionsScreen> createState() =>
      _FormInfosInfractionsScreenState();
}

class _FormInfosInfractionsScreenState
    extends State<FormInfosInfractionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Renseignement des infractions"),
      body: SafeArea(child: Container()),
    );
  }
}
