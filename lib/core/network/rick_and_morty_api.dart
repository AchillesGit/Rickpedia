import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;

  const ApiException(this.statusCode);

  @override
  String toString() => 'Rick and Morty API request failed (HTTP $statusCode)';
}

Future<dynamic> fetchApiJson(
  String resource, {
  Map<String, String>? queryParameters,
}) async {
  final url = Uri.https(
    'rickandmortyapi.com',
    '/api/$resource',
    queryParameters,
  );
  final response = await http.get(url).timeout(const Duration(seconds: 15));
  if (response.statusCode != 200) throw ApiException(response.statusCode);
  return jsonDecode(response.body);
}
