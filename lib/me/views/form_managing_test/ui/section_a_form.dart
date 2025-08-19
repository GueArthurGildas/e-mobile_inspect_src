import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/tbl_ref_formA.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/step_1/step_one_controller.dart';
import '../state/inspection_wizard_ctrl.dart';

class SectionAForm extends StatefulWidget {
  const SectionAForm({super.key});
  @override
  State<SectionAForm> createState() => _SectionAFormState();
}

class _SectionAFormState extends State<SectionAForm> with AutomaticKeepAliveClientMixin {
  final _key = GlobalKey<FormState>();
  late Map<String, dynamic> _local;

  Color get _orangeColor => const Color(0xFFFF6A00);

  // final StepOneController _stepCtrl = StepOneController();

  final MyStepOneController _stepCtrl= MyStepOneController();

  bool _loadingRefs = true; // indique si les listes de référence sont chargées

  Future<void> _initRefs() async {
    await _stepCtrl.loadData();

    final initial = context.read<InspectionWizardCtrl>().section('a') ?? {};

    setState(() {
      _loadingRefs = false;
    });

      _local = {
        // on part de ce qui est déjà dans le wizard (si tu as sauvegardé avant)
        ...initial,

        // Dates (ne remplace QUE si absent)
        'dateArriveeEffective': initial['dateArriveeEffective'],
        'dateDebutInspection' : initial['dateDebutInspection'],
        'dateEscaleNavire'    : initial['dateEscaleNavire'],

        // Dropdowns (si null → on met le 1er élément dispo)
        'portInspection': initial['portInspection']
            ?? (_stepCtrl.portsList.isNotEmpty ? _stepCtrl.portsList.first.id.toString() : null),

        // 'pavillonNavire': initial['pavillonNavire']
        //   ?? (_stepCtrl.pavillonsList.isNotEmpty ? _stepCtrl.pavillonsList.first.id.toString() : null),

        'typeNavire': initial['typeNavire']
            ?? (_stepCtrl.typesNavireList.isNotEmpty ? _stepCtrl.typesNavireList.first.id.toString() : null),

        'paysEscale': initial['paysEscale']
            ?? (_stepCtrl.pays.isNotEmpty ? _stepCtrl.pays.first.id.toString() : null),

        'portEscale': initial['portEscale']
            ?? (_stepCtrl.portsList.isNotEmpty ? _stepCtrl.portsList.first.id.toString() : null),

        'objet': initial['objet']
            ?? (_stepCtrl.motifsEntreeList.isNotEmpty ? _stepCtrl.motifsEntreeList.first.id.toString() : null),

        // Textuels
        'maillage'        : initial['maillage'] ?? '',
        'dimensionsCales' : initial['dimensionsCales'] ?? '',
        'marquageNavire'  : initial['marquageNavire'] ?? '',
        'baliseVMS'       : initial['baliseVMS'] ?? '',
        'observation'     : initial['observation'] ?? '',

        // Switch / objet imbriqué
        'demandePrealablePort': initial['demandePrealablePort'] ?? false,
        'observateurEmbarque' : initial['observateurEmbarque'] ?? {'present': false},
      };


  }
  @override
  void initState() {
    super.initState();
    _initRefs(); // charge les listes de référence

  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _pickDate(BuildContext context, String key) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tryParseDate(_local[key]) ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _local[key] = picked.toIso8601String(); // garde un format ISO simple
      });
    }
  }

  DateTime? _tryParseDate(dynamic v) {
    // Accepte DateTime, String ISO, ou null
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) {
      try {
        return DateTime.parse(v);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  String _dateLabel(dynamic v) {
    final dt = _tryParseDate(v);
    if (dt == null) return 'Sélectionner une date';
    // Affichage court (yyyy-mm-dd)
    return dt.toIso8601String().substring(0, 10);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loadingRefs) {
      return const Center(child: CircularProgressIndicator());
    }
    final ctrl = context.read<InspectionWizardCtrl>();

    final bool observateurPresent =
        ((_local['observateurEmbarque'] ?? const {'present': false})['present'] ?? false) == true;

    return Form(
      key: _key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ======= Dates de l'inspection =======
          Text(
            "Dates de l'inspection",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: _orangeColor),
          ),
          const SizedBox(height: 12),

          // Date d'arrivée effective du navire
          TextFormField(
            readOnly: true,
            decoration: const InputDecoration(labelText: "Date d'arrivée effective du navire"),
            controller: TextEditingController(text: _dateLabel(_local['dateArriveeEffective'])),
            onTap: () => _pickDate(context, 'dateArriveeEffective'),
          ),
          const SizedBox(height: 12),

          // Date de début inspection
          TextFormField(
            readOnly: true,
            decoration: const InputDecoration(labelText: "Date de début de l'inspection"),
            controller: TextEditingController(text: _dateLabel(_local['dateDebutInspection'])),
            onTap: () => _pickDate(context, 'dateDebutInspection'),
          ),
          const SizedBox(height: 20),

          // ======= Informations du navire =======
          Text(
            "Informations du navire",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: _orangeColor),
          ),
          const SizedBox(height: 20),

          // Port de l'inspection
          DropdownButtonFormField<String>(
            value: (_local['portInspection'] as String?),
            decoration: const InputDecoration(labelText: "Port de l'inspection"),
            items: _stepCtrl.portsList
                .map((e) => DropdownMenuItem<String>(value: e.id.toString(), child: Text(e.libelle.toString())))
                .toList(),
            onChanged: (v) => setState(() => _local['portInspection'] = v),
            validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
          ),
          const SizedBox(height: 12),

          // // Pavillon du navire
          // DropdownButtonFormField<String>(
          //   value: (_local['pavillonNavire'] as String?),
          //   decoration: const InputDecoration(labelText: "Pavillon du navire"),
          //   items: _stepCtrl.pavillonsList
          //       .map((e) => DropdownMenuItem<String>(value: e.id.toString(), child: Text(e.libelle.toString())))
          //       .toList(),
          //   onChanged: (v) => setState(() => _local['pavillonNavire'] = v),
          //   validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
          // ),
          const SizedBox(height: 12),

          // Type de navire
          DropdownButtonFormField<String>(
            value: (_local['typeNavire'] as String?),
            decoration: const InputDecoration(labelText: "Type de navire"),
            items: _stepCtrl.typesNavireList
                .map((e) => DropdownMenuItem<String>(value: e.id.toString(), child: Text(e.libelle.toString())))
                .toList(),
            onChanged: (v) => setState(() => _local['typeNavire'] = v),
            validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
          ),
          const SizedBox(height: 12),

          // Maillage (mm)
          TextFormField(
            initialValue: (_local['maillage'] ?? '').toString(),
            decoration: const InputDecoration(labelText: "Maillage (mm)"),
            keyboardType: TextInputType.number,
            validator: (v) => (v == null || v.isEmpty)
                ? 'Requis'
                : (int.tryParse(v) == null ? 'Nombre invalide' : null),
            onChanged: (v) => _local['maillage'] = v, // garde String comme ta source
          ),
          const SizedBox(height: 12),

          // Dimensions des cales (m)
          TextFormField(
            initialValue: (_local['dimensionsCales'] ?? '').toString(),
            decoration: const InputDecoration(labelText: "Dimension des cales (m)"),
            onChanged: (v) => _local['dimensionsCales'] = v,
          ),
          const SizedBox(height: 12),

          // Marquage du navire
          TextFormField(
            initialValue: (_local['marquageNavire'] ?? '').toString(),
            decoration: const InputDecoration(labelText: "Marquage du navire"),
            onChanged: (v) => _local['marquageNavire'] = v,
          ),
          const SizedBox(height: 12),

          // Balise VMS
          TextFormField(
            initialValue: (_local['baliseVMS'] ?? '').toString(),
            decoration: const InputDecoration(labelText: "Balise VMS"),
            onChanged: (v) => _local['baliseVMS'] = v,
          ),
          const SizedBox(height: 12),

          // Pays d'escale
          DropdownButtonFormField<String>(
            value: (_local['paysEscale'] as String?),
            decoration: const InputDecoration(labelText: "Pays d'escale"),
            items: _stepCtrl.pays
                .map((e) => DropdownMenuItem<String>(value: e.id.toString(), child: Text(e.libelle.toString())))
                .toList(),
            onChanged: (v) => setState(() => _local['paysEscale'] = v),
            validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
          ),
          const SizedBox(height: 12),

          // Port d'escale
          DropdownButtonFormField<String>(
            value: (_local['portEscale'] as String?),
            decoration: const InputDecoration(labelText: "Port d'escale"),
            items: _stepCtrl.portsList
                .map((e) => DropdownMenuItem<String>(value: e.id.toString(), child: Text(e.libelle.toString())))
                .toList(),
            onChanged: (v) => setState(() => _local['portEscale'] = v),
            validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
          ),
          const SizedBox(height: 12),

          // Date d'escale
          TextFormField(
            readOnly: true,
            decoration: const InputDecoration(labelText: "Date d'escale"),
            controller: TextEditingController(text: _dateLabel(_local['dateEscaleNavire'])),
            onTap: () => _pickDate(context, 'dateEscaleNavire'),
          ),
          const SizedBox(height: 12),

          // Demande préalable d'entrée au port ?
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Demande préalable d'entrée au port ?"),
            value: (_local['demandePrealablePort'] ?? false) == true,
            onChanged: (v) => setState(() => _local['demandePrealablePort'] = v),
          ),
          const SizedBox(height: 8),

          // Observateur embarqué ?
          // SwitchListTile(
          //   contentPadding: EdgeInsets.zero,
          //   title: const Text("Observateur embarqué ?"),
          //   value: ((_local['observateurEmbarque'] ?? const {'present': false})['present'] ?? false) == true,
          //   onChanged: (value) async {
          //     _local['observateurEmbarque'] ??= <String, dynamic>{};
          //     if (value == true) {
          //       final dynamic observerData = await Common.showBottomSheet(
          //         context,
          //         ExtraFieldsSheet(
          //           initialValues: _local['observateurEmbarque'] ?? {},
          //         ),
          //       );
          //       if (!mounted) return;
          //       setState(() {
          //         if (observerData != null) {
          //           _local['observateurEmbarque'] = {'present': true, ...observerData};
          //         } else {
          //           _local['observateurEmbarque'] = {'present': true, ...(_local['observateurEmbarque'] as Map)};
          //         }
          //       });
          //     } else {
          //       setState(() {
          //         (_local['observateurEmbarque'] as Map)['present'] = false;
          //       });
          //     }
          //   },
          // ),
          //
          // // Bouton "Voir les informations de l'observateur"
          // if (observateurPresent)
          //   Align(
          //     alignment: Alignment.centerLeft,
          //     child: TextButton(
          //       onPressed: () async {
          //         final dynamic observerData = await Common.showBottomSheet(
          //           context,
          //           ExtraFieldsSheet(
          //             initialValues: _local['observateurEmbarque'] ?? {},
          //           ),
          //         );
          //         if (!mounted) return;
          //         if (observerData != null) {
          //           setState(() {
          //             _local['observateurEmbarque'] = {'present': true, ...observerData};
          //           });
          //         }
          //       },
          //       child: const Text(
          //         "Voir les informations de l'observateur",
          //         style: TextStyle(fontSize: 12.0, decoration: TextDecoration.underline),
          //       ),
          //     ),
          //   ),

          const SizedBox(height: 20),

          // ======= Motifs / objectifs =======
          Text(
            "Motifs ou objectifs  d'entrée au port",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0, color: _orangeColor),
          ),
          const SizedBox(height: 20),

          // Objet (motif)
          DropdownButtonFormField<String>(
            value: (_local['objet'] as String?),
            decoration: const InputDecoration(labelText: "Objet"),
            items: _stepCtrl.motifsEntreeList
                .map((e) => DropdownMenuItem<String>(value: e.id.toString(), child: Text(e.libelle.toString())))
                .toList(),
            onChanged: (v) => setState(() => _local['objet'] = v),
            // validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
          ),
          const SizedBox(height: 12),

          // Observation (textarea)
          TextFormField(
            initialValue: (_local['observation'] ?? '').toString(),
            decoration: const InputDecoration(labelText: "Observation"),
            maxLines: 4,
            onChanged: (v) => _local['observation'] = v,
          ),

          const SizedBox(height: 20),

          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Sauvegarder cette section'),
              onPressed: () async {
                if (!_key.currentState!.validate()) return;
                await context.read<InspectionWizardCtrl>().saveSection('a', _local);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Section A sauvegardée.')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
