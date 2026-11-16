import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/models.dart';
import 'package:mobile/screens/challenge_screen.dart';
import 'package:mobile/screens/home_screen.dart';
import 'package:mobile/screens/prayer_screen.dart';
import 'package:mobile/screens/quiz_carousel_screen.dart';
import 'package:mobile/screens/scenes_carousel_screen.dart';

import '../helpers.dart';

const kVerseCacheKey = 'cache_verse_v1';
const kAudioCacheKey = 'cache_audio_v1';

final kTopic = TopicResponse.fromJson({
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

final kVerseJson = jsonEncode({
  'topicId': kTestTopicId,
  'verse': 'Juan 3:16',
  'description': 'Porque de tal manera amó Dios al mundo',
});

/// Audio sin URL: el título se muestra, pero no hay nada que reproducir
/// (la reproducción real necesita just_audio, que no existe en los tests).
final kAudioJson = jsonEncode({
  'topicId': kTestTopicId,
  'title': 'Dios cuida de ti',
  'audio_url': '',
});

/// Abre el Home en una pantalla de teléfono, con la caché dada.
Future<void> openHome(WidgetTester tester, Map<String, Object> cache) async {
  tester.view.physicalSize = const Size(412, 915);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  seedCache(cache);
  await pumpScreen(
    tester,
    HomeScreen(topic: kTopic, imageCacheManager: FakeCacheManager(fails: true)),
  );
  await waitForLoad(tester);
}

/// Desliza el Home hasta [finder] y lo toca.
Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump();
  await waitForLoad(tester);
}

Future<void> goBack(WidgetTester tester) async {
  await tester.pageBack();
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    imageCache.clear();
    imageCache.clearLiveImages();
  });

  group('contenido', () {
    testWidgets('muestra el título principal y la cita', (tester) async {
      await openHome(tester, {});

      expect(
        find.textContaining('palabras', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('Deu 6:4'), findsOneWidget);
    });

    testWidgets('muestra el menú y la barra inferior', (tester) async {
      await openHome(tester, {});

      for (final label in ['Devocional', 'Ayuda', 'Premios', 'Donación']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Enseñanzas'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
    });

    testWidgets('muestra las 4 secciones con el tema del día', (tester) async {
      await openHome(tester, {});

      for (final title in [
        'Devocional de hoy',
        'Preguntas del devocional',
        'Oración modelo',
        'Reto del día',
      ]) {
        expect(find.text(title), findsOneWidget, reason: title);
      }
      expect(find.text('Detrás del corazón de Dios'), findsNWidgets(4));
      expect(find.text('3 escenas'), findsOneWidget);
      expect(find.text('Responde y gana puntos'), findsOneWidget);
      expect(find.text('Ora junto con el pastor'), findsOneWidget);
      expect(find.text('Un pequeño desafío para hoy'), findsOneWidget);
    });

    testWidgets('muestra el versículo del día', (tester) async {
      await openHome(tester, {kVerseCacheKey: kVerseJson});

      expect(find.text('Versículo del día:'), findsOneWidget);
      expect(find.text('Juan 3:16'), findsOneWidget);
      expect(
        find.text('Porque de tal manera amó Dios al mundo'),
        findsOneWidget,
      );
    });

    testWidgets('sin versículo muestra "..."', (tester) async {
      await openHome(tester, {});

      expect(find.text('...'), findsOneWidget);
    });

    testWidgets('muestra el título del mensaje de hoy', (tester) async {
      await openHome(tester, {kAudioCacheKey: kAudioJson});

      expect(find.text('Mensaje de hoy'), findsOneWidget);
      expect(find.text('Dios cuida de ti'), findsOneWidget);
    });

    testWidgets('sin mensaje muestra "Toca para escuchar"', (tester) async {
      await openHome(tester, {});

      expect(find.text('Toca para escuchar'), findsOneWidget);
    });
  });

  group('mensaje de voz', () {
    testWidgets('sin audio, el botón avisa que no está disponible', (
      tester,
    ) async {
      await openHome(tester, {});

      await tester.tap(find.byTooltip('Escuchar mensaje'));
      await tester.pump();
      await waitForLoad(tester);

      expect(
        find.text('El mensaje de hoy aún no está disponible.'),
        findsOneWidget,
      );
    });

    testWidgets('un audio sin URL también avisa que no está disponible', (
      tester,
    ) async {
      await openHome(tester, {kAudioCacheKey: kAudioJson});

      await tester.tap(find.byTooltip('Escuchar mensaje'));
      await tester.pump();
      await waitForLoad(tester);

      expect(
        find.text('El mensaje de hoy aún no está disponible.'),
        findsOneWidget,
      );
    });
  });

  group('navegación', () {
    testWidgets('el menú Devocional abre las escenas y se puede volver', (
      tester,
    ) async {
      await openHome(tester, {});

      await scrollAndTap(tester, find.text('Devocional'));

      expect(find.byType(ScenesCarouselScreen), findsOneWidget);
      expect(find.text('Escena 1'), findsOneWidget);

      await goBack(tester);
      expect(find.byType(ScenesCarouselScreen), findsNothing);
      expect(find.text('Devocional de hoy'), findsOneWidget);
    });

    testWidgets('la tarjeta del devocional abre las escenas', (tester) async {
      await openHome(tester, {});

      await scrollAndTap(tester, find.byTooltip('Abrir devocional'));

      expect(find.byType(ScenesCarouselScreen), findsOneWidget);
    });

    testWidgets('la tarjeta de preguntas abre el quiz del tema', (
      tester,
    ) async {
      await openHome(tester, questionsCache(kTwoQuestions));

      await scrollAndTap(tester, find.byTooltip('Abrir preguntas'));

      expect(find.byType(QuizCarouselScreen), findsOneWidget);
      expect(find.text('Pregunta 1/2'), findsOneWidget);
    });

    testWidgets('la tarjeta de oración abre la oración modelo', (tester) async {
      await openHome(tester, {});

      await scrollAndTap(tester, find.byTooltip('Abrir oración modelo'));

      expect(find.byType(PrayerScreen), findsOneWidget);
    });

    testWidgets('la tarjeta del reto abre el reto del día', (tester) async {
      await openHome(tester, {});

      await scrollAndTap(tester, find.byTooltip('Abrir reto del día'));

      expect(find.byType(ChallengeScreen), findsOneWidget);
    });

    for (final item in ['Ayuda', 'Premios', 'Donación']) {
      testWidgets('el menú $item abre "Próximamente" y se puede volver', (
        tester,
      ) async {
        await openHome(tester, {});

        await scrollAndTap(tester, find.text(item));

        expect(find.widgetWithText(AppBar, item), findsOneWidget);
        expect(find.text('Próximamente'), findsOneWidget);

        await goBack(tester);
        expect(find.text('Próximamente'), findsNothing);
      });
    }

    for (final tab in ['Enseñanzas', 'Perfil']) {
      testWidgets('la pestaña $tab muestra "Próximamente"', (tester) async {
        await openHome(tester, {});

        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();

        // El título de la pestaña más su etiqueta en la barra inferior.
        expect(find.text(tab), findsNWidgets(2));
        expect(find.text('Próximamente').hitTestable(), findsOneWidget);
        expect(find.text('Devocional de hoy').hitTestable(), findsNothing);

        await tester.tap(find.text('Home'));
        await tester.pumpAndSettle();
        expect(find.text('Devocional de hoy'), findsOneWidget);
      });
    }
  });
}
