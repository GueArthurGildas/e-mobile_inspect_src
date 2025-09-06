import 'package:sqflite/sqflite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/Inspection_api_sync.dart';

class SyncReport {
  final String? error;
  final int totalPending; // nb lignes locales sync=0
  final int totalSent;    // nb ids envoyés
  final int totalUpdated; // somme 'updated' renvoyée par l'API
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

  Future<SyncReport> run() async {
    // 0) réseau ?
    final net = await Connectivity().checkConnectivity();
    if (net == ConnectivityResult.none) {
      return const SyncReport(error: 'Pas de connexion Internet', totalPending: 0, totalSent: 0, totalUpdated: 0);
    }

    final db = await getDb();

    // 1) ids locaux à synchroniser (sync=0)
    final rows = await db.query('inspections', columns: ['id'], where: 'sync = 0');
    if (rows.isEmpty) {
      return const SyncReport(error: null, totalPending: 0, totalSent: 0, totalUpdated: 0);
    }

    final ids = <int>[];
    for (final r in rows) {
      final v = r['id'];
      if (v is int) ids.add(v);
      if (v is String) {
        final n = int.tryParse(v);
        if (n != null) ids.add(n);
      }
    }
    if (ids.isEmpty) {
      return SyncReport(error: 'Aucun id exploitable trouvé', totalPending: rows.length, totalSent: 0, totalUpdated: 0);
    }

    // 2) envoi par lots (PUT) + MAJ locale
    int sent = 0;
    int updatedSum = 0;

    for (var i = 0; i < ids.length; i += chunkSize) {
      final chunk = ids.sublist(i, (i + chunkSize > ids.length) ? ids.length : i + chunkSize);
      try {
        debugPrint('[Sync] PUT lot ${chunk.length} ids');
        final updated = await api.syncIds(chunk, timeout: apiTimeout);
        updatedSum += updated;
        sent += chunk.length;

        // aligner localement (même si updated=0 -> déjà sync côté serveur)
        final placeholders = List.filled(chunk.length, '?').join(',');
        await db.rawUpdate('UPDATE inspections SET sync = 1 WHERE id IN ($placeholders)', chunk);
      } catch (e) {
        return SyncReport(
          error: 'Erreur pendant la synchro: $e',
          totalPending: ids.length,
          totalSent: sent,
          totalUpdated: updatedSum,
        );
      }
    }

    return SyncReport(error: null, totalPending: ids.length, totalSent: sent, totalUpdated: updatedSum);
  }
}
