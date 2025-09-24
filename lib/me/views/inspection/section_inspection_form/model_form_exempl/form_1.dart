import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:e_Inspection_APP/me/views/shared/app_bar.dart';

class Form1 extends StatefulWidget {
  const Form1({super.key});

  @override
  State<Form1> createState() => _Form1();
}

class _Form1 extends State<Form1> {
  final _formKey = GlobalKey<FormState>();
  final Color orange = const Color(0xFFFF6A00);
  final Color green = const Color(0xFF006400);

  String? port;
  String? typeInspection;
  String? inspecteur;
  String? statut;
  bool isSurprise = false;
  DateTime? date;
  TimeOfDay? heure;

  TextEditingController titreController = TextEditingController();
  TextEditingController observationsController = TextEditingController();

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => date = picked);
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => heure = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Informations générales"),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 12),
              TextFormField(
                controller: titreController,
                decoration: const InputDecoration(
                  labelText: "Titre de l'inspection",
                ),
                validator: (val) => val!.isEmpty ? "Ce champ est requis" : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: "Date prévue",
                        ),
                        child: Text(
                          date != null
                              ? DateFormat.yMMMMd('fr_FR').format(date!)
                              : "Choisir une date",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: pickTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: "Heure prévue",
                        ),
                        child: Text(
                          heure != null
                              ? heure!.format(context)
                              : "Choisir une heure",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: port,
                decoration: const InputDecoration(
                  labelText: "Port d'inspection",
                ),
                items: ['Abidjan', 'San Pedro', 'Sassandra']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => port = val),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: typeInspection,
                decoration: const InputDecoration(
                  labelText: "Type d’inspection",
                ),
                items: ['Complète', 'Rapide', 'Suivi']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => typeInspection = val),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: inspecteur,
                decoration: const InputDecoration(
                  labelText: "Inspecteur assigné",
                ),
                items:
                    [
                          'Inspecteur KONE',
                          'Inspecteur N’Guessan',
                          'Inspecteur Traoré',
                        ]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (val) => setState(() => inspecteur = val),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: statut,
                decoration: const InputDecoration(labelText: "Statut initial"),
                items: ['Prévue', 'En attente', 'Annulée']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => statut = val),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: isSurprise,
                activeColor: orange,
                title: const Text("Inspection surprise ?"),
                onChanged: (val) => setState(() => isSurprise = val),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: observationsController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Observations générales",
                  alignLabelWithHint: true,
                ),
              ),
              // const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 100.0,
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Sauvegarder ou passer à l’étape suivante
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Étape enregistrée ✅")),
                  );
                }
              },
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                "Enregistrer",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
