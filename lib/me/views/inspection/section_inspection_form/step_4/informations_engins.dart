import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/models/etats_engins_model.dart';
import 'package:test_app_divkit/me/models/types_engins_model.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/step_4/engine_bottomsheet.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/step_4/engins_listview.dart'; // Ensure EngineItem is defined here or imported
import 'package:test_app_divkit/me/views/shared/app_bar.dart';
import 'package:test_app_divkit/me/views/shared/app_dropdown_search.dart';
import 'package:test_app_divkit/me/views/shared/common.dart';

class FormInfosEnginsScreen extends StatefulWidget {
  const FormInfosEnginsScreen({super.key});

  @override
  State<FormInfosEnginsScreen> createState() => _FormInfosEnginsScreenState();
}

class _FormInfosEnginsScreenState extends State<FormInfosEnginsScreen> {
  Map<String, List<dynamic>>? _routeData;
  Map<String, dynamic> _formData = {};
  List<EngineItem> _installedEngines = [];

  bool _isLoading = false;

  static const Color _orangeColor = Color(0xFFFF6A00);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDataFromRoute();
  }

  void _loadDataFromRoute() {
    final data =
        ModalRoute.of(context)?.settings.arguments
            as Map<String, List<dynamic>>?;

    if (data != null && data != _routeData) {
      _isLoading = true;

      setState(() {
        _routeData = data;
        _formData = Map<String, dynamic>.from(
          _routeData?['formData']?[0] ?? <String, dynamic>{},
        ); // Make a mutable copy

        // Initialize _installedEngines from _formData
        final enginesData = _formData['enginsInstalles'];
        if (enginesData is List) {
          _installedEngines = enginesData
              .map((item) {
                if (item is EngineItem) return item;
                if (item is Map<String, dynamic>) {
                  return EngineItem.fromObject(item);
                }
                return null;
              })
              .whereType<EngineItem>()
              .toList();
        } else {
          _installedEngines = [];
        }
        _formData['enginsInstalles'] = _installedEngines;
        _isLoading = false;
      });
    } else if (data == null &&
        ModalRoute.of(context)?.settings.arguments == null) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<EtatsEngins> get _etatsEngins {
    final data = _routeData?['etatsEngins'];
    if (data is List<EtatsEngins>) {
      return data.isNotEmpty ? data : _defaultEtatsEngins;
    }
    return _defaultEtatsEngins;

    // return data;
  }

  List<TypesEngins> get _typesEngins {
    final data = _routeData?['typesEngins'];
    if (data is List<TypesEngins>) {
      return data.isNotEmpty ? data : _defaultTypesEngins;
    }
    return _defaultTypesEngins;

    // return data;
  }

  // Placeholder default data
  static final List<EtatsEngins> _defaultEtatsEngins = List.generate(
    5,
    (index) => EtatsEngins(
      id: index,
      libelle: "État par défaut ${index + 1}",
      created_at: null,
      updated_at: null,
    ),
  );
  static final List<TypesEngins> _defaultTypesEngins = List.generate(
    5,
    (index) => TypesEngins(
      id: index,
      libelle: "Type par défaut ${index + 1}",
      created_at: null,
      updated_at: null,
    ),
  );

  Future<void> _showAddEngineBottomSheet() async {
    final Map<String, dynamic>? result = await Common.showBottomSheet(
      context,
      EngineBottomSheet(
        engineEtats: _etatsEngins
            .where(
              (e) => _installedEngines
                  .where((i) => (i).etatsEngins.id == e.id)
                  .isEmpty,
            )
            .toList(),
        engineTypes: _typesEngins
            .where(
              (t) => _installedEngines
                  .where((i) => (i).typesEngins.id == t.id)
                  .isEmpty,
            )
            .toList(),
      ),
    );

    if (result != null) {
      final newEngine = EngineItem.fromObject({
        'observation': result['observation'],
        'typesEngin': (result['typesEngin'] as DropdownItem).value,
        'etatsEngin': (result['etatsEngin'] as DropdownItem).value,
      });

      setState(() {
        _installedEngines.add(newEngine);
        _formData['enginsInstalles'] = _installedEngines;
      });

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('Engin ajouté.')
      //   ),
      // );
    }
  }

  Widget _buildFloatingActionButton() {
    return Column(
      spacing: 10.0,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          heroTag: 'fab1',
          onPressed: _showAddEngineBottomSheet,
          label: const Text("Ajouter un engin"),
          icon: const Icon(Icons.add),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        FloatingActionButton.extended(
          heroTag: 'fab2',
          onPressed: () => Navigator.pop(context, _formData['enginsInstalles']),
          label: const Text("Enregistrer les modifications"),
          icon: const Icon(Icons.save),
          backgroundColor: _orangeColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    print(_formData['enginsInstalles'].isEmpty ? _formData : _formData['enginsInstalles'][0].observation);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Informations sur les engins",
        backgroundColor: _orangeColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: (_isLoading)
          ? const Center(child: CircularProgressIndicator(color: _orangeColor))
          : SafeArea(child: EngineListView(engines: _installedEngines)),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}
