import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormulaireStyleImage extends StatefulWidget {
  const FormulaireStyleImage({super.key});

  @override
  State<FormulaireStyleImage> createState() => _FormulaireStyleImageState();
}

class _FormulaireStyleImageState extends State<FormulaireStyleImage> {
  final Color orange = const Color(0xFFFF6A00);
  final _formKey = GlobalKey<FormState>();

  final titreController = TextEditingController();
  final brancheController = TextEditingController();
  final nomController = TextEditingController();
  final numeroController = TextEditingController();
  final cleController = TextEditingController();
  final montantController = TextEditingController();
  final raisonController = TextEditingController();

  String? typeInspection;

  InputDecoration champDecoration(String label, {int maxLines = 1}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      alignLabelWithHint: maxLines > 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text("Réalisation Inspection"),
        backgroundColor: orange,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 10),
            TextFormField(
              controller: titreController,
              decoration: champDecoration("Titre de l’inspection *"),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: typeInspection,
              decoration: champDecoration("Type d’inspection *"),
              items: ['Complète', 'Rapide', 'Surprise']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => typeInspection = val),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: brancheController,
              decoration: champDecoration("Nom du port / zone *"),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nomController,
              decoration: champDecoration("Inspecteur responsable *"),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: numeroController,
              decoration: champDecoration("Numéro de navire *"),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: cleController,
              decoration: champDecoration("Code interne / Clé *"),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: montantController,
              keyboardType: TextInputType.number,
              decoration: champDecoration("Durée prévue (en minutes) *"),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: raisonController,
              maxLines: 3,
              decoration: champDecoration("Objectif ou contexte *", maxLines: 3),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Formulaire soumis avec succès ✅")));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Soumettre"),
            ),
          ],
        ),
      ),
    );
  }
}
