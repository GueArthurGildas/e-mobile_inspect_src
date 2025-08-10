import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/models/agents_shiping_model.dart';
import 'package:test_app_divkit/me/models/consignations_model.dart';
import 'package:test_app_divkit/me/models/pays_model.dart';
import 'package:test_app_divkit/me/views/shared/app_bar.dart';
import 'package:test_app_divkit/me/views/shared/app_form.dart';
import 'package:test_app_divkit/me/views/shared/form_control.dart';

class FormInfosResponsablesScreen extends StatefulWidget {
  const FormInfosResponsablesScreen({super.key});

  @override
  State<FormInfosResponsablesScreen> createState() =>
      _FormInfosResponsablesScreenState();
}

class _FormInfosResponsablesScreenState
    extends State<FormInfosResponsablesScreen> {
  final _formKey = GlobalKey<FormState>();

  Map<String, List<dynamic>>? _data;
  Map<String, dynamic> _formData = {};

  late TextEditingController _nomCapitaineController;
  late TextEditingController _passeportCapitaineController;
  late TextEditingController _nomProprietaireController;

  // constants
  static const TextStyle _labelStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18.0,
    color: Color(0xFFFF6A00),
  );
  static const SizedBox _separator = SizedBox(height: 20.0);

  @override
  void initState() {
    super.initState();
    _nomCapitaineController = TextEditingController();
    _passeportCapitaineController = TextEditingController();
    _nomProprietaireController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newRouteData =
        ModalRoute.of(context)?.settings.arguments
            as Map<String, List<dynamic>>?;

    // Check if data has actually changed
    if (newRouteData != _data) {
      _data = newRouteData;

      _formData = _data?['formData']?[0] ?? <String, dynamic>{};
      _nomCapitaineController.text = _formData['nomCapitaine'] ?? '';
      _passeportCapitaineController.text =
          _formData['passeportCapitaine'] ?? '';
      _nomProprietaireController.text = _formData['nomProprietaire'] ?? '';
    }
  }

  @override
  void dispose() {
    _nomCapitaineController.dispose();
    _passeportCapitaineController.dispose();
    _nomProprietaireController.dispose();
    super.dispose();
  }

  // Helper method to build dropdown options
  List<DropdownOption> _buildDropdownOptions(
    List<dynamic>? items,
    String Function(dynamic) getLibelle,
    int Function(dynamic) getId,
  ) {
    if (items == null || items.isEmpty) {
      return [];
    }
    return items
        .map(
          (item) => DropdownOption(id: getId(item), libelle: getLibelle(item)),
        )
        .toList();
  }

  // Helper to get initial value for dropdowns
  String? _getInitialDropdownValue(
    List<dynamic>? items,
    int Function(dynamic) getId,
  ) {
    return items != null && items.isNotEmpty
        ? getId(items.first).toString()
        : null;
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null && ModalRoute.of(context)?.settings.arguments != null) {
      _data =
          ModalRoute.of(context)?.settings.arguments
              as Map<String, List<dynamic>>?;
    }

    final societesConsignation =
        (_data?['consignataires'] as List<Consignations>?) ?? [];
    final agentsShipping = (_data?['agents'] as List<AgentsShiping>?) ?? [];
    final nationalites = (_data?['pays'] as List<Pays>?) ?? [];

    final List<FormControl> controls = [
      FormControl(
        type: ControlType.dropdown,
        name: "societeConsignataire",
        label: "Société de consignation",
        options: _buildDropdownOptions(
          societesConsignation,
          (e) => e.nom_societe,
          (e) => e.id,
        ),
        initialValue: _getInitialDropdownValue(
          societesConsignation,
          (e) => e.id,
        ),
      ),
      FormControl(
        type: ControlType.dropdown,
        name: "agentShipping",
        label: "Agent shipping du navire",
        options: _buildDropdownOptions(
          agentsShipping,
          (e) => e.nom,
          (e) => e.id,
        ),
        initialValue: _getInitialDropdownValue(agentsShipping, (e) => e.id),
      ),
      FormControl(
        type: ControlType.label,
        name: "capitaineNavireLabel",
        label: "Capitaine du navire",
        style: _labelStyle,
        separator: _separator,
      ),
      FormControl(
        type: ControlType.text,
        name: "nomCapitaine",
        label: "Nom du capitaine",
        controller: _nomCapitaineController,
      ),
      FormControl(
        type: ControlType.text,
        name: "passeportCapitaine",
        label: "Passeport du capitaine",
        controller: _passeportCapitaineController,
      ),
      FormControl(
        type: ControlType.dropdown,
        name: "nationaliteCapitaine",
        label: "Nationalité",
        options: _buildDropdownOptions(
          nationalites,
          (e) => e.libelle,
          (e) => e.id,
        ),
        initialValue: _getInitialDropdownValue(nationalites, (e) => e.id),
      ),
      FormControl(
        type: ControlType.date,
        name: "dateExpirationPasseport",
        label: "Date d'expiration du passport",
        initialValue: _formData['dateExpirationPasseport'],
      ),
      FormControl(
        type: ControlType.label,
        name: "proprietaireNavireLabel",
        label: "Propriétaire du navire",
        style: _labelStyle,
        separator: _separator,
      ),
      FormControl(
        type: ControlType.text,
        name: "nomProprietaire",
        label: "Nom du propriétaire",
        controller: _nomProprietaireController,
      ),
      FormControl(
        type: ControlType.dropdown,
        name: "nationaliteProprietaire",
        label: "Nationalité",
        options: _buildDropdownOptions(
          nationalites,
          (e) => e.libelle,
          (e) => e.id,
        ),
        initialValue: _getInitialDropdownValue(nationalites, (e) => e.id),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Informations sur les responsables"),
      body: SafeArea(
        child:
            (_data == null &&
                ModalRoute.of(context)?.settings.arguments != null)
            ? const Center(child: CircularProgressIndicator())
            : AppForm(controls: controls, formKey: _formKey),
      ),
    );
  }
}
