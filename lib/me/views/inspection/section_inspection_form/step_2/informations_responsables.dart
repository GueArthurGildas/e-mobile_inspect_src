import 'package:flutter/material.dart';
import 'package:e_Inspection_APP/me/views/inspection/section_inspection_form/step_2/step_two_controller.dart';
import 'package:e_Inspection_APP/me/views/shared/app_bar.dart';
import 'package:e_Inspection_APP/me/views/shared/app_form.dart';
import 'package:e_Inspection_APP/me/views/shared/form_control.dart';

class FormInfosResponsablesScreen extends StatefulWidget {
  const FormInfosResponsablesScreen({super.key});

  @override
  State<FormInfosResponsablesScreen> createState() =>
      _FormInfosResponsablesScreenState();
}

class _FormInfosResponsablesScreenState
    extends State<FormInfosResponsablesScreen> {
  final _formKey = GlobalKey<FormState>();
  final StepTwoController _controller = StepTwoController();

  bool _loading = true;

  late Map<String, dynamic> _data;

  late TextEditingController _nomCapitaineController;
  late TextEditingController _passeportCapitaineController;
  late TextEditingController _nomProprietaireController;

  static const TextStyle _labelStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18.0,
    color: Color(0xFFFF6A00),
  );
  static const SizedBox _separator = SizedBox(height: 20.0);

  @override
  void initState() {
    super.initState();

    if (mounted) {
      _nomCapitaineController = TextEditingController();
      _passeportCapitaineController = TextEditingController();
      _nomProprietaireController = TextEditingController();

      WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
    }
  }

  void _loadData() async {
    dynamic routeData = ModalRoute.of(context)?.settings.arguments;
    _data = routeData ?? {};
    await _controller.loadData();

    _nomCapitaineController.text = _data['nomCapitaine'] ?? '';
    _passeportCapitaineController.text = _data['passeportCapitaine'] ?? '';
    _nomProprietaireController.text = _data['nomProprietaire'] ?? '';

    setState(() => _loading = false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _nomCapitaineController.dispose();
    _passeportCapitaineController.dispose();
    _nomProprietaireController.dispose();
    super.dispose();
  }

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Informations sur les responsables"),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF6A00)),
              )
            : AppForm(controls: controls, formKey: _formKey),
      ),
    );
  }

  List<FormControl> get controls => [
    FormControl(
      type: ControlType.dropdown,
      name: "societeConsignataire",
      label: "Société de consignation",
      options: _buildDropdownOptions(
        _controller.societesConsignation,
        (e) => e.nom_societe,
        (e) => e.id,
      ),
      initialValue: _getInitialDropdownValue(
        _controller.societesConsignation,
        (e) => e.id,
      ),
    ),
    FormControl(
      type: ControlType.dropdown,
      name: "agentShipping",
      label: "Agent shipping du navire",
      options: _buildDropdownOptions(
        _controller.agentsShipping,
        (e) => e.nom,
        (e) => e.id,
      ),
      initialValue: _getInitialDropdownValue(
        _controller.agentsShipping,
        (e) => e.id,
      ),
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
        _controller.pays,
        (e) => e.libelle,
        (e) => e.id,
      ),
      initialValue: _getInitialDropdownValue(_controller.pays, (e) => e.id),
    ),
    FormControl(
      type: ControlType.date,
      name: "dateExpirationPasseport",
      label: "Date d'expiration du passport",
      initialValue: _data['dateExpirationPasseport'],
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
        _controller.pays,
        (e) => e.libelle,
        (e) => e.id,
      ),
      initialValue: _getInitialDropdownValue(_controller.pays, (e) => e.id),
    ),
  ];
}
