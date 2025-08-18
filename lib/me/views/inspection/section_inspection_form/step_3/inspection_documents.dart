import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/models/types_documents_model.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/step_3/step_three_controller.dart';
import 'package:test_app_divkit/me/views/shared/app_bar.dart';
import 'package:test_app_divkit/me/views/shared/app_dropdown_search.dart';
import 'package:test_app_divkit/me/views/shared/app_form.dart';
import 'package:test_app_divkit/me/views/shared/common.dart';
import 'package:test_app_divkit/me/views/shared/file_manager.dart';
import 'package:test_app_divkit/me/views/shared/form_control.dart';

class FormInspectionDocumentsScreen extends StatefulWidget {
  const FormInspectionDocumentsScreen({super.key});

  @override
  State<FormInspectionDocumentsScreen> createState() =>
      _FormInspectionDocumentsScreenState();
}

class _FormInspectionDocumentsScreenState
    extends State<FormInspectionDocumentsScreen> {
  late Map<String, dynamic> _data;
  final StepThreeController _controller = StepThreeController();

  bool _isLoading = true;

  static const Color _orangeColor = Color(0xFFFF6A00);

  void _handleFilesForUpload(List<LocalFileItem> files) {
    setState(() {
      _data['documents'] = files;
    });
  }

  Future<dynamic> _handlePickFile(BuildContext context) async {
    final dynamic typeDoc = await Common.showBottomSheet(
      context,
      SelectDocType(items: _controller.typesDocuments),
    );

    return typeDoc;
  }

  void _handleFilesForDelete(List<LocalFileItem> files) {
    setState(() {
      _data['documents'] = files;
    });
  }

  @override
  void initState() {
    super.initState();

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _data = ModalRoute.of(context)?.settings.arguments as dynamic ?? {};
        await _controller.loadData();
      });
    }

    setState(() => _isLoading = false);
  }

  Widget _buildChecklistItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 5.0,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: _orangeColor,
            size: 15.0,
          ),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Contrôle documentaire",
        backgroundColor: _orangeColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: _orangeColor),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Documents de l'inspection",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: _orangeColor,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      "Points clés à vérifier pour chaque document :",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    _buildChecklistItem("Période de validité du document."),
                    _buildChecklistItem("Emetteur du document."),
                    _buildChecklistItem("Identifiant du document."),
                    const SizedBox(height: 24.0),
                    const Card(
                      elevation: 2.0,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Veuillez cliquer sur le bouton ci-dessous pour sélectionner les documents présents et ajouter les détails correspondants.",
                          style: TextStyle(
                            // fontSize: 15.0,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50.0),
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.folder_open_outlined,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Gérer les documents',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Common.showBottomSheet(
                            context,
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.70,
                              child: SafeArea(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20.0),
                                  ),
                                  child: FileManagerScreen(
                                    savedFiles: _data['documents'],
                                    onPickFile: (files) =>
                                        _handlePickFile(context),
                                    onUploadSelected: _handleFilesForUpload,
                                    onDelete: _handleFilesForDelete,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _orangeColor,
                          elevation: 3.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () => Navigator.pop(context, _data),
        style: ElevatedButton.styleFrom(backgroundColor: _orangeColor),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Text(
            "Enregistrer les modifications",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class SelectDocType extends StatefulWidget {
  const SelectDocType({super.key, required this.items});

  final List<TypesDocuments> items;

  @override
  State<SelectDocType> createState() => _SelectDocTypeState();
}

class _SelectDocTypeState extends State<SelectDocType> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: AppForm(
          controls: [
            FormControl(
              type: ControlType.label,
              name: "",
              label: "Choix du type de document",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17.0),
            ),
            FormControl(
              name: "typeDocument",
              label: "Type de documents",
              type: ControlType.dropdownSearch,
              searchDropdownItems: widget.items
                  .map(
                    (t) => DropdownItem(id: t.id, value: t, label: t.libelle),
                  )
                  .toList(),
              required: true,
            ),
          ],
          formKey: _formKey,
        ),
      ),
    );
  }
}
