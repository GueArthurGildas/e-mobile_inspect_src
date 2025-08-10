import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/views/shared/app_bar.dart';
import 'package:test_app_divkit/me/views/shared/common.dart';

import '../../../shared/file_manager.dart';

class FormInspectionDocumentsScreen extends StatefulWidget {
  const FormInspectionDocumentsScreen({super.key});

  @override
  State<FormInspectionDocumentsScreen> createState() =>
      _FormInspectionDocumentsScreenState();
}

class _FormInspectionDocumentsScreenState
    extends State<FormInspectionDocumentsScreen> {
  Map<String, List<dynamic>>? _data;
  Map<String, dynamic> _formData = {};

  static const Color _orangeColor = Color(0xFFFF6A00);

  void _handleFilesForUpload(List<LocalFileItem> files) {
    setState(() {
      _formData['documents'] = files;
    });

    // print('Files selected: ${files.map((f) => f.name).toList()}');
    // ...
  }

  void _handleFilesForDelete(List<LocalFileItem> files) {
    setState(() {
      _formData['documents'] = files;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newRouteData =
        ModalRoute.of(context)?.settings.arguments
            as Map<String, List<dynamic>>?;

    if (newRouteData != _data) {
      _data = newRouteData;
      _formData = _data?['formData']?[0] ?? <String, dynamic>{};
    }
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
    bool isLoading =
        _data == null &&
        ModalRoute.of(context)?.settings.arguments != null;
    if (isLoading && _data == null) {
      _data =
          ModalRoute.of(context)?.settings.arguments
              as Map<String, List<dynamic>>?;
      if (_data != null) {
        _formData = _data?['formData']?[0] ?? <String, dynamic>{};
        isLoading = false;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Contrôle documentaire",
        backgroundColor: _orangeColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: _orangeColor))
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
                          style: TextStyle(fontSize: 16, color: Colors.white),
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
                                    savedFiles: _formData['documents'],
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 12.0,
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          elevation: 3.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
      ),
    );
  }
}
