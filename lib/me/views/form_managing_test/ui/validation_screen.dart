import 'package:flutter/material.dart';

/// ✅ Exemple d’écran de validation (à adapter)
class ValidationScreen extends StatelessWidget {
  const ValidationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validation')),
      body: const Center(
        child: Text('Inspection validée ✅'),
      ),
    );
  }
}