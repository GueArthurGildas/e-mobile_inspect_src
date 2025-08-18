import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/step_1/step_one_controller.dart';
import 'package:test_app_divkit/me/views/shared/app_bar.dart';
import 'package:test_app_divkit/me/views/shared/app_button.dart';
import 'package:test_app_divkit/me/views/shared/app_form.dart';
import 'package:test_app_divkit/me/views/shared/common.dart';
import 'package:test_app_divkit/me/views/shared/form_control.dart';

import 'extra_fields_page.dart';

class FormInfosInitialesScreen extends StatefulWidget {
  const FormInfosInitialesScreen({super.key});

  @override
  State<FormInfosInitialesScreen> createState() =>
      _FormInfosInitialesScreenState();
}

class _FormInfosInitialesScreenState extends State<FormInfosInitialesScreen> {
  final _formKey = GlobalKey<FormState>();
  final Color _orangeColor = const Color(0xFFFF6A00);

  late Map<String, dynamic> _data;
  final StepOneController _controller = StepOneController();

  late TextEditingController _observationsController;
  late TextEditingController _maillageController;
  late TextEditingController _dimensionsCalesController;
  late TextEditingController _marquageNavireController;
  late TextEditingController _baliseVMSController;
  late TextEditingController _objetController;

  bool _loading = true;

  @override
  void initState() {
    super.initState();

    if (mounted) {
      _initControllers();
      // load data after first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadData();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _initControllers() {
    _observationsController = TextEditingController();
    _maillageController = TextEditingController();
    _dimensionsCalesController = TextEditingController();
    _marquageNavireController = TextEditingController();
    _baliseVMSController = TextEditingController();
    _objetController = TextEditingController();
  }

  Future<void> _loadData() async {
    dynamic routeData = ModalRoute.of(context)?.settings.arguments;
    _data = routeData ?? {};
    await _controller.loadData();

    _observationsController.text = _data['observation'] ?? '';
    _maillageController.text = _data['maillage'] ?? '';
    _dimensionsCalesController.text = _data['dimensionsCales'] ?? '';
    _marquageNavireController.text = _data['marquageNavire'] ?? '';
    _baliseVMSController.text = _data['baliseVMS'] ?? '';

    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _observationsController.dispose();
    _maillageController.dispose();
    _dimensionsCalesController.dispose();
    _marquageNavireController.dispose();
    _baliseVMSController.dispose();
    _objetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Informations initiales"),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6A00)))
          : SafeArea(
              child: AppForm(controls: _buildControls(), formKey: _formKey),
            ),
    );
  }

  List<FormControl> _buildControls() {
    bool observateurPresent = _data['observateurEmbarque']?['present'] ?? false;

    return [
      FormControl(
        type: ControlType.label,
        name: "",
        label: "Dates de l'inspection",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
          color: _orangeColor,
        ),
      ),
      FormControl(
        name: 'dateArriveeEffective',
        label: "Date d'arrivée effective du navire",
        type: ControlType.date,
        initialValue: _data['dateArriveeEffective'],
        required: true
      ),
      FormControl(
        name: 'dateDebutInspection',
        label: "Date de début de l'inspection",
        type: ControlType.date,
        initialValue: _data['dateDebutInspection'],
        required: true
      ),
      FormControl(
        type: ControlType.label,
        name: "",
        label: "Informations du navire",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
          color: _orangeColor,
        ),
        separator: const SizedBox(height: 20.0),
      ),
      FormControl(
        name: 'portInspection',
        label: "Port de l'inspection",
        type: ControlType.dropdown,
        options: _controller.portsList
            .map((e) => DropdownOption(id: e.id, libelle: e.libelle))
            .toList(),
        initialValue:
            _data['portInspection'] ??
            (_controller.portsList.isNotEmpty
                ? _controller.portsList.first.id.toString()
                : null),
        required: true
      ),
      FormControl(
        name: 'pavillonNavire',
        label: "Pavillon du navire",
        type: ControlType.dropdown,
        options: _controller.paysList
            .map((e) => DropdownOption(id: e.id, libelle: e.libelle))
            .toList(),
        initialValue:
            _data['pavillonNavire'] ??
            (_controller.paysList.isNotEmpty
                ? _controller.paysList.first.id.toString()
                : null),
        required: true
      ),
      FormControl(
        name: 'typeNavire',
        label: "Type de navire",
        type: ControlType.dropdown,
        options: _controller.typesNavireList
            .map((e) => DropdownOption(id: e.id, libelle: e.libelle))
            .toList(),
        initialValue:
            _data['typeNavire'] ??
            (_controller.typesNavireList.isNotEmpty
                ? _controller.typesNavireList.first.id.toString()
                : null),
        required: true
      ),
      FormControl(
        name: "maillage",
        label: "Maillage",
        type: ControlType.text,
        keyboardType: TextInputType.number,
        controller: _maillageController,
        hint: "40",
        suffixText: "mm",
        required: true
      ),
      FormControl(
        name: "dimensionsCales",
        label: "Dimension des cales",
        controller: _dimensionsCalesController,
        type: ControlType.text,
        hint: "10x5",
        suffixText: "m",
        required: true,
        // pattern: r"^\d[xX]\d$"
      ),
      FormControl(
        name: "marquageNavire",
        label: "Marquage du navire",
        controller: _marquageNavireController,
        type: ControlType.text,
        hint: "ABC123",
        required: true
      ),
      FormControl(
        name: "baliseVMS",
        label: "Balise VMS",
        controller: _baliseVMSController,
        type: ControlType.text,
        hint: "VMS-98754",
        required: true
      ),
      FormControl(
        name: 'paysEscale',
        label: "Pays d'escale",
        type: ControlType.dropdown,
        options: _controller.paysList
            .map((e) => DropdownOption(id: e.id, libelle: e.libelle))
            .toList(),
        initialValue:
            _data['paysEscale'] ??
            (_controller.paysList.isNotEmpty
                ? _controller.paysList.first.id.toString()
                : null),
        required: true
      ),
      FormControl(
        name: 'portEscale',
        label: "Port d'escale",
        type: ControlType.text,
        // type: ControlType.dropdown,
        // options: _controller.portsList
        //     .map((e) => DropdownOption(id: e.id, libelle: e.libelle))
        //     .toList(),
        // initialValue:
        //     _data['portEscale'] ??
        //     (_controller.portsList.isNotEmpty
        //         ? _controller.portsList.first.id.toString()
        //         : null),
        required: true
      ),
      FormControl(
        name: 'dateEscaleNavire',
        label: "Date d'escale",
        type: ControlType.date,
        initialValue: _data['dateEscaleNavire'],
        required: true
      ),
      FormControl(
        name: 'demandePrealablePort',
        label: "Demande préalable d'entrée au port ?",
        type: ControlType.switchTile,
        initialValue: _data['demandePrealablePort'],
      ),
      FormControl(
        name: 'observateurEmbarque',
        label: "Observateur embarqué ?",
        type: ControlType.switchTile,
        initialValue: {'present': observateurPresent},
        onChanged: (value) async {
          _data['observateurEmbarque'] ??= <String, dynamic>{};

          if (value == true) {
            final dynamic observerData = await Common.showBottomSheet(
              context,
              ExtraFieldsSheet(
                initialValues: _data['observateurEmbarque'] ?? {},
              ),
            );

            if (observerData != null) {
              setState(() {
                _data['observateurEmbarque'] = {
                  'present': true,
                  ...observerData,
                };
              });
            }
          } else {
            setState(() {
              _data['observateurEmbarque']['present'] = false;
            });
          }
        },
      ),
      FormControl(
        type: ControlType.button,
        name: "",
        label: "",
        visible: observateurPresent,
        child: AppButton.outline(
          text: "Voir les informations de l'observateur",
          style: const TextStyle(
            fontSize: 12.0,
            decoration: TextDecoration.underline,
          ),
          color: Colors.black54,
          onPressed: () async {
            final dynamic observerData = await Common.showBottomSheet(
              context,
              ExtraFieldsSheet(
                initialValues: _data['observateurEmbarque'] ?? {},
              ),
            );

            if (observerData != null) {
              setState(() {
                _data['observateurEmbarque'] = {
                  'present': true,
                  ...observerData,
                };
              });
            }
          },
        ),
      ),
      FormControl(
        type: ControlType.label,
        name: "",
        label: "Motifs ou objectifs  d'entrée au port",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
          color: _orangeColor,
        ),
        separator: const SizedBox(height: 20.0),
      ),
      FormControl(
        name: 'objet',
        label: "Objet",
        type: ControlType.dropdown,
        options: _controller.activitesNaviresList
            .map((a) => DropdownOption(id: a.id, libelle: a.libelle))
            .toList(),
        initialValue:
            _data['objet'] ??
            (_controller.activitesNaviresList.isNotEmpty
                ? _controller.activitesNaviresList.first.id.toString()
                : null),
        required: true
      ),
      FormControl(
        name: 'observation',
        label: "Observation",
        type: ControlType.textarea,
        controller: _observationsController,
      ),
    ];
  }
}
