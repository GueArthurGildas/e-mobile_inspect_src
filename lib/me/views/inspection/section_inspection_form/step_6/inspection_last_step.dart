import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/step_6/step_six_controller.dart';
import 'package:test_app_divkit/me/views/shared/app_bar.dart';
import 'package:test_app_divkit/me/views/shared/app_form.dart';
import 'package:test_app_divkit/me/views/shared/form_control.dart';

class InspectionLastStep extends StatefulWidget {
  const InspectionLastStep({super.key});

  @override
  State<InspectionLastStep> createState() => _InspectionLastStepState();
}

class _InspectionLastStepState extends State<InspectionLastStep> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> _data = {};
  final StepSixController _controller = StepSixController();

  final Color _orangeColor = const Color(0xFFFF6A00);
  bool _showDetailField = false;
  final List<Map<String, String?>> textFields = [
    {"name": "referenceInstrumentsJuridiques", "value": null},
    {"name": "commentairesCapitaine", "value": null},
    {"name": "mesuresPrises", "value": null},
    {"name": "detailInfractions", "value": null},
    {"name": "observations_supplementaires_1", "value": null},
    {"name": "observations_supplementaires_2", "value": null},
    {"name": "observations_supplementaires_3", "value": null},
    {"name": "remarques_supplementaires", "value": null},
  ];

  bool _isLoading = false;

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    super.initState();

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _data =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};

        // print(_data);

        setState(() {
          for (var field in textFields) {
            if (_data.containsKey(field['name']!)) {
              int index = textFields.indexWhere(
                    (element) => element['name'] == field['name'],
              );
              textFields[index]['value'] = _data[field['name']!];
            }

            _controller.setController(field['name']!, field['value']);
          }

          _showDetailField = _data['infractionObservee'] ?? false;
        });
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<FormControl> controls = [
      FormControl(
        type: ControlType.label,
        name: "",
        label: "Déclaration d'infraction",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
          color: _orangeColor,
        ),
      ),
      FormControl(
        type: ControlType.switchTile,
        name: "infractionObservee",
        label: "Avez-vous constaté une infraction lors de l'inspection ?",
        onChanged: (value) => setState(() => _showDetailField = value),
        initialValue: _data['infractionObservee'] ?? false,
      ),
      FormControl(
        type: ControlType.textarea,
        name: "detailInfractions",
        label: "Détail sur l'infraction observée",
        visible: _showDetailField,
        controller: _controller.getController('detailInfractions'),
      ),
      FormControl(
        type: ControlType.label,
        name: "",
        label: "Respect des mesures et régimes applicables",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
          color: _orangeColor,
        ),
        separator: SizedBox(height: MediaQuery.of(context).size.height * 0.03),
      ),
      FormControl(
        type: ControlType.text,
        name: "referenceInstrumentsJuridiques",
        label: "Référence au(x) instrument(s) juridique(s) pertinent(s)",
        controller: _controller.getController('referenceInstrumentsJuridiques'),
      ),
      FormControl(
        type: ControlType.text,
        name: "commentairesCapitaine",
        label: "Commentaires du capitaine du navire",
        controller: _controller.getController('commentairesCapitaine'),
      ),
      FormControl(
        type: ControlType.text,
        name: "mesuresPrises",
        label: "Mesures prises",
        controller: _controller.getController('mesuresPrises'),
      ),
      FormControl(
        type: ControlType.dropdown,
        name: "journaux_bord",
        label: "Examen du ou des journaux de bord et d'autres documents",
        options: [
          DropdownOption(id: 0, libelle: "Non"),
          DropdownOption(id: 1, libelle: "Oui"),
        ],
        initialValue: _data['journaux_bord'],
      ),
      FormControl(
        type: ControlType.textarea,
        name: "observations_supplementaires_1",
        label: "",
        controller: _controller.getController('observations_supplementaires_1'),
      ),
      FormControl(
        type: ControlType.dropdown,
        name: "doc_captures",
        label:
            "Conformité avec le(s) système(s) de documentation des captures applicable(s)",
        options: [
          DropdownOption(id: 0, libelle: "Non"),
          DropdownOption(id: 1, libelle: "Oui"),
        ],
        initialValue: _data['doc_captures'],
      ),
      FormControl(
        type: ControlType.textarea,
        name: "observations_supplementaires_2",
        label: "",
        controller: _controller.getController('observations_supplementaires_2'),
      ),
      FormControl(
        type: ControlType.dropdown,
        name: "info_commerciale",
        label:
            "Conformité avec le(s) système(s) d'information commerciale applicable(s)",
        options: [
          DropdownOption(id: 0, libelle: "Non"),
          DropdownOption(id: 1, libelle: "Oui"),
        ],
        initialValue: _data['info_commerciale'],
      ),
      FormControl(
        type: ControlType.textarea,
        name: "observations_supplementaires_3",
        label: "",
        controller: _controller.getController('observations_supplementaires_3'),
      ),
      FormControl(
        type: ControlType.dropdown,
        name: "engins_examine_psma",
        label:
            "Engins examinés conformément au paragraphe e) de l'annexe B de l'AMREP",
        options: [
          DropdownOption(id: 0, libelle: "Non"),
          DropdownOption(id: 1, libelle: "Oui"),
        ],
        initialValue: _data['engins_examine_psma'],
      ),
      FormControl(
        type: ControlType.textarea,
        name: "remarques_supplementaires",
        label: "",
        controller: _controller.getController('remarques_supplementaires'),
      ),
    ];

    return Scaffold(
      appBar: CustomAppBar(title: "Vérification et résultats d'inspection"),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _orangeColor))
          : SafeArea(
              child: AppForm(controls: controls, formKey: _formKey),
            ),
    );
  }
}
