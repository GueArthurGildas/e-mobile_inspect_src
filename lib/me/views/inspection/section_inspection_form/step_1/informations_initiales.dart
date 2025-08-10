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

  late TextEditingController _titreController;
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
    _titreController = TextEditingController();
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

    _titreController.text = _data['titre'] ?? '';
    _observationsController.text = _data['observation'] ?? '';
    _maillageController.text = _data['maillage'] ?? '';
    _dimensionsCalesController.text = _data['dimensionsCales'] ?? '';
    _marquageNavireController.text = _data['marquageNavire'] ?? '';
    _baliseVMSController.text = _data['baliseVMS'] ?? '';

    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _titreController.dispose();
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
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Informations initiales"),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
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
      ),
      FormControl(
        name: 'dateDebutInspection',
        label: "Date de début de l'inspection",
        type: ControlType.date,
        initialValue: _data['dateDebutInspection'],
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
      ),
      FormControl(
        name: 'pavillonNavire',
        label: "Pavillon du navire",
        type: ControlType.dropdown,
        options: _controller.pavillonsList
            .map((e) => DropdownOption(id: e.id, libelle: e.libelle))
            .toList(),
        initialValue:
            _data['pavillonNavire'] ??
            (_controller.pavillonsList.isNotEmpty
                ? _controller.pavillonsList.first.id.toString()
                : null),
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
      ),
      FormControl(
        name: "maillage",
        label: "Maillage",
        type: ControlType.text,
        controller: _maillageController,
        hint: "40",
        suffixText: "mm",
      ),
      FormControl(
        name: "dimensionsCales",
        label: "Dimension des cales",
        controller: _dimensionsCalesController,
        type: ControlType.text,
        hint: "10x5",
        suffixText: "m",
      ),
      FormControl(
        name: "marquageNavire",
        label: "Marquage du navire",
        controller: _marquageNavireController,
        type: ControlType.text,
        hint: "ABC123",
      ),
      FormControl(
        name: "baliseVMS",
        label: "Balise VMS",
        controller: _baliseVMSController,
        type: ControlType.text,
        hint: "VMS-98754",
      ),
      FormControl(
        name: 'paysEscale',
        label: "Pays d'escale",
        type: ControlType.dropdown,
        options: _controller.pays
            .map((e) => DropdownOption(id: e.id, libelle: e.libelle))
            .toList(),
        initialValue:
            _data['paysEscale'] ??
            (_controller.pays.isNotEmpty
                ? _controller.pays.first.id.toString()
                : null),
      ),
      FormControl(
        name: 'portEscale',
        label: "Port d'escale",
        type: ControlType.dropdown,
        options: _controller.portsList
            .map((e) => DropdownOption(id: e.id, libelle: e.libelle))
            .toList(),
        initialValue:
            _data['portEscale'] ??
            (_controller.portsList.isNotEmpty
                ? _controller.portsList.first.id.toString()
                : null),
      ),
      FormControl(
        name: 'dateEscaleNavire',
        label: "Date d'escale",
        type: ControlType.date,
        initialValue: _data['dateEscaleNavire'],
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
        options: _controller.motifsEntreeList
            .map((e) => DropdownOption(id: e.id, libelle: e.libelle))
            .toList(),
        initialValue:
            _data['objet'] ??
            (_controller.motifsEntreeList.isNotEmpty
                ? _controller.motifsEntreeList.first.id.toString()
                : null),
        controller: _objetController,
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
