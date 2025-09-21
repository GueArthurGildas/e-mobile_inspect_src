import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/tbl_ref_formA.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/wizard_screen.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/step_1/step_one_controller.dart';
import '../state/inspection_wizard_ctrl.dart';
import 'package:intl/intl.dart';

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
        'numiccat'     : initial['numiccat'] ?? '',


        // Switch / objet imbriqué
        'demandePrealablePort': initial['demandePrealablePort'] ?? false,
        // 'observateurEmbarque' : initial['observateurEmbarque'] ?? {'present': false},
        'observateurEmbarque': (initial['observateurEmbarque'] is Map)
            ? initial['observateurEmbarque']
            : {'present': false},

      };


    // Construire _local['objets'] à partir de l'existant (objet) ou de initial['objets']
    final List<Map<String, dynamic>> selectedObjets = [];
    if (initial['objets'] is List) {
      for (final e in (initial['objets'] as List)) {
        if (e is Map) {
          selectedObjets.add({
            'id': e['id'].toString(),
            'libelle': (e['libelle'] ?? '').toString(),
          });
        }
      }
    } else if (initial['objet'] != null) {
      final id = initial['objet'].toString();
      final match = _stepCtrl.motifsEntreeList.where((m) => m.id.toString() == id);
      if (match.isNotEmpty) {
        selectedObjets.add({
          'id': id,
          'libelle': (match.first.libelle ?? '').toString(),
        });
      }
    }

// Assigner dans _local
    _local['objets'] = selectedObjets;

// Et garder _local['objet'] synchronisé si vide
    if (_local['objet'] == null && selectedObjets.isNotEmpty) {
      _local['objet'] = selectedObjets.first['id'];
    }


  }

  Future<void> _openObservateurSheet() async {
    final current = Map<String, dynamic>.from(
      (_local['observateurEmbarque'] as Map?) ?? const {},
    );

    final Map<String, dynamic>? data = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _ObservateurSheet(initial: current),
    );

    if (!mounted) return;
    if (data != null) {
      setState(() {
        _local['observateurEmbarque'] = {
          'present': true,
          ...data, // nom, prenom, fonction, entreprise, numeroDoc
        };
      });
    }
  }



// =======================
//   Function to pick date + time
// =======================
// 4) Pick date THEN time (keeps your storage in _local; parses existing time if present)
  Future<void> _pickDateTime(BuildContext context, String key) async {
    // If there’s already a value, use it to prefill the pickers
    DateTime? current;
    final raw = _local[key];
    if (raw is DateTime) current = raw;
    if (raw is String) current = DateTime.tryParse(raw);

    final DateTime initialDate = current ?? DateTime.now();

    // Step 1: date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    // Step 2: time (24h)
    final TimeOfDay initialTime = current != null
        ? TimeOfDay(hour: current.hour, minute: current.minute)
        : TimeOfDay.now();

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (pickedTime == null) return;

    // Combine
    final DateTime pickedDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      // Keep your existing logic: store either DateTime or ISO string.
      // If you were storing strings before, keep it consistent:
      _local[key] = pickedDateTime.toIso8601String();
      // If you prefer DateTime object, use: _local[key] = pickedDateTime;
    });
  }

  Widget _buildObservateurSummary(Map obs) {
    final nom = (obs['nom'] ?? '').toString();
    final prenom = (obs['prenom'] ?? '').toString();
    final fonction = (obs['fonction'] ?? '').toString();
    final entreprise = (obs['entreprise'] ?? '').toString();
    final numeroDoc = (obs['numeroDoc'] ?? '').toString();

    if ((nom + prenom + fonction + entreprise + numeroDoc).trim().isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          "Aucune information saisie pour l’observateur.",
          style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black12.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryRow("Nom & Prénom", [nom, prenom].where((e) => e.isNotEmpty).join(' ')),
          _summaryRow("Fonction", fonction),
          _summaryRow("Entreprise", entreprise),
          _summaryRow("N° Passeport / NumCIV", numeroDoc),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _openObservateurSheet,
              icon: const Icon(Icons.edit),
              label: const Text("Modifier"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? "-" : value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    _initRefs(); // charge les listes de référence

  }


  String _motifsDisplayText() {
    final List<Map<String, dynamic>> list =
        ((_local['objets'] as List?)?.cast<Map<String, dynamic>>()) ?? const [];
    if (list.isEmpty) return '';
    if (list.length <= 2) {
      return list.map((m) => (m['libelle'] ?? '').toString()).join(', ');
    }
    return '${list[0]['libelle']}, ${list[1]['libelle']} +${list.length - 2} autres';
  }

  Future<void> _openMotifMultiPicker() async {
    final List<Map<String, dynamic>> current =
        ((_local['objets'] as List?)?.cast<Map<String, dynamic>>()) ?? const [];

    final picked = await showModalBottomSheet<List<Map<String, String>>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _MotifMultiPickerSheet(
        items: _stepCtrl.motifsEntreeList,                 // source
        initialSelectedIds: current.map((e) => e['id']!.toString()).toSet(),
      ),
    );

    if (picked != null) {
      setState(() {
        // picked: List<Map<String,String>> {[id, libelle]}
        _local['objets'] = picked
            .map((m) => {'id': m['id']!, 'libelle': m['libelle']!})
            .toList();

        // Compatibilité: garder 'objet' sur le premier élément si présent
        _local['objet'] = picked.isNotEmpty ? picked.first['id'] : null;
      });
    }
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

  String? _labelForTypeNavire(String? id) {
    if (id == null) return null;
    final match = _stepCtrl.typesNavireList.where((e) => e.id.toString() == id);
    if (match.isEmpty) return null;
    return match.first.libelle?.toString();
  }

  String? _labelForPays(String? id) {
    if (id == null) return null;
    final match = _stepCtrl.pays.where((e) => e.id.toString() == id);
    if (match.isEmpty) return null;
    return match.first.libelle?.toString();
  }

  Future<void> _openPaysPicker() async {
    final picked = await showModalBottomSheet<_PaysPickResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _PaysPickerSheet(
        items: _stepCtrl.pays,                       // ta liste de Pays
        initialId: _local['paysEscale'] as String?,  // id actuellement sélectionné
      ),
    );

    if (picked != null) {
      setState(() {
        _local['paysEscale'] = picked.id; // id en String
      });
    }
  }



  Future<void> _openTypeNavirePicker() async {
    final picked = await showModalBottomSheet<_TypeNavirePickResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _TypeNavirePickerSheet(
        items: _stepCtrl.typesNavireList,
        initialId: _local['typeNavire'] as String?,
      ),
    );

    if (picked != null) {
      setState(() {
        _local['typeNavire'] = picked.id; // id en String
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

  // String _dateLabel(dynamic v) {
  //   final dt = _tryParseDate(v);
  //   if (dt == null) return 'Sélectionner une date';
  //   // Affichage court (yyyy-mm-dd)
  //   return dt.toIso8601String().substring(0, 10);
  // }

  // 3) Make your label show date + hour (works if you store DateTime OR ISO string)
  String _dateLabel(dynamic v) {
    if (v == null) return '';
    DateTime dt;
    if (v is DateTime) {
      dt = v;
    } else if (v is String) {
      dt = DateTime.tryParse(v) ?? DateTime.now();
    } else if (v is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(v);
    } else {
      return v.toString();
    }
    // 👉 Shows day/month/year + 24h time
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loadingRefs) {
      return const Center(child: CircularProgressIndicator());
    }
    final ctrl = context.read<InspectionWizardCtrl>();

    // Observateur embarqué ?
    final Map<String, dynamic> _obs =
    Map<String, dynamic>.from((_local['observateurEmbarque'] as Map?) ?? const {'present': false});
    final bool observateurPresent = (_obs['present'] ?? false) == true;


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
            onTap: () => _pickDateTime(context, 'dateArriveeEffective'),
          ),
          const SizedBox(height: 12),

          // Date de début inspection
          // TextFormField(
          //   readOnly: true,
          //   decoration: const InputDecoration(labelText: "Date de début de l'inspection"),
          //   controller: TextEditingController(text: _dateLabel(_local['dateDebutInspection'])),
          //   onTap: () => _pickDate(context, 'dateDebutInspection'),
          // ),

          TextFormField(
            readOnly: true,
            decoration: const InputDecoration(labelText: "Date de début de l'inspection"),
            controller: TextEditingController(
              text: _dateLabel(_local['dateDebutInspection']),
            ),
            onTap: () => _pickDateTime(context, 'dateDebutInspection'),
          ),
          const SizedBox(height: 20),
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
          // DropdownButtonFormField<String>(
          //   value: (_local['typeNavire'] as String?),
          //   decoration: const InputDecoration(labelText: "Type de navire"),
          //   items: _stepCtrl.typesNavireList
          //       .map((e) => DropdownMenuItem<String>(value: e.id.toString(), child: Text(e.libelle.toString())))
          //       .toList(),
          //   onChanged: (v) => setState(() => _local['typeNavire'] = v),
          //   validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
          // ),

          FormField<String>(
            initialValue: _local['typeNavire'] as String?,
            validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
            builder: (state) {
              final labelText = "Type de navire";
              final selectedLabel = _labelForTypeNavire(_local['typeNavire'] as String?);
              final hasError = state.hasError;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _stepCtrl.typesNavireList.isEmpty ? null : () async {
                      await _openTypeNavirePicker();
                      // synchronise la valeur du FormField avec _local
                      state.didChange(_local['typeNavire'] as String?);
                    },
                    child: InputDecorator(
                      isEmpty: selectedLabel == null || selectedLabel.isEmpty,
                      decoration: InputDecoration(
                        labelText: labelText,
                        errorText: hasError ? state.errorText : null,
                        suffixIcon: const Icon(Icons.search),
                        enabled: _stepCtrl.typesNavireList.isNotEmpty,
                      ),
                      child: Text(
                        selectedLabel ?? 'Sélectionner…',
                        style: TextStyle(
                          color: (selectedLabel == null)
                              ? Theme.of(context).hintColor
                              : null,
                        ),
                      ),
                    ),
                  ),
                  if (_stepCtrl.typesNavireList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        "Aucune donnée disponible. Synchronisez d'abord.",
                        style: TextStyle(fontSize: 12, color: Colors.redAccent),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),

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

          // Numero ICCAT
          TextFormField(
            initialValue: (_local['numiccat'] ?? '').toString(),
            decoration: const InputDecoration(labelText: "Numero ICCAT"),
            keyboardType: TextInputType.text,
            validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
            onChanged: (v) => _local['numiccat'] = v, // garde String comme ta source

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
          // DropdownButtonFormField<String>(
          //   value: (_local['paysEscale'] as String?),
          //   decoration: const InputDecoration(labelText: "Pays d'escale"),
          //   items: _stepCtrl.pays
          //       .map((e) => DropdownMenuItem<String>(value: e.id.toString(), child: Text(e.libelle.toString())))
          //       .toList(),
          //   onChanged: (v) => setState(() => _local['paysEscale'] = v),
          //   validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
          // ),
          FormField<String>(
            initialValue: _local['paysEscale'] as String?,
            validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
            builder: (state) {
              final selectedLabel = _labelForPays(_local['paysEscale'] as String?);
              final hasError = state.hasError;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _stepCtrl.pays.isEmpty ? null : () async {
                      await _openPaysPicker();
                      // synchronise la valeur du FormField avec _local
                      state.didChange(_local['paysEscale'] as String?);
                    },
                    child: InputDecorator(
                      isEmpty: selectedLabel == null || selectedLabel.isEmpty,
                      decoration: InputDecoration(
                        labelText: "Pays d'escale",
                        errorText: hasError ? state.errorText : null,
                        suffixIcon: const Icon(Icons.search),
                        enabled: _stepCtrl.pays.isNotEmpty,
                      ),
                      child: Text(
                        selectedLabel ?? 'Sélectionner…',
                        style: TextStyle(
                          color: (selectedLabel == null)
                              ? Theme.of(context).hintColor
                              : null,
                        ),
                      ),
                    ),
                  ),
                  if (_stepCtrl.pays.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        "Aucune donnée disponible. Synchronisez d'abord.",
                        style: TextStyle(fontSize: 12, color: Colors.redAccent),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),


          const SizedBox(height: 12),

          // Port d'escale
          // DropdownButtonFormField<String>(
          //   value: (_local['portEscale'] as String?),
          //   decoration: const InputDecoration(labelText: "Port d'escale"),
          //   items: _stepCtrl.portsList
          //       .map((e) => DropdownMenuItem<String>(value: e.id.toString(), child: Text(e.libelle.toString())))
          //       .toList(),
          //   onChanged: (v) => setState(() => _local['portEscale'] = v),
          //   validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
          // ),


          //Port d'escale
          TextFormField(
            initialValue: (_local['portEscale'] ?? '').toString(),
            decoration: const InputDecoration(labelText: "Port d'escale"),
            keyboardType: TextInputType.text,
            validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
            onChanged: (v) => _local['portEscale'] = v, // garde String comme ta source
          ),

          const SizedBox(height: 12),

          // Date d'escale
          TextFormField(
            readOnly: true,
            decoration: const InputDecoration(labelText: "Date d'escale"),
            controller: TextEditingController(text: _dateLabel(_local['dateEscaleNavire'])),
            onTap: () => _pickDateTime(context, 'dateEscaleNavire'),
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

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Observateur embarqué ?"),
            value: observateurPresent,
            onChanged: (value) async {
              if (value == true) {
                // Active et ouvre la feuille pour saisir/éditer
                await _openObservateurSheet();
                // Si l’utilisateur a fermé sans enregistrer, on garde present=true mais on conserve l’existant
                if (!mounted) return;
                setState(() {
                  _local['observateurEmbarque'] ??= {'present': true};
                  (_local['observateurEmbarque'] as Map)['present'] = true;
                });
              } else {
                setState(() {
                  _local['observateurEmbarque'] = {'present': false};
                });
              }
            },
          ),

          if (observateurPresent) _buildObservateurSummary(_obs),


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
          // DropdownButtonFormField<String>(
          //   value: (_local['objet'] as String?),
          //   decoration: const InputDecoration(labelText: "Objet"),
          //   items: _stepCtrl.motifsEntreeList
          //       .map((e) => DropdownMenuItem<String>(value: e.id.toString(), child: Text(e.libelle.toString())))
          //       .toList(),
          //   onChanged: (v) => setState(() => _local['objet'] = v),
          //   // validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
          // ),

          FormField<String>(
            validator: (_) {
              final List list = (_local['objets'] as List?) ?? const [];
              return list.isEmpty ? 'Requis' : null;
            },
            builder: (state) {
              final hasError = state.hasError;
              final text = _motifsDisplayText();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _stepCtrl.motifsEntreeList.isEmpty ? null : () async {
                      await _openMotifMultiPicker();
                      // sync FormField (on passe un texte, mais la validation lit _local['objets'])
                      state.didChange(_motifsDisplayText());
                    },
                    child: InputDecorator(
                      isEmpty: text == 'Sélectionner…',
                      decoration: InputDecoration(
                        labelText: "Objet (motif d'entrée au port)",
                        errorText: hasError ? state.errorText : null,
                        suffixIcon: const Icon(Icons.search),
                        enabled: _stepCtrl.motifsEntreeList.isNotEmpty,
                      ),
                      child: Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: (text == 'Sélectionner…')
                              ? Theme.of(context).hintColor
                              : null,
                        ),
                      ),
                    ),
                  ),
                  if (_stepCtrl.motifsEntreeList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        "Aucune donnée disponible. Synchronisez d'abord.",
                        style: TextStyle(fontSize: 12, color: Colors.redAccent),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),

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
              style: filledOrangeStyle(),
              label: const Text('Sauvegarder cette section'),
              onPressed: () async {
                if (!_key.currentState!.validate()) return;
                await context.read<InspectionWizardCtrl>().saveSection('a', _local);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,        // floating for elegance
                      margin: const EdgeInsets.all(16),           // nice spacing from edges
                      duration: const Duration(seconds: 3),       // visible long enough
                      backgroundColor: Colors.green.shade600,     // ✅ success green
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),  // rounded corners
                      ),
                      content: Row(
                        children: const [
                          Icon(Icons.check_circle_outline,
                              color: Colors.white, size: 22),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Section A sauvegardée avec succès.',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _TypeNavirePickResult {
  final String id;
  final String label;
  _TypeNavirePickResult({required this.id, required this.label});
}

class _TypeNavirePickerSheet extends StatefulWidget {
  const _TypeNavirePickerSheet({
    required this.items,
    this.initialId,
  });

  final List<dynamic> items; // List<Typenavires>
  final String? initialId;

  @override
  State<_TypeNavirePickerSheet> createState() => _TypeNavirePickerSheetState();
}

class _TypeNavirePickerSheetState extends State<_TypeNavirePickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  late List<dynamic> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = List.of(widget.items);
    _searchCtrl.addListener(_applyFilter);
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _filtered = List.of(widget.items);
      } else {
        _filtered = widget.items.where((e) {
          final label = (e.libelle ?? '').toString().toLowerCase();
          final id = e.id.toString().toLowerCase();
          return label.contains(q) || id.contains(q);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        expand: false,
        // Donne plus de hauteur en paysage:
        minChildSize: 0.30,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (ctx, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Rechercher un type de navire",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchCtrl,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: "Nom…",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),

              // ⚠️ Pas de ListView imbriqué : on mappe directement
              ..._filtered.map((e) {
                final id = e.id.toString();
                final label = (e.libelle ?? '').toString();
                final selected = widget.initialId == id;

                return ListTile(
                  title: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                  // ⬅️ plus de subtitle avec l’ID
                  trailing: selected ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    Navigator.of(context).pop(
                      _TypeNavirePickResult(id: id, label: label),
                    );
                  },
                );
              }).toList(),

              const SizedBox(height: 12),
            ],
          );
        },
      ),

    );
  }
}

class _PaysPickResult {
  final String id;
  final String label;
  _PaysPickResult({required this.id, required this.label});
}

class _PaysPickerSheet extends StatefulWidget {
  const _PaysPickerSheet({
    required this.items,    // List<Pays>
    this.initialId,
  });

  final List<dynamic> items;
  final String? initialId;

  @override
  State<_PaysPickerSheet> createState() => _PaysPickerSheetState();
}

class _PaysPickerSheetState extends State<_PaysPickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  late List<dynamic> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = List.of(widget.items);
    _searchCtrl.addListener(_applyFilter);
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _filtered = List.of(widget.items);
      } else {
        _filtered = widget.items.where((e) {
          final label = (e.libelle ?? '').toString().toLowerCase();
          final id = e.id.toString().toLowerCase();
          return label.contains(q) || id.contains(q);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        expand: false,
        // Donne plus de hauteur en paysage:
        minChildSize: 0.30,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (ctx, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Rechercher un pays",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchCtrl,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: "Nom…",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),

              // ⚠️ Pas de ListView imbriqué : on mappe directement
              ..._filtered.map((e) {
                final id = e.id.toString();
                final label = (e.libelle ?? '').toString();
                final selected = widget.initialId == id;

                return ListTile(
                  title: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                  // ⬅️ plus de subtitle avec l’ID
                  trailing: selected ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    Navigator.of(context).pop(
                      _PaysPickResult(id: id, label: label),
                    );
                  },
                );
              }).toList(),

              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );

  }
}



class _MotifMultiPickerSheet extends StatefulWidget {
  const _MotifMultiPickerSheet({
    required this.items,                // List<dynamic> avec .id et .libelle
    required this.initialSelectedIds,   // Set<String>
  });

  final List<dynamic> items;
  final Set<String> initialSelectedIds;

  @override
  State<_MotifMultiPickerSheet> createState() => _MotifMultiPickerSheetState();
}

class _MotifMultiPickerSheetState extends State<_MotifMultiPickerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  late List<dynamic> _filtered;
  late Set<String> _selected; // ids sélectionnés

  @override
  void initState() {
    super.initState();
    _filtered = List.of(widget.items);
    _selected = Set<String>.from(widget.initialSelectedIds);
    _searchCtrl.addListener(_applyFilter);
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _filtered = List.of(widget.items);
      } else {
        _filtered = widget.items.where((e) {
          final label = (e.libelle ?? '').toString().toLowerCase();
          return label.contains(q); // pas de recherche par ID
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.30,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (ctx, scrollController) {
          return Column(
            children: [
              // poignée
              const SizedBox(height: 8),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              // Titre
              const Text(
                "Sélectionner un ou plusieurs motifs",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),

              // Recherche
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchCtrl,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "Motif…",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Liste (scroll unique -> évite l'overflow)
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filtered.length,
                  itemBuilder: (ctx, i) {
                    final e = _filtered[i];
                    final id = e.id.toString();
                    final label = (e.libelle ?? '').toString();
                    final selected = _selected.contains(id);

                    return CheckboxListTile(
                      value: selected,
                      onChanged: (_) => _toggle(id),
                      title: Text(label,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16),
                    );
                  },
                ),
              ),

              // Barre d'action collée en bas
              SafeArea(
                top: false,
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => setState(() => _selected.clear()),
                        child: const Text("Effacer"),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () {
                          // Construire le résultat {id, libelle} sans afficher d'ID dans l'UI
                          final list = <Map<String, String>>[];
                          for (final e in widget.items) {
                            final id = e.id.toString();
                            if (_selected.contains(id)) {
                              list.add({
                                'id': id,
                                'libelle': (e.libelle ?? '').toString(),
                              });
                            }
                          }
                          Navigator.of(context).pop(list);
                        },
                        child: const Text("Appliquer"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ObservateurSheet extends StatefulWidget {
  const _ObservateurSheet({required this.initial});
  final Map<String, dynamic> initial;

  @override
  State<_ObservateurSheet> createState() => _ObservateurSheetState();
}

class _ObservateurSheetState extends State<_ObservateurSheet> {
  late final TextEditingController _nomCtrl;
  late final TextEditingController _prenomCtrl;
  late final TextEditingController _fonctionCtrl;
  late final TextEditingController _entrepriseCtrl;
  late final TextEditingController _numeroDocCtrl;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nomCtrl = TextEditingController(text: (widget.initial['nom'] ?? '').toString());
    _prenomCtrl = TextEditingController(text: (widget.initial['prenom'] ?? '').toString());
    _fonctionCtrl = TextEditingController(text: (widget.initial['fonction'] ?? '').toString());
    _entrepriseCtrl = TextEditingController(text: (widget.initial['entreprise'] ?? '').toString());
    _numeroDocCtrl = TextEditingController(text: (widget.initial['numeroDoc'] ?? '').toString());
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _fonctionCtrl.dispose();
    _entrepriseCtrl.dispose();
    _numeroDocCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.30,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (ctx, scrollController) {
          return Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Informations de l'observateur",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _nomCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: "Nom"),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _prenomCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: "Prénom"),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _fonctionCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: "Fonction"),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _entrepriseCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: "Entreprise"),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _numeroDocCtrl,
                  decoration: const InputDecoration(labelText: "N° Passeport / NumCIV"),
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text("Annuler"),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () {
                        // si tu veux forcer nom/prénom, ajoute un validator ici
                        final result = <String, dynamic>{
                          'nom': _nomCtrl.text.trim(),
                          'prenom': _prenomCtrl.text.trim(),
                          'fonction': _fonctionCtrl.text.trim(),
                          'entreprise': _entrepriseCtrl.text.trim(),
                          'numeroDoc': _numeroDocCtrl.text.trim(),
                        };
                        Navigator.of(context).pop(result);
                      },
                      icon: const Icon(Icons.save),
                      label: const Text("Enregistrer"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

