import 'package:flutter/material.dart';
import 'package:e_Inspection_APP/me/models/etats_engins_model.dart';
import 'package:e_Inspection_APP/me/models/types_engins_model.dart';
import 'package:e_Inspection_APP/me/views/inspection/section_inspection_form/step_4/engine_bottomsheet.dart';
import 'package:e_Inspection_APP/me/views/inspection/section_inspection_form/step_4/engins_listview.dart'; // Ensure EngineItem is defined here or imported
import 'package:e_Inspection_APP/me/views/inspection/section_inspection_form/step_4/step_four_controller.dart';
import 'package:e_Inspection_APP/me/views/shared/app_bar.dart';
import 'package:e_Inspection_APP/me/views/shared/app_dropdown_search.dart';
import 'package:e_Inspection_APP/me/views/shared/common.dart';

class FormInfosEnginsScreen extends StatefulWidget {
  const FormInfosEnginsScreen({super.key});

  @override
  State<FormInfosEnginsScreen> createState() => _FormInfosEnginsScreenState();
}

class _FormInfosEnginsScreenState extends State<FormInfosEnginsScreen> {
  final StepFourController _controller = StepFourController();
  late dynamic _data;
  List<EngineItem> _installedEngines = [];

  bool _isLoading = false;
  static const Color _orangeColor = Color(0xFFFF6A00);

  @override
  void initState() {
    super.initState();

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadDataFromRoute();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _loadDataFromRoute() async {
    _data = ModalRoute.of(context)?.settings.arguments as dynamic ?? {};
    await _controller.loadData();

    final enginesData = _data['enginsInstalles'];
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
    _data['enginsInstalles'] = _installedEngines;

    _isLoading = false;
  }

  List<EtatsEngins> get _etatsEngins => _controller.etatsEngins;
  List<TypesEngins> get _typesEngins => _controller.typesEngins;

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
        _data['enginsInstalles'] = _installedEngines;
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
          onPressed: () => Navigator.pop(context, _data['enginsInstalles']),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Informations sur les engins",
        backgroundColor: _orangeColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: (_isLoading)
          ? const Center(child: CircularProgressIndicator(color: _orangeColor))
          : SafeArea(
              child: EngineListView(
                engines: _installedEngines,
                onDelete: (item) {
                  setState(() {
                    _installedEngines.remove(item);
                    _data['enginsInstalles'] = _installedEngines;
                  });
                },
              ),
            ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}
