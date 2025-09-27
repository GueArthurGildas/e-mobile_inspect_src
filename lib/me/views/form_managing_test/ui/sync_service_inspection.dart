// sync_service.dart
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:e_Inspection_APP/me/views/form_managing_test/ui/Inspection_api_sync.dart';


class SyncReport {
  final String? error;
  final int totalPending;
  final int totalSent;     // nb d’items envoyés
  final int totalUpdated;  // somme 'updated' de l’API
  const SyncReport({this.error, required this.totalPending, required this.totalSent, required this.totalUpdated});
}

class SyncService {
  final Future<Database> Function() getDb;
  final InspectionApi api;
  final int chunkSize;
  final Duration apiTimeout;

  SyncService({
    required this.getDb,
    required this.api,
    this.chunkSize = 200,
    this.apiTimeout = const Duration(seconds: 20),
  });

  // Helper: construit un json_field “safe” si null/vidé
  Map<String, dynamic> _normalizeJsonField(dynamic raw) {
    try {
      final Map<String, dynamic> empty =
      {"a":{}, "b":{}, "c":{}, "d":{}, "e":{}, "f":{}};

      if (raw == null) return empty;
      if (raw is Map<String, dynamic>) {
        return {...empty, ...raw}; // merge, garantit les clés a..f
      }
      if (raw is String && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return {...empty, ...decoded};
        }
      }
      return empty;
    } catch (_) {
      // en cas de JSON corrompu → renvoie structure vide
      return {"a":{}, "b":{}, "c":{}, "d":{}, "e":{}, "f":{}};
    }
  }

  Future<SyncReport> run() async {
    // 0) réseau
    final net = await Connectivity().checkConnectivity();
    if (net == ConnectivityResult.none) {
      return const SyncReport(error: 'Pas de connexion Internet', totalPending: 0, totalSent: 0, totalUpdated: 0);
    }

    final db = await getDb();

    // 1) récupérer id + json_field où sync=0
    final rows = await db.query(
      'inspections',
      columns: ['id', 'json_field',"statut_inspection_id"],
      where: 'sync = 0',
    );

    if (rows.isEmpty) {
      return const SyncReport(error: null, totalPending: 0, totalSent: 0, totalUpdated: 0);
    }

    // 2) transformer en items {id, json_field:{a..f}}
    final items = <Map<String, dynamic>>[];
    for (final r in rows) {
      final idVal = r['id'];
      int? id;
      if (idVal is int) id = idVal;
      if (idVal is String) id = int.tryParse(idVal);

      if (id == null) continue;

      final jf = _normalizeJsonField(r['json_field']);
      final statut_id = r['statut_inspection_id'];
      items.add({
        'id': id,
        'json_field': jf,
        'statut_inspection_id' : statut_id,
      });
    }

    if (items.isEmpty) {
      return SyncReport(error: 'Aucun enregistrement exploitable', totalPending: rows.length, totalSent: 0, totalUpdated: 0);
    }

    // 3) envoi par lots + MAJ locale
    int sent = 0;
    int updatedSum = 0;

    for (var i = 0; i < items.length; i += chunkSize) {
      final chunk = items.sublist(i, (i + chunkSize > items.length) ? items.length : i + chunkSize);
      try {
        debugPrint('[Sync] PUT lot ${chunk.length} items');
        final updated = await api.syncPayloads(chunk, timeout: apiTimeout);
        updatedSum += updated;
        sent += chunk.length;

        // MAJ locale: passer sync=1 pour les id envoyés
        final ids = chunk.map((e) => e['id'] as int).toList();
        final placeholders = List.filled(ids.length, '?').join(',');
        await db.rawUpdate('UPDATE inspections SET sync = 1 WHERE id IN ($placeholders)', ids);

      } catch (e) {
        return SyncReport(
          error: 'Erreur pendant la synchro: $e',
          totalPending: items.length,
          totalSent: sent,
          totalUpdated: updatedSum,
        );
      }
    }

    return SyncReport(error: null, totalPending: items.length, totalSent: sent, totalUpdated: updatedSum);
  }
}
