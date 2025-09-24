// lib/services/inspection_docs_sync.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
// lib/widgets/push_inspection_320_button.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:e_Inspection_APP/me/services/database_service.dart';


final _dio = Dio(BaseOptions(
  baseUrl: 'https://www.mirah-csp.com/api/v1/', // ⬅️ change l’URL
  headers: {'Accept': 'application/json'},
  connectTimeout: const Duration(seconds: 20),
  receiveTimeout: const Duration(seconds: 60),
));

Future<List<Map<String, dynamic>>> _fetchDocumentsFor320(Database db) async {
  final rows = await db.query(
    'inspections',
    columns: ['id', 'json_field'],
    where: 'id = ?',
    whereArgs: [320],
    limit: 1,
  );
  if (rows.isEmpty) return [];

  final raw = rows.first['json_field'] as String?;
  if (raw == null || raw.trim().isEmpty) return [];

  Map<String, dynamic> jf;
  try {
    jf = json.decode(raw) as Map<String, dynamic>;
  } catch (_) {
    return [];
  }

  final c = (jf['c'] ?? {}) as Map<String, dynamic>;
  final docs = (c['documents'] ?? []) as List;
  return docs.whereType<Map<String, dynamic>>().toList();
}

Future<Response> _uploadDocsFor320(List<Map<String, dynamic>> documents,
    {void Function(int, int)? onProgress}) async {
  final form = FormData()..fields.add(const MapEntry('inspection_id', '320'));

  for (int i = 0; i < documents.length; i++) {
    final doc = documents[i];

    void addField(String key, dynamic value) {
      if (value == null) return;
      form.fields.add(MapEntry('documents[$i][$key]', '$value'));
    }

    addField('typeDocumentId',    doc['typeDocumentId']);
    addField('typeDocumentLabel', doc['typeDocumentLabel']);
    addField('identifiant',       doc['identifiant']);
    addField('delivrePar',        doc['delivrePar']);
    addField('dateEmission',      doc['dateEmission']);
    addField('dateExpiration',    doc['dateExpiration']);
    addField('verifie',           (doc['verifie'] == true) ? 1 : 0);

    final attachments = (doc['attachments'] ?? []) as List;
    for (int j = 0; j < attachments.length; j++) {
      final path = attachments[j]?.toString() ?? '';
      if (path.isEmpty) continue;
      final f = File(path);
      if (await f.exists()) {
        form.files.add(MapEntry(
          'documents[$i][attachments][$j]',
          await MultipartFile.fromFile(path, filename: p.basename(path)),
        ));
      } else {
        form.fields.add(MapEntry('documents[$i][missing][$j]', path));
      }
    }
  }

  return _dio.post('/inspections/320/documents', data: form, onSendProgress: onProgress);
}

/// 👉 Fonction publique à appeler depuis le bouton
Future<bool> pushInspection320(Database db, {void Function(int,int)? onProgress}) async {
  final docs = await _fetchDocumentsFor320(db);
  if (docs.isEmpty) {
    throw Exception("Aucun document à envoyer pour l'inspection 320.");
  }
  final res = await _uploadDocsFor320(docs, onProgress: onProgress);
  return (res.statusCode == 200 || res.statusCode == 201) && (res.data?['ok'] == true);
}



//////////////////////////////////

class PushInspection320Button extends StatefulWidget {
  const PushInspection320Button({super.key});

  @override
  State<PushInspection320Button> createState() => _PushInspection320ButtonState();
}

class _PushInspection320ButtonState extends State<PushInspection320Button> {
  bool _loading = false;
  double _progress = 0.0;

  Future<void> _onPressed() async {
    if (_loading) return;
    setState(() { _loading = true; _progress = 0; });

    try {
      final Database db = await DatabaseHelper.database;

      final ok = await pushInspection320(
        db,
        onProgress: (sent, total) {
          if (total > 0) {
            setState(() => _progress = sent / total);
          }
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? 'Documents de l’inspection 320 envoyés avec succès.'
              : 'Échec de l’envoi des documents.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() { _loading = false; _progress = 0; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      icon: _loading
          ? const SizedBox(
        width: 18, height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : const Icon(Icons.cloud_upload),
      label: _loading
          ? Text('Envoi… ${(_progress * 100).toStringAsFixed(0)}%')
          : const Text('Envoyer documents (ID 320)'),
      onPressed: _onPressed,
    );
  }
}
