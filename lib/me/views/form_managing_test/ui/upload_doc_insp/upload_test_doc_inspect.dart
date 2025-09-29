// lib/services/inspection_docs_sync.dart
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:e_Inspection_APP/me/services/database_service.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


// Configuration Dio avec EXACTEMENT les mêmes headers que Postman
final _dio = Dio(BaseOptions(
  baseUrl: 'https://www.mirah-csp.com/api/v1/',
  headers: {
    // Headers qui fonctionnent dans Postman
    'Accept': 'application/json',
    'User-Agent': 'PostmanRuntime/7.48.0',  // Même User-Agent que Postman
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
    developer.log(obj.toString(), name: 'DIO_REQUEST');
    if (kDebugMode) print('🌐 DIO: $obj');
  },
));

void _logDebug(String message, {String? tag, Object? error}) {
  final logTag = tag ?? 'INSPECTION_UPLOAD';
  developer.log(message, name: logTag, error: error);
  if (kDebugMode) print('📋 [$logTag] $message${error != null ? ' ERROR: $error' : ''}');
}

Future<List<Map<String, dynamic>>> _fetchDocumentsFor320(Database db) async {
  _logDebug('📥 Récupération des documents pour inspection 320...');

  try {
    final rows = await db.query(
      'inspections',
      columns: ['id', 'json_field'],
      where: 'id = ?',
      whereArgs: [320],
      limit: 1,
    );

    _logDebug('📊 Nombre de lignes trouvées: ${rows.length}');

    if (rows.isEmpty) {
      _logDebug('⚠️ Aucune inspection avec l\'ID 320 trouvée');
      return [];
    }

    final raw = rows.first['json_field'] as String?;
    _logDebug('📄 Contenu json_field (${raw?.length ?? 0} caractères): ${raw?.substring(0, raw != null && raw.length > 200 ? 200 : raw?.length ?? 0)}${(raw?.length ?? 0) > 200 ? '...' : ''}');

    if (raw == null || raw.trim().isEmpty) {
      _logDebug('⚠️ Le champ json_field est vide ou null');
      return [];
    }

    Map<String, dynamic> jf;
    try {
      jf = json.decode(raw) as Map<String, dynamic>;
      _logDebug('✅ JSON décodé avec succès. Clés principales: ${jf.keys.toList()}');
    } catch (e) {
      _logDebug('❌ Erreur de décodage JSON', error: e);
      return [];
    }

    final c = (jf['c'] ?? {}) as Map<String, dynamic>;
    _logDebug('📁 Contenu de "c": clés = ${c.keys.toList()}');

    final docs = (c['documents'] ?? []) as List;
    final validDocs = docs.whereType<Map<String, dynamic>>().toList();

    _logDebug('📋 ${docs.length} documents bruts trouvés, ${validDocs.length} documents valides');

    for (int i = 0; i < validDocs.length; i++) {
      final doc = validDocs[i];
      _logDebug('📄 Document $i: ${doc.keys.toList()}');
      _logDebug('   - typeDocumentId: ${doc['typeDocumentId']}');
      _logDebug('   - typeDocumentLabel: ${doc['typeDocumentLabel']}');
      _logDebug('   - attachments: ${(doc['attachments'] ?? []).length} fichiers');

      final attachments = (doc['attachments'] ?? []) as List;
      for (int j = 0; j < attachments.length; j++) {
        final path = attachments[j]?.toString() ?? '';
        final exists = path.isNotEmpty ? await File(path).exists() : false;
        _logDebug('     Fichier $j: $path (existe: $exists)');
      }
    }

    return validDocs;
  } catch (e, stackTrace) {
    _logDebug('❌ Erreur lors de la récupération des documents', error: e);
    _logDebug('Stack trace: $stackTrace');
    rethrow;
  }
}

Future<Response> _uploadDocsFor320(List<Map<String, dynamic>> documents,
    {void Function(int, int)? onProgress}) async {

  _logDebug('🚀 Début de l\'upload pour ${documents.length} documents');

  final form = FormData()..fields.add(const MapEntry('inspection_id', '320'));
  _logDebug('📝 Ajouté inspection_id = 320');

  for (int i = 0; i < documents.length; i++) {
    final doc = documents[i];
    _logDebug('📄 Traitement document $i...');

    void addField(String key, dynamic value) {
      if (value == null) {
        _logDebug('   ⚠️ Champ $key est null, ignoré');
        return;
      }
      final strValue = value.toString().trim();
      if (strValue.isEmpty) {
        _logDebug('   ⚠️ Champ $key est vide, ignoré');
        return;
      }
      form.fields.add(MapEntry('documents[$i][$key]', strValue));
      _logDebug('   ✅ Ajouté documents[$i][$key] = $strValue');
    }

    addField('typeDocumentId',    doc['typeDocumentId']);
    addField('typeDocumentLabel', doc['typeDocumentLabel']);
    addField('identifiant',       doc['identifiant']);
    addField('delivrePar',        doc['delivrePar']);
    addField('dateEmission',      doc['dateEmission']);
    addField('dateExpiration',    doc['dateExpiration']);

    // Gestion robuste du champ booléen
    final verifie = doc['verifie'];
    final verifieValue = (verifie == true || verifie == 1 || verifie == '1' || verifie == 'true') ? '1' : '0';
    form.fields.add(MapEntry('documents[$i][verifie]', verifieValue));
    _logDebug('   ✅ Ajouté documents[$i][verifie] = $verifieValue (original: $verifie)');

    final attachments = (doc['attachments'] ?? []) as List;
    _logDebug('   📎 ${attachments.length} attachments à traiter');

    for (int j = 0; j < attachments.length; j++) {
      final path = attachments[j]?.toString() ?? '';
      if (path.isEmpty) {
        _logDebug('     ⚠️ Chemin vide pour attachment $j');
        continue;
      }

      _logDebug('     📁 Vérification fichier: $path');
      final f = File(path);

      if (await f.exists()) {
        try {
          final stat = await f.stat();
          _logDebug('     ✅ Fichier existe: ${p.basename(path)} (${stat.size} bytes)');

          form.files.add(MapEntry(
            'documents[$i][attachments][$j]',
            await MultipartFile.fromFile(
              path,
              filename: p.basename(path),
            ),
          ));
          _logDebug('     ✅ Fichier ajouté au FormData: documents[$i][attachments][$j]');
        } catch (e) {
          _logDebug('     ❌ Erreur lors de l\'ajout du fichier', error: e);
          form.fields.add(MapEntry('documents[$i][missing][$j]', path));
        }
      } else {
        _logDebug('     ❌ Fichier n\'existe pas: $path');
        form.fields.add(MapEntry('documents[$i][missing][$j]', path));
      }
    }
  }

  // Debug: afficher tout le contenu du FormData
  _logDebug('📋 Contenu final du FormData:');
  _logDebug('   Fields (${form.fields.length}):');
  for (final field in form.fields) {
    _logDebug('     ${field.key} = ${field.value}');
  }
  _logDebug('   Files (${form.files.length}):');
  for (final file in form.files) {
    _logDebug('     ${file.key} = ${file.value.filename} (${file.value.length} bytes)');
  }

  try {
    _logDebug('🌐 Envoi de la requête POST avec headers Postman');

    final response = await _dio.post(
      '/inspections/320/documents',
      data: form,
      onSendProgress: (sent, total) {
        final percent = total > 0 ? (sent / total * 100).toStringAsFixed(1) : '0';
        _logDebug('📤 Progression: $sent/$total bytes ($percent%)');
        onProgress?.call(sent, total);
      },
      options: Options(
        headers: {
          // EXACTEMENT les mêmes headers que Postman qui fonctionne
          'Accept': 'application/json',
          'User-Agent': 'PostmanRuntime/7.48.0',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
          // Content-Type sera automatiquement défini par Dio pour FormData
          // Content-Length sera calculé automatiquement
        },
        validateStatus: (status) => true, // Accepte tous les statuts pour debug
        followRedirects: true,
        maxRedirects: 5,
      ),
    );

    _logDebug('📥 Réponse reçue:');
    _logDebug('   Status: ${response.statusCode}');
    _logDebug('   Headers: ${response.headers}');
    _logDebug('   Data: ${response.data}');

    return response;

  } on DioException catch (e) {
    _logDebug('❌ Erreur DioException:');
    _logDebug('   Type: ${e.type}');
    _logDebug('   Message: ${e.message}');
    _logDebug('   Response Status: ${e.response?.statusCode}');
    _logDebug('   Response Headers: ${e.response?.headers}');
    _logDebug('   Response Data: ${e.response?.data}');
    _logDebug('   Request Options: ${e.requestOptions}');

    if (e.response?.data is Map) {
      final data = e.response!.data as Map;
      _logDebug('   Détails erreur serveur: ${data.toString()}');
    }

    rethrow;
  } catch (e, stackTrace) {
    _logDebug('❌ Erreur générale:', error: e);
    _logDebug('Stack trace: $stackTrace');
    rethrow;
  }
}

/// 👉 Fonction publique à appeler depuis le bouton
Future<bool> pushInspection320(Database db, {void Function(int,int)? onProgress}) async {
  _logDebug('🚀 === DÉBUT UPLOAD INSPECTION 320 (Headers Postman) ===');

  try {
    final docs = await _fetchDocumentsFor320(db);

    if (docs.isEmpty) {
      _logDebug('❌ Aucun document à envoyer pour l\'inspection 320');
      throw Exception("Aucun document à envoyer pour l'inspection 320.");
    }

    _logDebug('✅ ${docs.length} documents prêts pour l\'upload');

    final res = await _uploadDocsFor320(docs, onProgress: onProgress);

    final isSuccess = (res.statusCode == 200 || res.statusCode == 201);
    final hasOkFlag = res.data is Map && (res.data as Map)['ok'] == true;
    final finalResult = isSuccess && hasOkFlag;

    _logDebug('📊 Résultat final:');
    _logDebug('   Status OK: $isSuccess (${res.statusCode})');
    _logDebug('   Flag OK: $hasOkFlag');
    _logDebug('   Succès global: $finalResult');
    _logDebug('🏁 === FIN UPLOAD INSPECTION 320 ===');

    return finalResult;

  } catch (e, stackTrace) {
    _logDebug('❌ Erreur dans pushInspection320', error: e);
    _logDebug('Stack trace complet: $stackTrace');
    _logDebug('🏁 === ÉCHEC UPLOAD INSPECTION 320 ===');
    rethrow;
  }
}

class PushInspection320Button extends StatefulWidget {
  const PushInspection320Button({super.key});

  @override
  State<PushInspection320Button> createState() => _PushInspection320ButtonState();
}

class _PushInspection320ButtonState extends State<PushInspection320Button> {
  bool _loading = false;
  double _progress = 0.0;
  String _statusMessage = '';

  void _logDebug(String message, {Object? error}) {
    developer.log(message, name: 'UPLOAD_BUTTON', error: error);
    if (kDebugMode) print('🔘 [BUTTON] $message${error != null ? ' ERROR: $error' : ''}');
  }

  Future<void> _onPressed() async {
    if (_loading) {
      _logDebug('⚠️ Upload déjà en cours, ignorer le clic');
      return;
    }

    _logDebug('🔘 Bouton pressé - Début upload');
    setState(() {
      _loading = true;
      _progress = 0;
      _statusMessage = 'Préparation...';
    });

    try {
      _logDebug('📊 Récupération de la base de données...');
      final Database db = await DatabaseHelper.database;
      _logDebug('✅ Base de données obtenue');

      setState(() => _statusMessage = 'Envoi en cours...');

      final ok = await pushInspection320(
        db,
        onProgress: (sent, total) {
          if (total > 0) {
            final progress = sent / total;
            final percent = (progress * 100).toStringAsFixed(1);
            _logDebug('📈 Progression: $sent/$total ($percent%)');
            setState(() {
              _progress = progress;
              _statusMessage = 'Envoi... $percent%';
            });
          }
        },
      );

      _logDebug('📋 Résultat upload: $ok');

      if (!mounted) {
        _logDebug('⚠️ Widget non monté, pas de mise à jour UI');
        return;
      }

      final message = ok
          ? 'Documents de l\'inspection 320 envoyés avec succès.'
          : 'Échec de l\'envoi des documents.';

      _logDebug('💬 Message à afficher: $message');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: ok ? Colors.green : Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );

    } catch (e, stackTrace) {
      _logDebug('❌ Erreur dans _onPressed', error: e);
      _logDebug('Stack trace: $stackTrace');

      if (!mounted) {
        _logDebug('⚠️ Widget non monté après erreur');
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8),
        ),
      );
    } finally {
      if (mounted) {
        _logDebug('🔄 Remise à zéro de l\'état du bouton');
        setState(() {
          _loading = false;
          _progress = 0;
          _statusMessage = '';
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
            width: 18, height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Icon(Icons.cloud_upload),
          label: _loading
              ? Text('${(_progress * 100).toStringAsFixed(0)}%')
              : const Text('Envoyer documents (ID 320)'),
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