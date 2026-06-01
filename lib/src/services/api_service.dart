// =============================================================================
// ARQUIVO: lib/src/services/api_service.dart
// =============================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/filme_model.dart';

class ApiService {
  static const String _apiKey = 'af532920';
  static const String _baseUrl = 'https://www.omdbapi.com/';

  Future<List<FilmeModel>> buscarFilmes(String termoBusca) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        's': termoBusca,
        'apikey': _apiKey,
        'type': 'movie',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> dados = jsonDecode(response.body);
      if (dados['Response'] == 'True') {
        final List<dynamic> listaJson = dados['Search'];
        return listaJson.map((json) => FilmeModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Falha na requisição. Status: ${response.statusCode}');
    }
  }
}
