// lib/services/inspection_images_sync_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:e_Inspection_APP/me/services/database_service.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

void _logDebug(String message, {String? tag, Object? error}) {
  final logTag = tag ?? 'IMAGES_SYNC';
  developer.log(message, name: logTag, error: error);
  if (kDebugMode) print('📸 [$logTag] $message${error != null ? ' ERROR: $error' : ''}');
}

final _dio = Dio(BaseOptions(
  baseUrl: 'https://www.mirah-csp.com/api/v1/',
  headers: {
    'Accept': 'application/json',
    'User-Agent': 'PostmanRuntime/7.48.0',
    'Accept-Encoding': 'gzip, deflate, br',
    'Connection': 'keep-alive',
  },
  connectTimeout: const Duration(seconds: 60),
  receiveTimeout: const Duration(seconds: 180),
  sendTimeout: const Duration(seconds: 180),
));

/// Résultat de synchronisation des images pour une inspection
class ImagesSyncResult {
  final int inspectionId;
  final bool success;
  final String message;
  final int totalImages;
  final int uploadedImages;
  final List<String> errors;

  ImagesSyncResult({
    required this.inspectionId,
    required this.success,
    required this.message,
    this.totalImages = 0,
    this.uploadedImages = 0,
    this.errors = const [],
  });
}

/// Structure pour une capture avec ses images
class CaptureData {
  final String type; // 'captureDebarque', 'captureABord', 'captureInterdite'
  final String uuid;
  final String especeId;
  final List<String> zoneIds;
  final String presentationId;
  final String conservationId;
  final String quantiteObservee;
  final String quantiteDeclaree;
  final String quantiteRetenue;
  final String? observations;
  final List<String> imagePaths;

  CaptureData({
    required this.type,
    required this.uuid,
    required this.especeId,
    required this.zoneIds,
    required this.presentationId,
    required this.conservationId,
    required this.quantiteObservee,
    required this.quantiteDeclaree,
    required this.quantiteRetenue,
    this.observations,
    required this.imagePaths,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'uuid': uuid,
    'especeId': especeId,
    'zoneIds': zoneIds,
    'presentationId': presentationId,
    'conservationId': conservationId,
    'quantiteObservee': quantiteObservee,
    'quantiteDeclaree': quantiteDeclaree,
    'quantiteRetenue': quantiteRetenue,
    'observations': observations,
  };
}

class InspectionImagesSyncService {
  /// Extrait toutes les captures avec images de la section "e"
  static Future<List<CaptureData>> _extractCapturesFromInspection(
      Database db,
      int inspectionId,
      ) async {
    _logDebug('📥 Extraction captures pour inspection $inspectionId...');

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
        _logDebug('❌ Erreur décodage JSON', error: e);
        return [];
      }

      // Extraire la section "e"
      final e = (jf['e'] ?? {}) as Map<String, dynamic>;
      if (e.isEmpty) {
        _logDebug('ℹ️ Section "e" vide ou absente');
        return [];
      }

      final captures = <CaptureData>[];

      // Traiter chaque type de capture
      final captureTypes = ['captureDebarque', 'captureABord', 'captureInterdite'];

      for (final type in captureTypes) {
        final captureList = (e[type] ?? []) as List;

        for (final item in captureList) {
          if (item is! Map<String, dynamic>) continue;

          final imagePaths = (item['imagePaths'] ?? []) as List;
          final validPaths = imagePaths
              .map((p) => p?.toString() ?? '')
              .where((p) => p.isNotEmpty)
              .toList();

          if (validPaths.isEmpty) continue;

          captures.add(CaptureData(
            type: type,
            uuid: item['uuid']?.toString() ?? '',
            especeId: item['especeId']?.toString() ?? '',
            zoneIds: ((item['zoneIds'] ?? []) as List)
                .map((z) => z?.toString() ?? '')
                .toList(),
            presentationId: item['presentationId']?.toString() ?? '',
            conservationId: item['conservationId']?.toString() ?? '',
            quantiteObservee: item['quantiteObservee']?.toString() ?? '',
            quantiteDeclaree: item['quantiteDeclaree']?.toString() ?? '',
            quantiteRetenue: item['quantiteRetenue']?.toString() ?? '',
            observations: item['observations']?.toString(),
            imagePaths: validPaths,
          ));
        }
      }

      _logDebug('✅ ${captures.length} captures avec images trouvées');
      int totalImages = captures.fold(0, (sum, c) => sum + c.imagePaths.length);
      _logDebug('📸 Total images: $totalImages');

      return captures;
    } catch (e, stackTrace) {
      _logDebug('❌ Erreur extraction captures', error: e);
      _logDebug('Stack trace: $stackTrace');
      return [];
    }
  }

  /// Upload les images d'une inspection vers le serveur
  static Future<ImagesSyncResult> _uploadImages(
      int inspectionId,
      List<CaptureData> captures,
      void Function(int, int)? onProgress,
      ) async {
    _logDebug('🚀 Upload images pour inspection $inspectionId');

    if (captures.isEmpty) {
      return ImagesSyncResult(
        inspectionId: inspectionId,
        success: false,
        message: 'Aucune capture avec images',
      );
    }

    final form = FormData()
      ..fields.add(MapEntry('inspection_id', inspectionId.toString()));

    int totalImages = 0;
    int uploadedImages = 0;
    final errors = <String>[];

    // Construire le FormData
    for (int i = 0; i < captures.length; i++) {
      final capture = captures[i];

      // Ajouter les métadonnées de la capture
      form.fields.add(MapEntry('captures[$i][type]', capture.type));
      form.fields.add(MapEntry('captures[$i][uuid]', capture.uuid));
      form.fields.add(MapEntry('captures[$i][especeId]', capture.especeId));

      // Zones (array)
      for (int z = 0; z < capture.zoneIds.length; z++) {
        form.fields.add(MapEntry('captures[$i][zoneIds][$z]', capture.zoneIds[z]));
      }

      form.fields.add(MapEntry('captures[$i][presentationId]', capture.presentationId));
      form.fields.add(MapEntry('captures[$i][conservationId]', capture.conservationId));
      form.fields.add(MapEntry('captures[$i][quantiteObservee]', capture.quantiteObservee));
      form.fields.add(MapEntry('captures[$i][quantiteDeclaree]', capture.quantiteDeclaree));
      form.fields.add(MapEntry('captures[$i][quantiteRetenue]', capture.quantiteRetenue));

      if (capture.observations != null) {
        form.fields.add(MapEntry('captures[$i][observations]', capture.observations!));
      }

      // Traiter les images
      for (int j = 0; j < capture.imagePaths.length; j++) {
        totalImages++;
        final path = capture.imagePaths[j];
        final f = File(path);

        if (await f.exists()) {
          try {
            final stat = await f.stat();
            _logDebug('  📎 Image $j (${(stat.size / 1024).toStringAsFixed(1)} KB): ${p.basename(path)}');

            form.files.add(MapEntry(
              'captures[$i][images][$j]',
              await MultipartFile.fromFile(
                path,
                filename: p.basename(path),
              ),
            ));
            uploadedImages++;
          } catch (e) {
            final error = 'Erreur ajout image $j de capture $i: $e';
            _logDebug('  ❌ $error');
            errors.add(error);
            form.fields.add(MapEntry('captures[$i][missing][$j]', path));
          }
        } else {
          final error = 'Fichier inexistant: $path';
          _logDebug('  ❌ $error');
          errors.add(error);
          form.fields.add(MapEntry('captures[$i][missing][$j]', path));
        }
      }
    }

    _logDebug('📦 FormData préparé: $uploadedImages/$totalImages images');

    try {
      final response = await _dio.post(
        '/inspections/$inspectionId/images',
        data: form,
        onSendProgress: (sent, total) {
          onProgress?.call(sent, total);
          if (total > 0) {
            final percent = (sent / total * 100).toStringAsFixed(1);
            _logDebug('📤 Progression: $percent% ($sent/$total bytes)');
          }
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

      _logDebug('📥 Réponse serveur: ${response.statusCode}');
      _logDebug('📄 Data: ${response.data}');

      final isSuccess = (response.statusCode == 200 || response.statusCode == 201);
      final hasOkFlag = response.data is Map && (response.data as Map)['ok'] == true;

      if (isSuccess && hasOkFlag) {
        return ImagesSyncResult(
          inspectionId: inspectionId,
          success: true,
          message: 'Images synchronisées avec succès',
          totalImages: totalImages,
          uploadedImages: uploadedImages,
          errors: errors,
        );
      } else {
        return ImagesSyncResult(
          inspectionId: inspectionId,
          success: false,
          message: 'Échec synchronisation (Status: ${response.statusCode})',
          totalImages: totalImages,
          uploadedImages: uploadedImages,
          errors: errors,
        );
      }
    } catch (e, stackTrace) {
      _logDebug('❌ Erreur upload', error: e);
      _logDebug('Stack trace: $stackTrace');

      return ImagesSyncResult(
        inspectionId: inspectionId,
        success: false,
        message: 'Erreur: ${e.toString()}',
        totalImages: totalImages,
        uploadedImages: uploadedImages,
        errors: [...errors, e.toString()],
      );
    }
  }

  /// Synchronise les images d'une inspection spécifique
  static Future<ImagesSyncResult> syncImagesForInspection(
      int inspectionId, {
        void Function(int, int)? onProgress,
      }) async {
    _logDebug('🔄 === SYNC IMAGES INSPECTION $inspectionId ===');

    final db = await DatabaseHelper.database;
    final captures = await _extractCapturesFromInspection(db, inspectionId);

    if (captures.isEmpty) {
      return ImagesSyncResult(
        inspectionId: inspectionId,
        success: false,
        message: 'Aucune capture avec images',
      );
    }

    return await _uploadImages(inspectionId, captures, onProgress);
  }

  /// Synchronise les images de toutes les inspections avec sync=1 et statut=2
  static Future<List<ImagesSyncResult>> syncAllPendingImages({
    void Function(int current, int total)? onInspectionProgress,
    void Function(int sent, int total)? onUploadProgress,
  }) async {
    _logDebug('🚀 === SYNC TOUTES LES IMAGES ===');

    final db = await DatabaseHelper.database;

    // Récupérer les inspections à synchroniser
    final rows = await db.query(
      'inspections',
      columns: ['id'],
      where: 'sync = ? AND statut_inspection_id = ?',
      whereArgs: [0, 2],
    );

    final inspectionIds = rows.map((row) => row['id'] as int).toList();

    if (inspectionIds.isEmpty) {
      _logDebug('ℹ️ Aucune inspection à synchroniser');
      return [];
    }

    _logDebug('📋 ${inspectionIds.length} inspections à traiter');

    final results = <ImagesSyncResult>[];

    for (int i = 0; i < inspectionIds.length; i++) {
      final inspectionId = inspectionIds[i];
      onInspectionProgress?.call(i + 1, inspectionIds.length);

      _logDebug('📤 Synchronisation ${i + 1}/${inspectionIds.length}: inspection $inspectionId');

      final result = await syncImagesForInspection(
        inspectionId,
        onProgress: onUploadProgress,
      );

      results.add(result);

      _logDebug(result.success
          ? '✅ Inspection $inspectionId: ${result.uploadedImages}/${result.totalImages} images'
          : '❌ Inspection $inspectionId: ${result.message}');
    }

    final successCount = results.where((r) => r.success).length;
    final totalImagesUploaded = results.fold(0, (sum, r) => sum + r.uploadedImages);

    _logDebug('🏁 Terminé: $successCount/${inspectionIds.length} inspections, $totalImagesUploaded images');

    return results;
  }

  /// Synchronise les images de plusieurs inspections spécifiques
  static Future<List<ImagesSyncResult>> syncImagesForSpecificInspections(
      List<int> inspectionIds, {
        void Function(int current, int total)? onInspectionProgress,
        void Function(int sent, int total)? onUploadProgress,
      }) async {
    _logDebug('🚀 === SYNC IMAGES INSPECTIONS: $inspectionIds ===');

    final results = <ImagesSyncResult>[];

    for (int i = 0; i < inspectionIds.length; i++) {
      final inspectionId = inspectionIds[i];
      onInspectionProgress?.call(i + 1, inspectionIds.length);

      final result = await syncImagesForInspection(
        inspectionId,
        onProgress: onUploadProgress,
      );

      results.add(result);
    }

    return results;
  }
}