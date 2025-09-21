import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:test_app_divkit/me/services/database_service.dart';
import '../data/db.dart';
import 'package:sqflite/sqflite.dart';


Map<String, dynamic> _deepCopy(Map<String, dynamic> src) =>
    jsonDecode(jsonEncode(src)) as Map<String, dynamic>;

class InspectionWizardCtrl extends ChangeNotifier { 
  int? _inspectionId;
  Map<String, dynamic> _global = {"a": {}, "b": {}, "c": {}, "d": {},"e": {},"f": {}};
  final Map<String, int> _versions = {"a": 0, "b": 0, "c": 0, "d": 0,"e": 0,"f": 0};

  int? get inspectionId => _inspectionId;
  Map<String, dynamic> get globalJson => _deepCopy(_global);

  Future<void> loadOrCreate({int? id}) async {
    final db = await DatabaseHelper.database;
    if (id != null) {
      final rows = await db.query('inspections', where: 'id=?', whereArgs: [id], limit: 1);
      if (rows.isNotEmpty) {
        _inspectionId = rows.first['id'] as int;

        // 🔽 Correction ici
        final raw = jsonDecode(rows.first['json_field'] as String);
        final map = Map<String, dynamic>.from(raw);

        _global = {
          "a": Map<String, dynamic>.from(map["a"] ?? {}),
          "b": Map<String, dynamic>.from(map["b"] ?? {}),
          "c": Map<String, dynamic>.from(map["c"] ?? {}),
          "d": Map<String, dynamic>.from(map["d"] ?? {}),
          "e": Map<String, dynamic>.from(map["e"] ?? {}),
          "f": Map<String, dynamic>.from(map["e"] ?? {}),
        };

        for (final k in _versions.keys) {
          _versions[k] = (_global[k]?["sectionVersion"] ?? 0) as int;
        }

        //
        final dynamic myVa =  await  _global;
        print(myVa);

        notifyListeners();
        return;
      }
    }
    // Create new empty if id is null or not found
    final newId = await db.insert('inspections', {'json_field': jsonEncode({})});
    _inspectionId = newId;
    _global = {"a": {}, "b": {}, "c": {}, "d": {},"e": {},"f": {}};
    await db.update(
      'inspections',
      {'json_field': jsonEncode(_global)},
      where: 'id=?',
      whereArgs: [_inspectionId],
    );
    notifyListeners();
  }

  Future<void> updateInspectionStatus(int id, int newStatus) async {
    final db = await DatabaseHelper.database;
    await db.update(
      'inspections',
      {
        'statut_inspection_id': newStatus,
        'sync': 0, // 🔄 on force sync à 0 pour qu'il soit pris en compte dans la synchro a envoyer vers laravel
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }



  Map<dynamic, dynamic> section(String key) =>   /// ici j'ai changé en dynamic , j'esoère qu'il n'yaura pas de sucis
      _deepCopy(_global[key] ?? {});

  // Future<void> saveSection(String key, Map<String, dynamic> sectionData) async {
  //   if (_inspectionId == null) return;
  //   final db = await DatabaseHelper.database;
  //   // bump version + timestamp
  //   _versions[key] = (_versions[key] ?? 0) + 1;
  //   final copy = _deepCopy(sectionData);
  //   copy["sectionVersion"] = _versions[key];
  //   copy["sectionSavedAt"] = DateTime.now().toIso8601String();
  //
  //   // merge in-memory
  //   _global[key] = {...(_global[key] ?? {}), ...copy};
  //
  //   //
  //
  //
  //   // persist ONLY this id
  //   await db.transaction((txn) async {
  //     await txn.update(
  //       'inspections',
  //       {'json_field': jsonEncode(_global)},
  //       where: 'id=?',
  //       whereArgs: [_inspectionId],
  //       conflictAlgorithm: ConflictAlgorithm.replace,
  //     );
  //   });
  //
  //   notifyListeners();
  // }

  Future<void> _markDirtySyncOnly() async {
    if (_inspectionId == null) return;
    final db = await DatabaseHelper.database;
    await db.update(
      'inspections',
      {'sync': 0},
      where: 'id = ?',
      whereArgs: [_inspectionId],
    );
  }


  Future<void> saveSection(String key, Map<String, dynamic> sectionData) async {
    if (_inspectionId == null) return;
    final db = await DatabaseHelper.database;

    // bump version + timestamp
    _versions[key] = (_versions[key] ?? 0) + 1;
    final copy = _deepCopy(sectionData);
    copy["sectionVersion"] = _versions[key];
    copy["sectionSavedAt"] = DateTime.now().toIso8601String();

    // merge in-memory (shallow)
    _global[key] = {...(_global[key] ?? {}), ...copy};

    // persist + sync=0 dans la même transaction
    await db.transaction((txn) async {
      await txn.update(
        'inspections',
        {'json_field': jsonEncode(_global)},
        where: 'id=?',
        whereArgs: [_inspectionId],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 👉 ne touche PAS à statut_inspection_id, on remet SEULEMENT sync à 0
      await txn.update(
        'inspections',
        {'sync': 0},
        where: 'id=?',
        whereArgs: [_inspectionId],
      );
    });

    notifyListeners();
  }


}
