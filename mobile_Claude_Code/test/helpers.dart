// Utilidades compartidas por los tests de pantallas.
//
// En los tests de Flutter toda petición HTTP responde 400, así que ApiClient
// siempre cae a la copia guardada en SharedPreferences. Los tests aprovechan
// eso: guardan datos de prueba en esa caché y las pantallas los cargan como
// si vinieran del backend.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/services/auth_service.dart';
import 'package:mobile/theme/app_theme.dart';

const kTestTopicId = 'tema-prueba';

/// Claves de caché que usa ApiClient (lib/api.dart).
String questionsCacheKey(String topicId) => 'cache_questions_v1_$topicId';
const kPrayerCacheKey = 'cache_prayer_v1';
const kChallengeCacheKey = 'cache_challenge_v1';

/// Deja la caché con [values] (JSON ya codificado) y nada más.
void seedCache(Map<String, Object> values) {
  SharedPreferences.setMockInitialValues(values);
}

Map<String, Object> questionsCache(List<Map<String, dynamic>> questions) => {
  questionsCacheKey(kTestTopicId): jsonEncode({
    'topicId': kTestTopicId,
    'questions': questions,
  }),
};

Map<String, dynamic> question(
  int index,
  String text,
  List<(String, bool)> options, {
  String recommendation = '',
}) => {
  'index': index,
  'question': text,
  'recommendation': recommendation,
  'options': [
    for (final (t, ok) in options) {'text': t, 'isCorrect': ok},
  ],
};

/// Dos preguntas: la correcta de la 1 es "Moisés" y la de la 2 es "Siete".
final kTwoQuestions = [
  question(1, '¿Quién guió al pueblo?', [
    ('Moisés', true),
    ('Faraón', false),
  ], recommendation: 'Piensa en la historia de hoy'),
  question(2, '¿Cuántos días tiene la semana?', [
    ('Cinco', false),
    ('Siete', true),
  ]),
];

/// Monta [screen] dentro de una app con el tema real de Deu64.
Future<void> pumpScreen(WidgetTester tester, Widget screen) {
  return tester.pumpWidget(MaterialApp(theme: buildKidsTheme(), home: screen));
}

/// Espera a que termine la carga (desaparece el indicador de progreso).
///
/// No se usa pumpAndSettle mientras carga porque el indicador gira sin fin.
Future<void> waitForLoad(WidgetTester tester) async {
  for (var i = 0; i < 50; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) {
      await tester.pumpAndSettle();
      return;
    }
  }
  fail('La pantalla siguió cargando');
}

/// Caché falsa: la caché real necesita carpetas del teléfono (path_provider)
/// que no existen en los tests.
class FakeCacheManager extends Fake implements BaseCacheManager {
  /// true: la descarga falla. false: se queda cargando para siempre.
  final bool fails;
  final _pending = <StreamController<FileResponse>>[];

  /// URLs que se pidieron precargar (getFileFromCache/downloadFile).
  final precached = <String>[];

  FakeCacheManager({required this.fails});

  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) {
    if (fails) return Stream.error(Exception('Sin red: $url'));
    final c = StreamController<FileResponse>();
    _pending.add(c);
    return c.stream;
  }

  @override
  Future<FileInfo?> getFileFromCache(
    String key, {
    bool ignoreMemCache = false,
  }) async {
    precached.add(key);
    return null; // nada guardado todavía
  }

  @override
  Future<FileInfo> downloadFile(
    String url, {
    String? key,
    Map<String, String>? authHeaders,
    bool force = false,
  }) => Future.error(Exception('Sin red: $url'));

  void closePending() {
    for (final c in _pending) {
      c.close();
    }
  }
}

AuthorizationTokenResponse tokens() => AuthorizationTokenResponse(
  'access-token',
  'refresh-token',
  null,
  'id-token',
  'Bearer',
  const ['openid'],
  null,
  null,
);

/// AuthService falso: cada login espera a que el test lo complete.
class FakeAuthService extends AuthService {
  int calls = 0;
  Completer<AuthorizationTokenResponse?> _pending = Completer();

  @override
  Future<AuthorizationTokenResponse?> login() {
    calls++;
    _pending = Completer();
    return _pending.future;
  }

  void succeed(AuthorizationTokenResponse r) => _pending.complete(r);
  void cancel() => _pending.complete(null);
  void fail(Object error) => _pending.completeError(error);
}
