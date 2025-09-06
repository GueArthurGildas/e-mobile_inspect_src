import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class InspectionApi {
  final String baseUrl; // ex: https://www.mirah-csp.com/api/v1  (sans slash final)
  InspectionApi({required this.baseUrl});

  static const _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  /// PUT /inspections/sync  Body: {"ids":[...]}
  Future<int> syncIds(List<int> ids, {Duration timeout = const Duration(seconds: 20)}) async {
    final uri = Uri.parse('$baseUrl/inspections/sync');
    final res = await http
        .put(uri, headers: _headers, body: jsonEncode({'ids': ids}))
        .timeout(timeout);

    if (res.statusCode != 200) {
      throw HttpException('HTTP ${res.statusCode}: ${res.body}');
    }

    final ct = res.headers['content-type'] ?? '';
    if (!ct.contains('application/json')) {
      throw const FormatException('Réponse non-JSON (content-type inattendu)');
    }

    final data = jsonDecode(res.body);
    if (data is! Map || !data.containsKey('updated')) {
      throw const FormatException('JSON invalide: champ "updated" manquant');
    }
    return (data['updated'] as num).toInt();
  }
}
