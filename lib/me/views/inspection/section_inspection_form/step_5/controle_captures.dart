import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/services/database_service.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/step_5/step_five_controller.dart';
import 'package:test_app_divkit/me/views/shared/app_bar.dart';
import 'package:test_app_divkit/me/views/shared/app_dropdown_search.dart';
import 'package:test_app_divkit/me/views/shared/app_fab_speed_dial.dart';
import 'package:test_app_divkit/me/views/shared/app_form.dart';
import 'package:test_app_divkit/me/views/shared/common.dart';
import 'package:test_app_divkit/me/views/shared/form_control.dart';

import 'informations_captures_screen.dart';

class FormControleCapturesScreen extends StatefulWidget {
  const FormControleCapturesScreen({super.key});

  @override
  State<FormControleCapturesScreen> createState() =>
      _FormControleCapturesScreenState();
}

class _FormControleCapturesScreenState
    extends State<FormControleCapturesScreen> {
  final StepFiveController _controller = StepFiveController();
  late Map<String, dynamic> _data;

  bool _isLoading = false;
  static const Color _orangeColor = Color(0xFFFF6A00);
  final List<Map<String, dynamic>> _tabData = [
    {'label': "Captures débarquées", 'key': "capturesDebarquees"},
    {'label': "Captures restées à bord du navire", 'key': "capturesABord"},
    {'label': "Captures interdites", 'key': "capturesInterdites"},
  ];

  @override
  void initState() {
    super.initState();

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _data =
            ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>? ??
            {};
        await _controller.loadData();
      });
    }

    _isLoading = false;
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

  Widget _buildDataView(String key) {
    final List<dynamic> data = _data[key] ?? [];

    return data.isEmpty
        ? Center(child: Text('Aucune donnée..'))
        : ListView(
            padding: const EdgeInsets.all(16.0),
            children: data.map((item) {
              int index = data.indexOf(item);

              return Dismissible(
                key: Key(index.toString()),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) => setState(() {
                  data.removeAt(index);
                  _data[key] = data;
                }),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20.0),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  title: Text(
                    (item['especes'] as DropdownItem).label,
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    "${(item['presentation'] as DropdownItem).label} (${(item['conservation'] as DropdownItem).label})",
                  ),
                  trailing: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "${item['quantiteDeclaree'] ?? item['quantiteObservee']} KG",
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool _, result) => result = _data,
      child: Scaffold(
        appBar: CustomAppBar(title: "Contrôle des captures sur le navire"),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: _orangeColor),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Contrôle des espèces trouvées sur le navire",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                          color: _orangeColor,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      const Text(
                        "Points clés à vérifier :",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      _buildChecklistItem("Espèces présentes sur le naivre."),
                      _buildChecklistItem("Zone de pêche."),
                      _buildChecklistItem(
                        "Conservation et présentation des espèces.",
                      ),
                      const SizedBox(height: 24.0),
                      const Card(
                        elevation: 2.0,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Veuillez cliquer sur les boutons ci-dessous pour sélectionner la présence d'une espèce et ajouter les détails correspondants.\n\n(?) Pour supprimer un element de la liste, glissez-le vers la gauche.",
                            style: TextStyle(
                              // fontSize: 15.0,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.06,
                      ),
                      Center(
                        child: OutlinedButton(
                          onPressed: () => Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  InformationsCapturesScreen(
                                    tabBars: _tabData
                                        .map((t) => Tab(text: t['label']))
                                        .toList(),
                                    tabBarViews: _tabData
                                        .map((t) => _buildDataView(t['key']))
                                        .toList(),
                                  ),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    var tween = Tween(
                                      begin: const Offset(1.0, 0.0),
                                      end: Offset.zero,
                                    ).chain(CurveTween(curve: Curves.ease));
                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: child,
                                    );
                                  },
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.015,
                            ),
                            child: Text(
                              "Voir les enregistrements",
                              style: TextStyle(
                                color: _orangeColor,
                                fontSize: 13.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        floatingActionButton: AppFABSpeedDial(
          menuButtonColor: _orangeColor,
          fabActions: [
            FABAction(
              icon: Icons.add_outlined,
              label: "Captures débarquées",
              foreground: Colors.grey[800]!,
              onPressed: () async {
                dynamic result = await _toggleBottomSheet(
                  context,
                  "capturesDebarquees",
                  "Captures débarquées",
                );

                if (result != null) {
                  setState(() {
                    if ((_data as Map).containsKey("capturesDebarquees")) {
                      (_data["capturesDebarquees"] as List<dynamic>).add(
                        result,
                      );
                    } else {
                      (_data as Map)["capturesDebarquees"] = [result];
                    }
                  });
                }
              },
            ),
            FABAction(
              icon: Icons.add_outlined,
              label: "Captures restées à bord du navire",
              foreground: Colors.grey[800]!,
              onPressed: () async {
                dynamic result = await _toggleBottomSheet(
                  context,
                  "capturesABord",
                  "Captures restées à bord du navire",
                );

                if (result != null) {
                  setState(() {
                    if ((_data as Map).containsKey("capturesABord")) {
                      ((_data as Map)["capturesABord"] as List).addAll(result);
                    } else {
                      (_data as Map)["capturesABord"] = [result];
                    }
                  });
                }
              },
            ),
            FABAction(
              icon: Icons.add_outlined,
              label: "Spécimens protégés, vénéneux ou interdits",
              foreground: Colors.grey[800]!,
              onPressed: () async {
                dynamic result = await _toggleCaptureInterditesBottomSheet(
                  context,
                  "capturesInterdites",
                );

                if (result != null) {
                  setState(() {
                    if ((_data as Map).containsKey("capturesInterdites")) {
                      ((_data as Map)["capturesInterdites"] as List).addAll(
                        result,
                      );
                    } else {
                      (_data as Map)["capturesInterdites"] = [result];
                    }
                  });
                }
              },
            ),
            FABAction(
              icon: Icons.save,
              label: "Enregistrer les modifications",
              onPressed: () => Navigator.pop(context, _data),
              fabBackground: _orangeColor,
              foreground: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _toggleCaptureInterditesBottomSheet(
    BuildContext context,
    String key,
  ) async {
    final formKey = GlobalKey<FormState>();
    final List<FormControl> controls = [
      FormControl(
        type: ControlType.label,
        name: "",
        label: "Captures interdites",
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17.0),
      ),
      FormControl(
        type: ControlType.dropdownSearch,
        name: "especes",
        label: "Especes",
        required: true,
        searchDropdownItems: [],
        asyncSearch: true,
        asyncSearchQuery: SearchQuery(table: DBTables.especes, column: 'name'),
      ),
      FormControl(
        type: ControlType.dropdownSearch,
        name: "zonesCapture",
        label: "Zones de captures",
        required: true,
        searchDropdownItems: [],
        asyncSearch: true,
        asyncSearchQuery: SearchQuery(
          table: DBTables.zones_capture,
          column: 'libelle',
        ),
      ),
      FormControl(
        type: ControlType.dropdownSearch,
        name: "presentation",
        label: "Présentation du produit",
        required: true,
        searchDropdownItems: _controller.presentationsList
            .map((p) => DropdownItem(value: p, id: p.id, label: p.libelle))
            .toList(),
      ),
      FormControl(
        type: ControlType.dropdownSearch,
        name: "conservation",
        label: "Conservation du produit",
        required: true,
        searchDropdownItems: _controller.conservationsList
            .map((c) => DropdownItem(value: c, id: c.id, label: c.libelle))
            .toList(),
      ),
      FormControl(
        type: ControlType.text,
        name: "quantiteObservee",
        label: "Quantité observée",
        suffixText: "Kg",
        keyboardType: TextInputType.number,
        required: true,
      ),
    ];

    dynamic result = await Common.showBottomSheet(
      context,
      SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: AppForm(controls: controls, formKey: formKey),
        ),
      ),
    );

    return result;
  }

  Future<dynamic> _toggleBottomSheet(
    BuildContext context,
    String key,
    String label,
  ) async {
    final formKey = GlobalKey<FormState>();
    final List<FormControl> controls = [
      FormControl(
        type: ControlType.label,
        name: "",
        label: label,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17.0),
      ),
      FormControl(
        type: ControlType.dropdownSearch,
        name: "especes",
        label: "Especes",
        required: true,
        searchDropdownItems: [],
        asyncSearch: true,
        asyncSearchQuery: SearchQuery(table: DBTables.especes, column: 'name'),
      ),
      FormControl(
        type: ControlType.dropdownSearch,
        name: "zonesCapture",
        label: "Zones de captures",
        required: true,
        searchDropdownItems: [],
        asyncSearch: true,
        asyncSearchQuery: SearchQuery(
          table: DBTables.zones_capture,
          column: 'libelle',
        ),
      ),
      FormControl(
        type: ControlType.dropdownSearch,
        name: "presentation",
        label: "Présentation du produit",
        required: true,
        searchDropdownItems: _controller.presentationsList
            .map((p) => DropdownItem(value: p, id: p.id, label: p.libelle))
            .toList(),
      ),
      FormControl(
        type: ControlType.dropdownSearch,
        name: "conservation",
        label: "Conservation du produit",
        required: true,
        searchDropdownItems: _controller.conservationsList
            .map((c) => DropdownItem(value: c, id: c.id, label: c.libelle))
            .toList(),
      ),
      FormControl(
        type: ControlType.text,
        name: "quantiteDeclaree",
        label: "Quantité déclarée",
        suffixText: "Kg",
        keyboardType: TextInputType.number,
        required: true,
      ),
      FormControl(
        type: ControlType.text,
        name: "quantiteRetenue",
        label: "Quantité retenue à bord",
        suffixText: "Kg",
        keyboardType: TextInputType.number,
        required: true,
      ),
    ];

    dynamic result = await Common.showBottomSheet(
      context,
      SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: AppForm(controls: controls, formKey: formKey),
        ),
      ),
    );

    return result;
  }
}
