// lib/services/inspection_sync_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:e_Inspection_APP/me/services/database_service.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Configuration Dio globale
final _dio = Dio(BaseOptions(
  baseUrl: 'https://www.mirah-csp.com/api/v1/',
  headers: {
    'Accept': 'application/json',
    'User-Agent': 'PostmanRuntime/7.48.0',
    'Accept-Encoding': 'gzip, deflate, br',
    'Connection': 'keep-alive',
  },
  connectTimeout: const Duration(seconds: 30),
  receiveTimeout: const Duration(seconds: 120),
  sendTimeout: const Duration(seconds: 120),
))..interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
  requestHeader: true,
  responseHeader: true,
  error: true,
  logPrint: (obj) {
    developer.log(obj.toString(), name: 'DIO_SYNC');
    if (kDebugMode) print('🌐 DIO: $obj');
  },
));

void _logDebug(String message, {String? tag, Object? error}) {
  final logTag = tag ?? 'INSPECTION_SYNC';
  developer.log(message, name: logTag, error: error);
  if (kDebugMode) print('📋 [$logTag] $message${error != null ? ' ERROR: $error' : ''}');
}

/// Résultat de synchronisation pour une inspection
class InspectionSyncResult {
  final int inspectionId;
  final bool success;
  final String message;
  final int documentCount;
  final Map<String, dynamic>? serverResponse;

  InspectionSyncResult({
    required this.inspectionId,
    required this.success,
    required this.message,
    this.documentCount = 0,
    this.serverResponse,
  });
}

/// Service de synchronisation des inspections
class InspectionSyncService {
  /// Récupère les inspections à synchroniser selon les critères
  /// - sync = true (ou 1)
  /// - statut_inspection_id = 2
  static Future<List<int>> getInspectionsToSync(Database db) async {
    _logDebug('🔍 Recherche des inspections à synchroniser...');

    try {
      final rows = await db.query(
        'inspections',
        columns: ['id'],
        where: 'sync = ? AND statut_inspection_id = ?',
        whereArgs: [0, 2], // sync = 0 (true) et statut = 2
      );

      final ids = rows.map((row) => row['id'] as int).toList();
      _logDebug('✅ ${ids.length} inspections trouvées à synchroniser: $ids');

      return ids;
    } catch (e) {
      _logDebug('❌ Erreur recherche inspections', error: e);
      return [];
    }
  }

  /// Récupère les documents d'une inspection spécifique
  static Future<List<Map<String, dynamic>>> _fetchDocumentsForInspection(
      Database db,
      int inspectionId,
      ) async {
    _logDebug('📥 Récupération documents pour inspection $inspectionId...');

    try {
      final rows = await db.query(
        'inspections',
        columns: ['id', 'json_field'],
        where: 'id = ?',
        whereArgs: [inspectionId],
        limit: 1,
      );

      if (rows.isEmpty) {
        _logDebug('⚠️ Inspection $inspectionId non trouvée');
        return [];
      }

      final raw = rows.first['json_field'] as String?;
      if (raw == null || raw.trim().isEmpty) {
        _logDebug('⚠️ json_field vide pour inspection $inspectionId');
        return [];
      }

      Map<String, dynamic> jf;
      try {
        jf = json.decode(raw) as Map<String, dynamic>;
      } catch (e) {
        _logDebug('❌ Erreur décodage JSON inspection $inspectionId', error: e);
        return [];
      }

      final c = (jf['c'] ?? {}) as Map<String, dynamic>;
      final docs = (c['documents'] ?? []) as List;
      final validDocs = docs.whereType<Map<String, dynamic>>().toList();

      _logDebug('📋 ${validDocs.length} documents valides pour inspection $inspectionId');

      return validDocs;
    } catch (e) {
      _logDebug('❌ Erreur récupération documents inspection $inspectionId', error: e);
      return [];
    }
  }

  /// Upload les documents d'une inspection vers le serveur
  static Future<InspectionSyncResult> _uploadDocuments(
      int inspectionId,
      List<Map<String, dynamic>> documents,
      void Function(int, int)? onProgress,
      ) async {
    _logDebug('🚀 Upload ${documents.length} documents pour inspection $inspectionId');

    if (documents.isEmpty) {
      return InspectionSyncResult(
        inspectionId: inspectionId,
        success: false,
        message: 'Aucun document à envoyer',
      );
    }

    final form = FormData()
      ..fields.add(MapEntry('inspection_id', inspectionId.toString()));

    // Construire le FormData
    for (int i = 0; i < documents.length; i++) {
      final doc = documents[i];

      void addField(String key, dynamic value) {
        if (value == null) return;
        final strValue = value.toString().trim();
        if (strValue.isEmpty) return;
        form.fields.add(MapEntry('documents[$i][$key]', strValue));
      }

      addField('typeDocumentId', doc['typeDocumentId']);
      addField('typeDocumentLabel', doc['typeDocumentLabel']);
      addField('identifiant', doc['identifiant']);
      addField('delivrePar', doc['delivrePar']);
      addField('dateEmission', doc['dateEmission']);
      addField('dateExpiration', doc['dateExpiration']);

      final verifie = doc['verifie'];
      final verifieValue = (verifie == true || verifie == 1 || verifie == '1' || verifie == 'true') ? '1' : '0';
      form.fields.add(MapEntry('documents[$i][verifie]', verifieValue));

      // Traiter les fichiers
      final attachments = (doc['attachments'] ?? []) as List;
      for (int j = 0; j < attachments.length; j++) {
        final path = attachments[j]?.toString() ?? '';
        if (path.isEmpty) continue;

        final f = File(path);
        if (await f.exists()) {
          try {
            form.files.add(MapEntry(
              'documents[$i][attachments][$j]',
              await MultipartFile.fromFile(path, filename: p.basename(path)),
            ));
          } catch (e) {
            _logDebug('⚠️ Erreur ajout fichier $path', error: e);
            form.fields.add(MapEntry('documents[$i][missing][$j]', path));
          }
        } else {
          form.fields.add(MapEntry('documents[$i][missing][$j]', path));
        }
      }
    }

    try {
      final response = await _dio.post(
        '/inspections/$inspectionId/documents',
        data: form,
        onSendProgress: (sent, total) {
          onProgress?.call(sent, total);
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'PostmanRuntime/7.48.0',
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
          },
          validateStatus: (status) => true,
          followRedirects: true,
          maxRedirects: 5,
        ),
      );

      final isSuccess = (response.statusCode == 200 || response.statusCode == 201);
      final hasOkFlag = response.data is Map && (response.data as Map)['ok'] == true;

      if (isSuccess && hasOkFlag) {
        return InspectionSyncResult(
          inspectionId: inspectionId,
          success: true,
          message: 'Documents synchronisés avec succès',
          documentCount: documents.length,
          serverResponse: response.data as Map<String, dynamic>?,
        );
      } else {
        return InspectionSyncResult(
          inspectionId: inspectionId,
          success: false,
          message: 'Échec de la synchronisation (Status: ${response.statusCode})',
          documentCount: documents.length,
          serverResponse: response.data as Map<String, dynamic>?,
        );
      }
    } catch (e) {
      _logDebug('❌ Erreur upload inspection $inspectionId', error: e);
      return InspectionSyncResult(
        inspectionId: inspectionId,
        success: false,
        message: 'Erreur: ${e.toString()}',
        documentCount: documents.length,
      );
    }
  }

  /// Marque une inspection comme synchronisée dans la BD
  static Future<void> _markAsSynced(Database db, int inspectionId) async {
    try {
      await db.update(
        'inspections',
        {'sync': 0}, // Mettre sync à 0 (false) car déjà synchronisé
        where: 'id = ?',
        whereArgs: [inspectionId],
      );
      _logDebug('✅ Inspection $inspectionId marquée comme synchronisée');
    } catch (e) {
      _logDebug('⚠️ Erreur marquage sync inspection $inspectionId', error: e);
    }
  }

  /// Synchronise une inspection spécifique
  static Future<InspectionSyncResult> syncInspection(
      int inspectionId, {
        void Function(int, int)? onProgress,
      }) async {
    _logDebug('🔄 === SYNC INSPECTION $inspectionId ===');

    final db = await DatabaseHelper.database;
    final docs = await _fetchDocumentsForInspection(db, inspectionId);

    if (docs.isEmpty) {
      return InspectionSyncResult(
        inspectionId: inspectionId,
        success: false,
        message: 'Aucun document trouvé',
      );
    }

    final result = await _uploadDocuments(inspectionId, docs, onProgress);

    // Si succès, marquer comme synchronisé
    if (result.success) {
      await _markAsSynced(db, inspectionId);
    }

    return result;
  }

  /// Synchronise toutes les inspections qui remplissent les critères
  /// sync = 1 ET statut_inspection_id = 2
  static Future<List<InspectionSyncResult>> syncAllPendingInspections({
    void Function(int current, int total)? onInspectionProgress,
    void Function(int sent, int total)? onUploadProgress,
  }) async {
    _logDebug('🚀 === SYNC TOUTES LES INSPECTIONS ===');

    final db = await DatabaseHelper.database;
    final inspectionIds = await getInspectionsToSync(db);

    if (inspectionIds.isEmpty) {
      _logDebug('ℹ️ Aucune inspection à synchroniser');
      return [];
    }

    final results = <InspectionSyncResult>[];

    for (int i = 0; i < inspectionIds.length; i++) {
      final inspectionId = inspectionIds[i];
      onInspectionProgress?.call(i + 1, inspectionIds.length);

      _logDebug('📤 Synchronisation ${i + 1}/${inspectionIds.length}: inspection $inspectionId');

      final result = await syncInspection(
        inspectionId,
        onProgress: onUploadProgress,
      );

      results.add(result);

      _logDebug(result.success
          ? '✅ Inspection $inspectionId: ${result.message}'
          : '❌ Inspection $inspectionId: ${result.message}');
    }

    final successCount = results.where((r) => r.success).length;
    _logDebug('🏁 Synchronisation terminée: $successCount/${inspectionIds.length} réussies');

    return results;
  }

  /// Synchronise une liste spécifique d'IDs d'inspections
  static Future<List<InspectionSyncResult>> syncSpecificInspections(
      List<int> inspectionIds, {
        void Function(int current, int total)? onInspectionProgress,
        void Function(int sent, int total)? onUploadProgress,
      }) async {
    _logDebug('🚀 === SYNC INSPECTIONS SPÉCIFIQUES: $inspectionIds ===');

    final results = <InspectionSyncResult>[];

    for (int i = 0; i < inspectionIds.length; i++) {
      final inspectionId = inspectionIds[i];
      onInspectionProgress?.call(i + 1, inspectionIds.length);

      final result = await syncInspection(
        inspectionId,
        onProgress: onUploadProgress,
      );

      results.add(result);
    }

    return results;
  }
}

// ============================================================
// WIDGETS D'INTERFACE
// ============================================================

/// Bouton pour synchroniser toutes les inspections en attente
class SyncAllInspectionsButton extends StatefulWidget {
  const SyncAllInspectionsButton({super.key});

  @override
  State<SyncAllInspectionsButton> createState() => _SyncAllInspectionsButtonState();
}

class _SyncAllInspectionsButtonState extends State<SyncAllInspectionsButton> {
  bool _loading = false;
  String _statusMessage = '';
  double _progress = 0.0;

  Future<void> _onPressed() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _statusMessage = 'Recherche des inspections...';
      _progress = 0;
    });

    try {
      final results = await InspectionSyncService.syncAllPendingInspections(
        onInspectionProgress: (current, total) {
          setState(() {
            _statusMessage = 'Synchronisation $current/$total...';
            _progress = current / total;
          });
        },
      );

      if (!mounted) return;

      final successCount = results.where((r) => r.success).length;
      final totalCount = results.length;

      final message = totalCount == 0
          ? 'Aucune inspection à synchroniser'
          : '$successCount/$totalCount inspections synchronisées';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: successCount == totalCount ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 5),
        ),
      );

      // Afficher les détails des échecs
      final failures = results.where((r) => !r.success).toList();
      if (failures.isNotEmpty && mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Détails de la synchronisation'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✅ Réussies: $successCount'),
                  Text('❌ Échouées: ${failures.length}'),
                  const SizedBox(height: 16),
                  ...failures.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('• Inspection ${f.inspectionId}: ${f.message}'),
                  )),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _statusMessage = '';
          _progress = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FilledButton.icon(
          icon: _loading
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Icon(Icons.cloud_upload),
          label: _loading
              ? Text('${(_progress * 100).toStringAsFixed(0)}%')
              : const Text('Synchroniser toutes les inspections'),
          onPressed: _loading ? null : _onPressed,
        ),
        if (_loading && _statusMessage.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _statusMessage,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: _progress),
        ],
      ],
    );
  }
}

/// Bouton pour synchroniser des inspections spécifiques
class SyncSpecificInspectionsButton extends StatefulWidget {
  final List<int> inspectionIds;
  final String? buttonLabel;

  const SyncSpecificInspectionsButton({
    super.key,
    required this.inspectionIds,
    this.buttonLabel,
  });

  @override
  State<SyncSpecificInspectionsButton> createState() => _SyncSpecificInspectionsButtonState();
}

class _SyncSpecificInspectionsButtonState extends State<SyncSpecificInspectionsButton> {
  bool _loading = false;
  String _statusMessage = '';
  double _progress = 0.0;

  Future<void> _onPressed() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _statusMessage = 'Synchronisation...';
      _progress = 0;
    });

    try {
      final results = await InspectionSyncService.syncSpecificInspections(
        widget.inspectionIds,
        onInspectionProgress: (current, total) {
          setState(() {
            _statusMessage = 'Synchronisation $current/$total...';
            _progress = current / total;
          });
        },
      );

      if (!mounted) return;

      final successCount = results.where((r) => r.success).length;
      final message = '$successCount/${results.length} inspections synchronisées';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: successCount == results.length ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _statusMessage = '';
          _progress = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      icon: _loading
          ? const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : const Icon(Icons.sync),
      label: Text(widget.buttonLabel ?? 'Synchroniser ${widget.inspectionIds.length} inspections'),
      onPressed: _loading ? null : _onPressed,
    );
  }
}