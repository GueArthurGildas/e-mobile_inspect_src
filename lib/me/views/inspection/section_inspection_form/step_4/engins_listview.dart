import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/models/etats_engins_model.dart';
import 'package:test_app_divkit/me/models/types_engins_model.dart';

class EngineItem {
  TypesEngins typesEngins;
  EtatsEngins etatsEngins;
  String? observation;

  String get key => "$typesEngins-$etatsEngins".hashCode.toString();

  EngineItem({
    required this.typesEngins,
    required this.etatsEngins,
    this.observation,
  });

  factory EngineItem.fromObject(Map<String, dynamic> obj) {
    return EngineItem(
      typesEngins: obj['typesEngin'] as TypesEngins,
      etatsEngins: obj['etatsEngin'] as EtatsEngins,
      observation: obj['observation'],
    );
  }
}

class EngineListView extends StatefulWidget {
  const EngineListView({super.key, this.engines = const []});

  final List<EngineItem> engines;

  @override
  State<EngineListView> createState() => _EngineListViewState();
}

class _EngineListViewState extends State<EngineListView> {
  Widget _buildEngineView(EngineItem engine) {
    return Dismissible(
      key: Key(engine.key),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        print(direction);
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.0),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        title: Row(
          spacing: 10.0,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              engine.typesEngins.libelle,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              engine.etatsEngins.libelle,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        subtitle: Text(
          engine.observation ?? "Aucune observation",
          style: TextStyle(fontSize: 12.0),
        ),
        trailing: Icon(Icons.remove, color: Colors.red),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: widget.engines.isNotEmpty
          ? ListView.builder(
              itemCount: widget.engines.length,
              itemBuilder: (context, index) {
                return _buildEngineView(widget.engines[index]);
              },
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'Appuyer sur le bouton "Ajouter un engin" pour en ajouter.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
    );
  }
}
