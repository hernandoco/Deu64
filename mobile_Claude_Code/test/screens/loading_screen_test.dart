import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/pages/login_page.dart';
import 'package:mobile/screens/home_screen.dart';
import 'package:mobile/screens/loading_screen.dart';

import '../helpers.dart';

const kTopicCacheKey = 'cache_topic_v1';

final kTopicJson = jsonEncode({
  'topicId': kTestTopicId,
  'title': 'Detrás del corazón de Dios',
  'scenes': [
    for (var i = 1; i <= 3; i++)
      {
        'index': i,
        'title': 'Escena $i',
        'description': 'Descripción $i',
        'imageUrl': 'http://example.invalid/escena$i.png',
      },
  ],
});

/// Abre la pantalla de carga en un teléfono y espera a que abra el login.
Future<void> openLoading(
  WidgetTester tester, {
  required FakeAuthService auth,
  required FakeCacheManager images,
  Map<String, Object> cache = const {},
}) async {
  tester.view.physicalSize = const Size(412, 915);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  seedCache(cache);
  await pumpScreen(
    tester,
    LoadingScreen(authService: auth, imageCacheManager: images),
  );
  await tester.pumpAndSettle(); // primer frame: abre el login
}

/// Inicia sesión en el login falso y espera a que termine la carga.
Future<void> loginWith(WidgetTester tester, FakeAuthService auth) async {
  await tester.tap(find.text('Iniciar sesión'));
  await tester.pump();
  auth.succeed(tokens());
  await tester.pumpAndSettle();
  await waitForLoad(tester);
}

void main() {
  setUp(() {
    imageCache.clear();
    imageCache.clearLiveImages();
  });

  testWidgets('al abrir, lo primero que muestra es el login', (tester) async {
    await openLoading(
      tester,
      auth: FakeAuthService(),
      images: FakeCacheManager(fails: true),
    );

    expect(find.byType(LoginPage), findsOneWidget);
    // Detrás del login queda la carga, esperando.
    expect(
      find.text('Iniciando sesión...', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('después del login abre el Home con el tema del día', (
    tester,
  ) async {
    final auth = FakeAuthService();
    await openLoading(
      tester,
      auth: auth,
      images: FakeCacheManager(fails: true),
      cache: {kTopicCacheKey: kTopicJson},
    );

    await loginWith(tester, auth);

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(LoadingScreen), findsNothing);
    expect(find.text('Detrás del corazón de Dios'), findsWidgets);
  });

  testWidgets('precarga las imágenes de todas las escenas', (tester) async {
    final auth = FakeAuthService();
    final images = FakeCacheManager(fails: true);
    await openLoading(
      tester,
      auth: auth,
      images: images,
      cache: {kTopicCacheKey: kTopicJson},
    );

    await loginWith(tester, auth);

    expect(images.precached, [
      for (var i = 1; i <= 3; i++) 'http://example.invalid/escena$i.png',
    ]);
  });

  testWidgets('si no se puede cargar el tema, muestra el error', (
    tester,
  ) async {
    final auth = FakeAuthService();
    await openLoading(
      tester,
      auth: auth,
      images: FakeCacheManager(fails: true),
    );

    await loginWith(tester, auth);

    expect(find.byType(HomeScreen), findsNothing);
    expect(find.textContaining('Error cargando datos:'), findsOneWidget);
    expect(find.textContaining('leer_tema'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('"Reintentar" vuelve a pedir el login', (tester) async {
    final auth = FakeAuthService();
    await openLoading(
      tester,
      auth: auth,
      images: FakeCacheManager(fails: true),
    );
    await loginWith(tester, auth);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('si se sale del login con "atrás", ofrece volver a '
      'iniciar sesión', (tester) async {
    await openLoading(
      tester,
      auth: FakeAuthService(),
      images: FakeCacheManager(fails: true),
    );

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsNothing);
    expect(find.text('Inicio de sesión cancelado'), findsOneWidget);
    // Ya no queda el indicador girando sin salida.
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('tras cancelar, se puede iniciar sesión y llegar al Home', (
    tester,
  ) async {
    final auth = FakeAuthService();
    await openLoading(
      tester,
      auth: auth,
      images: FakeCacheManager(fails: true),
      cache: {kTopicCacheKey: kTopicJson},
    );
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    await loginWith(tester, auth);

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
