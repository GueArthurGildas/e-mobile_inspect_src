// inspection_api.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class InspectionApi {
  final String baseUrl; // ex: https://www.mirah-csp.com/api/v1
  InspectionApi({required this.baseUrl});

  static const _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  /// PUT /inspections/sync
  /// Body: {"items":[ {"id":319,"json_field":{...}}, ... ]}
  Future<int> syncPayloads(List<Map<String, dynamic>> items,
      {Duration timeout = const Duration(seconds: 20)}) async {
    final uri = Uri.parse('$baseUrl/inspections/sync');
    final res = await http
        .put(uri, headers: _headers, body: jsonEncode({'items': items}))
        .timeout(timeout);

    if (res.statusCode != 200) {
      throw HttpException('HTTP ${res.statusCode}: ${res.body}');
    }
    final ct = res.headers['content-type'] ?? '';
    if (!ct.contains('application/json')) {
      throw const FormatException('Réponse non-JSON');
    }
    final data = jsonDecode(res.body);
    if (data is! Map || !data.containsKey('updated')) {
      throw const FormatException('JSON invalide: "updated" manquant');
    }
    return (data['updated'] as num).toInt();
  }
}
