import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
import 'models.dart';


class ApiClient {
  static const _cacheTopicKey = 'cache_topic_v1';
  static const _cacheLastTopicIdKey = 'cache_last_topic_id_v1';
  static const _cacheQuestionsPrefix = 'cache_questions_v1_';

  static const Duration _timeout = Duration(seconds: 6);

/*
  Future<TopicResponse> fetchTopic() async {
    print('=== FLAG: fetchTopic 0 ===');
    final prefs = await SharedPreferences.getInstance();
    final cachedTopicStr = prefs.getString(_cacheTopicKey);

    print('=== FLAG: fetchTopic 1 ===');
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/leer_tema');
      final res = await http.get(uri).timeout(_timeout);

print('=== FLAG: fetchTopic 2 ===');

      if (res.statusCode != 200) {
        throw Exception('Error leer_tema: ${res.statusCode} ${res.body}');
      }

print('=== FLAG: fetchTopic 3 ===');
      await prefs.setString(_cacheTopicKey, res.body);

print('=== FLAG: fetchTopic 4 ===');
      final topic = TopicResponse.fromJson(jsonDecode(res.body));
      print('=== FLAG: fetchTopic 5 ===');
      await prefs.setString(_cacheLastTopicIdKey, topic.topicId);
      print('=== FLAG: fetchTopic 6 ===');
      return topic;
    } on SocketException catch (_) {
      if (cachedTopicStr != null && cachedTopicStr.isNotEmpty) {
        return TopicResponse.fromJson(jsonDecode(cachedTopicStr));
      }
      rethrow;
    } on HttpException catch (_) {
      if (cachedTopicStr != null && cachedTopicStr.isNotEmpty) {
        return TopicResponse.fromJson(jsonDecode(cachedTopicStr));
      }
      rethrow;
    } on FormatException catch (_) {
      // JSON inválido (raro, pero posible)
      rethrow;
    } on Exception catch (e) {
      // Timeout u otro error
      if (cachedTopicStr != null && cachedTopicStr.isNotEmpty) {
        return TopicResponse.fromJson(jsonDecode(cachedTopicStr));
      }
      throw e;
    }
  }
  original*/

  Future<TopicResponse> fetchTopic() async {
  final prefs = await SharedPreferences.getInstance();
  final cachedTopicStr = prefs.getString(_cacheTopicKey);
  final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/leer_tema');


  try {
    final res = await http.get(uri).timeout(_timeout);

    if (res.statusCode != 200) {
      throw Exception('Error leer_tema: ${res.statusCode} ${res.body}');
    }

    await prefs.setString(_cacheTopicKey, res.body);
    final topic = TopicResponse.fromJson(jsonDecode(res.body));
    await prefs.setString(_cacheLastTopicIdKey, topic.topicId);
    return topic;
  } catch (e) {
    // Ya no se oculta el error

    if (cachedTopicStr != null && cachedTopicStr.isNotEmpty) {
      return TopicResponse.fromJson(jsonDecode(cachedTopicStr));
    }
    rethrow;
  }
}

  Future<QuestionsResponse> fetchQuestions(String topicId) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cacheQuestionsPrefix$topicId';
    final cachedQuestionsStr = prefs.getString(cacheKey);
    try {
      final uri = Uri.parse('${AppConfig.baseUrl}/api/v1/preguntas_tema')
          .replace(queryParameters: {'topicId': topicId});

      final res = await http.get(uri).timeout(_timeout);

      if (res.statusCode != 200) {
        throw Exception('Error preguntas_tema: ${res.statusCode} ${res.body}');
      }

      await prefs.setString(cacheKey, res.body);
      return QuestionsResponse.fromJson(jsonDecode(res.body));
    } catch (e) {
      if (cachedQuestionsStr != null && cachedQuestionsStr.isNotEmpty) {
        return QuestionsResponse.fromJson(jsonDecode(cachedQuestionsStr));
      }
      rethrow;
    }
  }
}