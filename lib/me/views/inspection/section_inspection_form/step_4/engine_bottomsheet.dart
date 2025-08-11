import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/models/etats_engins_model.dart';
import 'package:test_app_divkit/me/models/types_engins_model.dart';
import 'package:test_app_divkit/me/views/shared/app_dropdown_search.dart';
import 'package:test_app_divkit/me/views/shared/app_form.dart';
import 'package:test_app_divkit/me/views/shared/form_control.dart';

class EngineBottomSheet extends StatefulWidget {
  const EngineBottomSheet({
    super.key,
    required this.engineTypes,
    required this.engineEtats,
  });

  final List<TypesEngins> engineTypes;
  final List<EtatsEngins> engineEtats;

  @override
  State<EngineBottomSheet> createState() => _EngineBottomSheetState();
}

class _EngineBottomSheetState extends State<EngineBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final List<FormControl> controls = [
      FormControl(
        type: ControlType.label,
        name: "",
        label: "Ajouter un engin",
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
      ),
      FormControl(
        type: ControlType.dropdownSearch,
        name: "typesEngin",
        label: "Type d'engin",
        searchDropdownItems: widget.engineTypes
            .map((e) => DropdownItem(id: e.id, value: e, label: e.french_name))
            .toList(),
        required: true,
      ),
      FormControl(
        type: ControlType.dropdownSearch,
        name: "etatsEngin",
        label: "Etat de l'engin",
        searchDropdownItems: widget.engineEtats
            .map((e) => DropdownItem(id: e.id, value: e, label: e.libelle))
            .toList(),
        required: true,
      ),
      FormControl(
        type: ControlType.textarea,
        name: "observation",
        label: "Observation",
      ),
      FormControl(type: ControlType.label, name: "", label: ""),
    ];

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.70,
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          child: AppForm(controls: controls, formKey: _formKey),
        ),
      ),
    );
  }
}
