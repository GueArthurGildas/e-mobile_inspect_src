import 'package:flutter/material.dart';

class ExtraFieldsSheet extends StatefulWidget {
  final Map<String, dynamic> initialValues;
  // final void Function(Map<String, String>) onSave;

  const ExtraFieldsSheet({
    super.key,
    required this.initialValues,
    // required this.onSave,
  });

  @override
  State<ExtraFieldsSheet> createState() => _ExtraFieldsSheetState();
}

class _ExtraFieldsSheetState extends State<ExtraFieldsSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nomControler;
  late TextEditingController prenomController;
  late TextEditingController societeController;
  late TextEditingController passportIDController;
  late DateTime? expirationPasseport;

  @override
  void initState() {
    super.initState();
    nomControler = TextEditingController(text: widget.initialValues['nom']);
    prenomController = TextEditingController(
      text: widget.initialValues['prenom'],
    );
    societeController = TextEditingController(
      text: widget.initialValues['societe'],
    );
    passportIDController = TextEditingController(
      text: widget.initialValues['numeroPasseport'],
    );
    expirationPasseport = DateTime.tryParse(
      widget.initialValues['dateExpirationPasseport'] ?? "",
    );
  }

  String? validate(String? val) {
    return (val == null || val.isEmpty) ? "Ce champ est requis" : null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      height: MediaQuery.of(context).size.height * 0.5,
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Informations de l'observateur",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextFormField(
                controller: nomControler,
                decoration: InputDecoration(labelText: "Nom"),
                validator: (val) => validate(val),
              ),
              TextFormField(
                controller: prenomController,
                decoration: InputDecoration(labelText: "Prénoms"),
                validator: (val) => validate(val),
              ),
              TextFormField(
                controller: societeController,
                decoration: InputDecoration(labelText: "Société"),
                validator: (val) => validate(val),
              ),
              TextFormField(
                controller: passportIDController,
                decoration: InputDecoration(labelText: "Numéro de passeport"),
                validator: (val) => validate(val),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, {
                      "nom": nomControler.text,
                      "prenom": prenomController.text,
                      "societe": societeController.text,
                      "numeroPasseport": passportIDController.text,
                      "dateExpirationPasseport": expirationPasseport.toString(),
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFFFF6A00),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Enregistrer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
