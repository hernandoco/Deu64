import 'dart:convert';
import 'package:http/http.dart' as http;

import 'config.dart';
import 'models.dart';

class ApiClient {
  Future<TopicResponse> fetchTopic() async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/leer_tema');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Error leer_tema: ${res.statusCode} ${res.body}');
    }
    return TopicResponse.fromJson(jsonDecode(res.body));
  }

  Future<QuestionsResponse> fetchQuestions() async {
    final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/preguntas_tema');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Error preguntas_tema: ${res.statusCode} ${res.body}');
    }
    return QuestionsResponse.fromJson(jsonDecode(res.body));
  }
}