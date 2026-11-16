import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/screens/challenge_screen.dart';
import 'package:mobile/screens/prayer_screen.dart';
import 'package:mobile/screens/quiz_carousel_screen.dart';
import 'package:mobile/screens/result_screen.dart';
import 'package:mobile/screens/start_questions_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers.dart';

void main() {
  group('ResultScreen', () {
    testWidgets('muestra los puntos obtenidos', (tester) async {
      await pumpScreen(tester, const ResultScreen(score: 3, total: 5));

      expect(find.text('Resultado'), findsOneWidget);
      expect(find.text('Puntos: 3/5'), findsOneWidget);
    });
  });

  group('StartQuestionsScreen', () {
    testWidgets('el botón PREGUNTAS abre el quiz del tema', (tester) async {
      seedCache(questionsCache(kTwoQuestions));
      await pumpScreen(
        tester,
        const StartQuestionsScreen(topicId: kTestTopicId),
      );

      await tester.tap(find.text('PREGUNTAS'));
      await tester.pump();
      await waitForLoad(tester);

      expect(find.byType(StartQuestionsScreen), findsNothing);
      expect(find.byType(QuizCarouselScreen), findsOneWidget);
      expect(find.text('Pregunta 1/2'), findsOneWidget);
    });
  });

  group('PrayerScreen', () {
    final prayerJson = jsonEncode({
      'topicId': kTestTopicId,
      'title': 'Oración del día',
      'prayer': 'Señor, gracias por este día.',
      'verses': [
        {'verse': 'Salmo 23:1'},
        {'verse': 'Juan 3:16'},
      ],
    });

    testWidgets('muestra la oración y los versículos de apoyo', (tester) async {
      seedCache({kPrayerCacheKey: prayerJson});
      await pumpScreen(tester, const PrayerScreen());
      await waitForLoad(tester);

      expect(find.text('Oración modelo'), findsOneWidget);
      expect(find.text('Oración del día'), findsOneWidget);
      expect(find.text('Señor, gracias por este día.'), findsOneWidget);
      expect(find.text('Versículos de apoyo'), findsOneWidget);
      expect(find.text('Salmo 23:1'), findsOneWidget);
      expect(find.text('Juan 3:16'), findsOneWidget);
    });

    testWidgets('sin versículos no muestra esa sección', (tester) async {
      seedCache({
        kPrayerCacheKey: jsonEncode({'title': 'Oración', 'prayer': 'Amén'}),
      });
      await pumpScreen(tester, const PrayerScreen());
      await waitForLoad(tester);

      expect(find.text('Amén'), findsOneWidget);
      expect(find.text('Versículos de apoyo'), findsNothing);
    });

    testWidgets('si falla la carga, "Reintentar" vuelve a intentarlo', (
      tester,
    ) async {
      seedCache({});
      await pumpScreen(tester, const PrayerScreen());
      await waitForLoad(tester);

      expect(find.text('No se pudo cargar la oración.'), findsOneWidget);

      // Ahora hay una copia guardada: el reintento debe mostrarla.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kPrayerCacheKey, prayerJson);
      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      await waitForLoad(tester);

      expect(find.text('Oración del día'), findsOneWidget);
    });
  });

  group('ChallengeScreen', () {
    testWidgets('muestra el reto y cada desafío con su consejo', (
      tester,
    ) async {
      seedCache({
        kChallengeCacheKey: jsonEncode({
          'title': 'Reto de la semana',
          'description': 'Haz algo bueno por alguien.',
          'listChallenge': [
            {'challenge': 'Ayuda en casa', 'tips': 'Pregunta qué falta'},
            {'challenge': 'Comparte un juguete', 'tips': ''},
          ],
        }),
      });
      await pumpScreen(tester, const ChallengeScreen());
      await waitForLoad(tester);

      expect(find.text('Reto del día'), findsOneWidget);
      expect(find.text('Reto de la semana'), findsOneWidget);
      expect(find.text('Haz algo bueno por alguien.'), findsOneWidget);
      expect(find.text('Ayuda en casa'), findsOneWidget);
      expect(find.text('Pregunta qué falta'), findsOneWidget);
      expect(find.text('Comparte un juguete'), findsOneWidget);
    });

    testWidgets('si falla la carga, "Reintentar" vuelve a intentarlo', (
      tester,
    ) async {
      seedCache({});
      await pumpScreen(tester, const ChallengeScreen());
      await waitForLoad(tester);

      expect(find.text('No se pudo cargar el reto.'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        kChallengeCacheKey,
        jsonEncode({'title': 'Reto de la semana', 'listChallenge': []}),
      );
      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      await waitForLoad(tester);

      expect(find.text('Reto de la semana'), findsOneWidget);
    });
  });
}
