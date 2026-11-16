import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/models.dart';
import 'package:mobile/screens/scenes_carousel_screen.dart';

import '../helpers.dart';

/// Caché falsa: la caché real necesita carpetas del teléfono (path_provider)
/// que no existen en los tests.
class FakeCacheManager extends Fake implements BaseCacheManager {
  /// true: la descarga falla. false: se queda cargando para siempre.
  final bool fails;
  final _pending = <StreamController<FileResponse>>[];

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

  void closePending() {
    for (final c in _pending) {
      c.close();
    }
  }
}

TopicResponse topicWithScenes(int count) => TopicResponse.fromJson({
  'topicId': kTestTopicId,
  'title': 'Detrás del corazón de Dios',
  'scenes': [
    for (var i = 1; i <= count; i++)
      {
        'index': i,
        'title': 'Escena $i',
        'description': 'Descripción de la escena $i',
        'imageUrl': 'http://example.invalid/escena$i.png',
      },
  ],
});

/// Abre la pantalla con imágenes que fallan: tras la espera queda la imagen
/// de reemplazo y ningún indicador girando.
Future<void> openScenes(WidgetTester tester, {int count = 3}) async {
  await pumpScreen(
    tester,
    ScenesCarouselScreen(
      topic: topicWithScenes(count),
      cacheManager: FakeCacheManager(fails: true),
    ),
  );
  await waitForLoad(tester);
}

Future<void> swipe(WidgetTester tester, {required bool forward}) async {
  await tester.drag(find.byType(PageView), Offset(forward ? -500 : 500, 0));
  await waitForLoad(tester);
}

/// Ancho de cada punto del indicador: el de la escena actual mide 10.
List<double?> dotSizes(WidgetTester tester) => [
  for (final dot in tester.widgetList<AnimatedContainer>(
    find.byType(AnimatedContainer),
  ))
    dot.constraints?.maxWidth,
];

void main() {
  // Flutter guarda en memoria las imágenes por URL y la comparte entre
  // tests: sin esto, un test hereda la carga pendiente del anterior.
  setUp(() {
    imageCache.clear();
    imageCache.clearLiveImages();
  });

  testWidgets('muestra el título del tema y la primera escena', (
    tester,
  ) async {
    await openScenes(tester);

    expect(find.text('Detrás del corazón de Dios'), findsOneWidget);
    expect(find.text('Escena 1'), findsOneWidget);
    expect(find.text('Descripción de la escena 1'), findsOneWidget);
  });

  testWidgets('hay un punto por escena y el primero está marcado', (
    tester,
  ) async {
    await openScenes(tester, count: 4);

    expect(dotSizes(tester), [10, 8, 8, 8]);
  });

  testWidgets('al deslizar pasa a la siguiente escena y mueve el punto', (
    tester,
  ) async {
    await openScenes(tester);

    await swipe(tester, forward: true);

    expect(find.text('Escena 2'), findsOneWidget);
    expect(find.text('Descripción de la escena 2'), findsOneWidget);
    expect(dotSizes(tester), [8, 10, 8]);

    await swipe(tester, forward: false);

    expect(find.text('Escena 1'), findsOneWidget);
    expect(dotSizes(tester), [10, 8, 8]);
  });

  testWidgets('en la última escena no avanza más', (tester) async {
    await openScenes(tester, count: 2);

    await swipe(tester, forward: true);
    await swipe(tester, forward: true);

    expect(find.text('Escena 2'), findsOneWidget);
    expect(dotSizes(tester), [8, 10]);
  });

  testWidgets('mientras carga la imagen muestra el indicador', (tester) async {
    final cache = FakeCacheManager(fails: false);
    addTearDown(cache.closePending);
    await pumpScreen(
      tester,
      ScenesCarouselScreen(topic: topicWithScenes(1), cacheManager: cache),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('si la imagen no carga muestra la imagen de reemplazo', (
    tester,
  ) async {
    await openScenes(tester, count: 1);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    final placeholder = find.byWidgetPredicate(
      (w) =>
          w is Image &&
          w.image is AssetImage &&
          (w.image as AssetImage).assetName == 'assets/images/placeholder.jpg',
    );
    expect(placeholder, findsOneWidget);
  });
}
