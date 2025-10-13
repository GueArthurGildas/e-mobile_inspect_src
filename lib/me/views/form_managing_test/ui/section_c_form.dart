import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:e_Inspection_APP/me/views/form_managing_test/ui/tbl_ref_formC.dart';
import 'package:e_Inspection_APP/me/views/form_managing_test/ui/wizard_screen.dart';

import '../state/inspection_wizard_ctrl.dart';
import 'package:e_Inspection_APP/me/views/inspection/section_inspection_form/step_1/step_one_controller.dart';

// ===============================
// Modèle local
// ===============================
class CDocItem {
  final String typeDocumentId;
  final String typeDocumentLabel;
  final String identifiant;
  final String delivrePar;
  final String? dateEmission;   // stockage yyyy-MM-dd
  final String? dateExpiration; // stockage yyyy-MM-dd
  final bool verifie;

  // Pièces jointes (chemins locaux persistés)
  final List<String> attachments;

  CDocItem({
    required this.typeDocumentId,
    required this.typeDocumentLabel,
    required this.identifiant,
    required this.delivrePar,
    this.dateEmission,
    this.dateExpiration,
    this.verifie = false,
    this.attachments = const [],
  });

  CDocItem copyWith({
    String? typeDocumentId,
    String? typeDocumentLabel,
    String? identifiant,
    String? delivrePar,
    String? dateEmission,
    String? dateExpiration,
    bool? verifie,
    List<String>? attachments,
  }) {
    return CDocItem(
      typeDocumentId: typeDocumentId ?? this.typeDocumentId,
      typeDocumentLabel: typeDocumentLabel ?? this.typeDocumentLabel,
      identifiant: identifiant ?? this.identifiant,
      delivrePar: delivrePar ?? this.delivrePar,
      dateEmission: dateEmission ?? this.dateEmission,
      dateExpiration: dateExpiration ?? this.dateExpiration,
      verifie: verifie ?? this.verifie,
      attachments: attachments ?? this.attachments,
    );
  }

  Map<String, dynamic> toMap() => {
    'typeDocumentId': typeDocumentId,
    'typeDocumentLabel': typeDocumentLabel,
    'identifiant': identifiant,
    'delivrePar': delivrePar,
    'dateEmission': dateEmission,
    'dateExpiration': dateExpiration,
    'verifie': verifie,
    'attachments': attachments,
  };

  factory CDocItem.fromMap(Map<String, dynamic> m) => CDocItem(
    typeDocumentId: (m['typeDocumentId'] ?? '').toString(),
    typeDocumentLabel: (m['typeDocumentLabel'] ?? '').toString(),
    identifiant: (m['identifiant'] ?? '').toString(),
    delivrePar: (m['delivrePar'] ?? '').toString(),
    dateEmission: (m['dateEmission'] as String?),
    dateExpiration: (m['dateExpiration'] as String?),
    verifie: (m['verifie'] as bool?) ?? false,
    attachments: (m['attachments'] as List?)?.map((e) => e.toString()).toList() ?? const [],
  );
}

// ===============================
// Section C (liste + ajout via BottomSheet)
// ===============================
class SectionCForm extends StatefulWidget {
  const SectionCForm({super.key});
  @override
  State<SectionCForm> createState() => _SectionCFormState();
}

class _SectionCFormState extends State<SectionCForm>
    with AutomaticKeepAliveClientMixin {
  final _saveKey = GlobalKey<FormState>();
  final _storeFmt = DateFormat('yyyy-MM-dd');
  final _viewFmt = DateFormat('dd/MM/yyyy');

  final MyStepThreeController _stepCtrl = MyStepThreeController();
  bool _loading = true;

  // Liste des documents de la section
  late List<CDocItem> _docs;

  Color get _orange => const Color(0xFFFF6A00);

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _initLoad() async {
    await _stepCtrl.loadData(); // assure typesDocuments rempli
    final initial =
        context.read<InspectionWizardCtrl>().section('c') ?? <String, dynamic>{};
    final List parsed = (initial['documents'] as List?) ?? <Map<String, dynamic>>[];
    _docs = parsed.map((e) => CDocItem.fromMap(Map<String, dynamic>.from(e))).toList();
    if (mounted) setState(() => _loading = false);
  }

  String _labelForTypeDoc(String id) {
    final m = _stepCtrl.typesDocuments.where((e) => e.id.toString() == id).toList();
    return m.isEmpty ? id : (m.first.libelle ?? '').toString();
  }

  // Ouvre le BottomSheet pour créer/éditer un doc
  Future<void> _openDocSheet({CDocItem? initial, int? index}) async {
    final result = await showModalBottomSheet<CDocItem>(
      context: context,
      useRootNavigator: true, // IMPORTANT pour que pop(rootNavigator:true) referme bien
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return _DocSheet(
          typesDocuments: _stepCtrl.typesDocuments,
          initial: initial,
        );
      },
    );

    if (result != null) {
      setState(() {
        if (index != null) {
          _docs[index] = result;
        } else {
          _docs.add(result);
        }
      });
    }
  }

  Future<void> _saveAll() async {
    final payload = {
      'documents': _docs.map((e) => e.toMap()).toList(),
    };
    await context.read<InspectionWizardCtrl>().saveSection('c', payload);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green.shade600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: const [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Section C sauvegardée avec succès.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Form(
      key: _saveKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Documents du navire",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _orange),
          ),
          const SizedBox(height: 8),

          // Liste des documents ajoutés
          if (_docs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "Aucun document ajouté. Cliquez sur « Ajouter un document ». ",
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final d = _docs[i];
                return Material(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    leading: Checkbox(
                      value: d.verifie,
                      onChanged: (v) {
                        setState(() => _docs[i] = d.copyWith(verifie: v ?? false));
                      },
                    ),
                    title: Text(
                      "${d.typeDocumentLabel} • ${d.identifiant}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      [
                        "Délivré par: ${d.delivrePar}",
                        if (d.dateEmission != null)
                          "Émission: ${_viewFmt.format(DateTime.parse(d.dateEmission!))}",
                        if (d.dateExpiration != null)
                          "Expiration: ${_viewFmt.format(DateTime.parse(d.dateExpiration!))}",
                      ].join(" · "),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _openDocSheet(initial: d, index: i), // Éditer
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (d.attachments.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFF6A00)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.attachment, size: 16, color: Color(0xFFE25F00)),
                                const SizedBox(width: 4),
                                Text('${d.attachments.length}',
                                    style: const TextStyle(color: Color(0xFFE25F00))),
                              ],
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: "Supprimer",
                          onPressed: () => setState(() => _docs.removeAt(i)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 16),

          // Actions
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: () => _openDocSheet(),
                icon: const Icon(Icons.add),
                label: const Text("Ajouter un document"),
              ),
              FilledButton.icon(
                onPressed: _docs.isEmpty ? null : _saveAll,
                icon: const Icon(Icons.save),
                label: const Text("Enregistrer section"),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ===============================
// BottomSheet : formulaire d'un document
// ===============================
class _DocSheet extends StatefulWidget {
  const _DocSheet({
    required this.typesDocuments,
    this.initial,
  });

  final List<dynamic> typesDocuments; // items avec e.id, e.libelle
  final CDocItem? initial;

  @override
  State<_DocSheet> createState() => _DocSheetState();
}

class _DocSheetState extends State<_DocSheet> {
  final _formKey = GlobalKey<FormState>();

  final _storeFmt = DateFormat('yyyy-MM-dd');
  final _viewFmt = DateFormat('dd/MM/yyyy');

  // champs
  String? _typeId;
  String _typeLabel = '';
  final _identCtrl = TextEditingController();
  final _delivreCtrl = TextEditingController();
  final _emissCtrl = TextEditingController(); // view dd/MM/yyyy
  final _expirCtrl = TextEditingController(); // view dd/MM/yyyy
  bool _verifie = false;

  // Pièces jointes (0..3)
  final _picker = ImagePicker();
  List<String> _attachments = [];

  @override
  void initState() {
    super.initState();

    if (widget.initial != null) {
      final d = widget.initial!;
      _typeId = d.typeDocumentId;
      _typeLabel = d.typeDocumentLabel;
      _identCtrl.text = d.identifiant;
      _delivreCtrl.text = d.delivrePar;
      if (d.dateEmission != null) {
        _emissCtrl.text = _viewFmt.format(DateTime.parse(d.dateEmission!));
      }
      if (d.dateExpiration != null) {
        _expirCtrl.text = _viewFmt.format(DateTime.parse(d.dateExpiration!));
      }
      _verifie = d.verifie;

      _attachments = List<String>.from(d.attachments);
    } else {
      // défaut: premier type si dispo
      if (widget.typesDocuments.isNotEmpty) {
        final e = widget.typesDocuments.first;
        _typeId = e.id.toString();
        _typeLabel = (e.libelle ?? '').toString();
      }
    }
  }

  @override
  void dispose() {
    _identCtrl.dispose();
    _delivreCtrl.dispose();
    _emissCtrl.dispose();
    _expirCtrl.dispose();
    super.dispose();
  }

  // ---------- utils ----------
  bool _isImage(String path) {
    final ext = p.extension(path).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.heic', '.heif'].contains(ext);
  }

  Future<String> _persistToAppDir(String srcPath) async {
    final dir = await getApplicationDocumentsDirectory();
    final ext = p.extension(srcPath);
    final name = 'doc_${DateTime.now().millisecondsSinceEpoch}_${_attachments.length}$ext';
    final dest = p.join(dir.path, name);
    final out = await File(srcPath).copy(dest);
    return out.path;
  }

  // ---------- validation & dates ----------
  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Requis' : null;
  String? _optionalDate(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    try {
      _viewFmt.parseStrict(v.trim());
      return null;
    } catch (_) {
      return 'Date invalide (jj/mm/aaaa)';
    }
  }

  String? _datesCoherenceError() {
    DateTime? de;
    DateTime? dx;
    if (_emissCtrl.text.trim().isNotEmpty) {
      try { de = _viewFmt.parseStrict(_emissCtrl.text.trim()); } catch (_) {}
    }
    if (_expirCtrl.text.trim().isNotEmpty) {
      try { dx = _viewFmt.parseStrict(_expirCtrl.text.trim()); } catch (_) {}
    }
    if (de != null && dx != null && de.isAfter(dx)) {
      return "La date d’émission doit précéder la date d’expiration";
    }
    return null;
  }

  Future<void> _pickDate(TextEditingController target) async {
    final now = DateTime.now();
    DateTime initial = now;
    if (target.text.trim().isNotEmpty) {
      try {
        initial = _viewFmt.parseStrict(target.text.trim());
      } catch (_) {}
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 30),
    );
    if (picked != null) {
      target.text = _viewFmt.format(picked);
      setState(() {}); // pour recalculer la cohérence si besoin
    }
  }

  Future<void> _openTypePicker() async {
    final res = await showModalBottomSheet<_PickResult<String>>(
      context: context,
      useRootNavigator: true, // IMPORTANT
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _SimplePickerSheet<dynamic, String>(
        title: "Sélectionner un type de document",
        items: widget.typesDocuments,
        initialId: _typeId,
        idOf: (e) => e.id.toString(),
        labelOf: (e) => (e.libelle ?? '').toString(),
      ),
    );
    if (res != null) {
      setState(() {
        _typeId = res.id;
        _typeLabel = res.label;
      });
    }
  }

  // ---------- pièces jointes ----------
  Future<void> _pickFromCamera() async {
    if (_attachments.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 pièces jointes.')),
      );
      return;
    }
    final x = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (x != null) {
      final saved = await _persistToAppDir(x.path);
      setState(() => _attachments.add(saved));
    }
  }

  // Pas de galerie d'images : on sélectionne un **document** (pdf/doc/xls/images, etc.)
  Future<void> _pickDocumentFromDevice() async {
    if (_attachments.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 pièces jointes.')),
      );
      return;
    }
    final res = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: [
        'pdf', 'doc', 'docx', 'xls', 'xlsx',
        'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif'
      ],
    );
    if (res != null && res.files.single.path != null) {
      final saved = await _persistToAppDir(res.files.single.path!);
      setState(() => _attachments.add(saved));
    }
  }

  void _submit() {
    if (_typeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez choisir un type de document.")),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final err = _datesCoherenceError();
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    String? storedEmission;
    String? storedExpiration;
    if (_emissCtrl.text.trim().isNotEmpty) {
      storedEmission = _storeFmt.format(_viewFmt.parseStrict(_emissCtrl.text.trim()));
    }
    if (_expirCtrl.text.trim().isNotEmpty) {
      storedExpiration = _storeFmt.format(_viewFmt.parseStrict(_expirCtrl.text.trim()));
    }

    final item = CDocItem(
      typeDocumentId: _typeId!,
      typeDocumentLabel: _typeLabel,
      identifiant: _identCtrl.text.trim(),
      delivrePar: _delivreCtrl.text.trim(),
      dateEmission: storedEmission,
      dateExpiration: storedExpiration,
      verifie: _verifie,
      attachments: List<String>.from(_attachments),
    );

    // IMPORTANT: fermer correctement le bottom sheet même s'il a été ouvert avec useRootNavigator
    Navigator.of(context, rootNavigator: true).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final coherenceError = _datesCoherenceError();

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.25,
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        builder: (ctx, controller) {
          return SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.description_outlined),
                      SizedBox(width: 8),
                      Text("Ajouter / Éditer un document",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Type (BottomSheet)
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _openTypePicker,
                    child: InputDecorator(
                      isEmpty: _typeLabel.isEmpty,
                      decoration: InputDecoration(
                        labelText: "Type de document *",
                        suffixIcon: const Icon(Icons.search),
                        // Affiche une erreur visuelle si non choisi et qu'on a tenté de valider
                        errorText: (_typeId == null) ? null : null,
                      ),
                      child: Text(
                        _typeLabel.isEmpty ? 'Sélectionner…' : _typeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _typeLabel.isEmpty ? Theme.of(context).hintColor : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _identCtrl,
                          decoration: const InputDecoration(
                            labelText: "Identifiant *",
                            hintText: "N° XXXXXXXXXX",
                          ),
                          validator: _required,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _delivreCtrl,
                          decoration: const InputDecoration(
                            labelText: "Délivré par *",
                            hintText: "Délivré par XXXXXXX",
                          ),
                          validator: _required,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _emissCtrl,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Date d’émission (option)",
                            hintText: "jj/mm/aaaa",
                            suffixIcon: IconButton(
                              onPressed: () => _pickDate(_emissCtrl),
                              icon: const Icon(Icons.date_range),
                            ),
                          ),
                          validator: _optionalDate,
                          onTap: () => _pickDate(_emissCtrl),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _expirCtrl,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Date d’expiration (option)",
                            hintText: "jj/mm/aaaa",
                            suffixIcon: IconButton(
                              onPressed: () => _pickDate(_expirCtrl),
                              icon: const Icon(Icons.date_range),
                            ),
                          ),
                          validator: _optionalDate,
                          onTap: () => _pickDate(_expirCtrl),
                        ),
                      ),
                    ],
                  ),
                  if (coherenceError != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      coherenceError,
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // === Pièces jointes ===
                  Row(
                    children: [
                      const Icon(Icons.attachment),
                      const SizedBox(width: 8),
                      const Text('Pièces jointes', style: TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: _attachments.length >= 3 ? null : _pickFromCamera,
                        icon: const Icon(Icons.photo_camera),
                        label: const Text('Caméra'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _attachments.length >= 3 ? null : _pickDocumentFromDevice,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Joindre un fichier'),
                      ),
                      const SizedBox(width: 8),
                      Text("${_attachments.length}/3"),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (_attachments.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _attachments.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (_, i) {
                        final path = _attachments[i];
                        final f = File(path);
                        final isImg = _isImage(path);
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                color: Colors.grey.shade100,
                                child: isImg && f.existsSync()
                                    ? Image.file(f, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                                    : Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.insert_drive_file, size: 32),
                                        const SizedBox(height: 6),
                                        Text(
                                          p.basename(path),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4, right: 4,
                              child: InkWell(
                                onTap: () => setState(() => _attachments.removeAt(i)),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                  const SizedBox(height: 16),
                  Tooltip(
                    message: "Cochez uniquement après avoir vérifié physiquement l'authenticité du document (tampon, signature, date de validité, etc.)",
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    preferBelow: false,
                    waitDuration: const Duration(milliseconds: 500),
                    showDuration: const Duration(seconds: 4),
                    child: SwitchListTile(
                      value: _verifie,
                      onChanged: (v) => setState(() => _verifie = v),
                      title: Row(
                        children: [
                          const Text("Document authentifié ?"),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Colors.orange.shade700,
                          ),
                        ],
                      ),
                      subtitle: const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          "Maintenez appuyé sur l'icône ⓘ pour plus d'info",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context, rootNavigator: true).maybePop(),
                        icon: const Icon(Icons.close),
                        label: const Text("Fermer"),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text("Valider"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ===============================
// Sélecteur générique (reuse de ton pattern)
// ===============================
class _PickResult<T> {
  final T id;
  final String label;
  _PickResult({required this.id, required this.label});
}

class _SimplePickerSheet<E, T> extends StatefulWidget {
  const _SimplePickerSheet({
    required this.title,
    required this.items,
    required this.idOf,
    required this.labelOf,
    this.initialId,
  });

  final String title;
  final List<E> items;
  final T Function(E e) idOf;
  final String Function(E e) labelOf;
  final T? initialId;

  @override
  State<_SimplePickerSheet<E, T>> createState() => _SimplePickerSheetState<E, T>();
}

class _SimplePickerSheetState<E, T> extends State<_SimplePickerSheet<E, T>> {
  final TextEditingController _searchCtrl = TextEditingController();
  late List<E> _filtered;

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
          final label = widget.labelOf(e).toLowerCase();
          final idStr = widget.idOf(e).toString().toLowerCase();
          return label.contains(q) || idStr.contains(q);
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
    final initialIdStr = widget.initialId?.toString();

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        expand: false,
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
              Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchCtrl,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: "Rechercher…",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),

              ..._filtered.map((e) {
                final idStr = widget.idOf(e).toString();
                final label = widget.labelOf(e);
                final selected = initialIdStr == idStr;

                return ListTile(
                  title: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: selected ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop(
                      _PickResult<T>(id: widget.idOf(e), label: label),
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
