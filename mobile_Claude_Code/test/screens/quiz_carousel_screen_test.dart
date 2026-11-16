import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/screens/quiz_carousel_screen.dart';
import 'package:mobile/screens/result_screen.dart';

import '../helpers.dart';

Future<void> openQuiz(WidgetTester tester) async {
  await pumpScreen(tester, const QuizCarouselScreen(topicId: kTestTopicId));
  await waitForLoad(tester);
}

int? selectedOption(WidgetTester tester) =>
    tester.widget<RadioGroup<int>>(find.byType(RadioGroup<int>)).groupValue;

ElevatedButton button(WidgetTester tester, String label) =>
    tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, label));

void main() {
  testWidgets('muestra la primera pregunta con sus opciones', (tester) async {
    seedCache(questionsCache(kTwoQuestions));
    await openQuiz(tester);

    expect(find.text('Pregunta 1/2'), findsOneWidget);
    expect(find.text('¿Quién guió al pueblo?'), findsOneWidget);
    expect(find.text('Piensa en la historia de hoy'), findsOneWidget);
    expect(find.text('Moisés'), findsOneWidget);
    expect(find.text('Faraón'), findsOneWidget);
    expect(selectedOption(tester), isNull);
  });

  testWidgets('"Anterior" está desactivado en la primera pregunta', (
    tester,
  ) async {
    seedCache(questionsCache(kTwoQuestions));
    await openQuiz(tester);

    expect(button(tester, 'Anterior').onPressed, isNull);
    expect(button(tester, 'Siguiente').onPressed, isNotNull);
  });

  testWidgets('en la última pregunta el botón dice "Finalizar"', (
    tester,
  ) async {
    seedCache(questionsCache(kTwoQuestions));
    await openQuiz(tester);

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();

    expect(find.text('Pregunta 2/2'), findsOneWidget);
    expect(find.text('Finalizar'), findsOneWidget);
    expect(button(tester, 'Anterior').onPressed, isNotNull);
  });

  testWidgets('al volver atrás se conserva la respuesta elegida', (
    tester,
  ) async {
    seedCache(questionsCache(kTwoQuestions));
    await openQuiz(tester);

    await tester.tap(find.text('Faraón'));
    await tester.pump();
    expect(selectedOption(tester), 1);

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Anterior'));
    await tester.pumpAndSettle();

    expect(find.text('Pregunta 1/2'), findsOneWidget);
    expect(selectedOption(tester), 1);
  });

  testWidgets('cuenta solo las respuestas correctas en el resultado', (
    tester,
  ) async {
    seedCache(questionsCache(kTwoQuestions));
    await openQuiz(tester);

    await tester.tap(find.text('Moisés')); // correcta
    await tester.pump();
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cinco')); // incorrecta
    await tester.pump();
    await tester.tap(find.text('Finalizar'));
    await tester.pumpAndSettle();

    expect(find.byType(ResultScreen), findsOneWidget);
    expect(find.text('Puntos: 1/2'), findsOneWidget);
  });

  testWidgets('se puede finalizar sin responder (0 puntos)', (tester) async {
    seedCache(questionsCache(kTwoQuestions));
    await openQuiz(tester);

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finalizar'));
    await tester.pumpAndSettle();

    expect(find.text('Puntos: 0/2'), findsOneWidget);
  });

  testWidgets('una pregunta larga no se desborda y los botones se ven', (
    tester,
  ) async {
    // Pantalla baja, como la del error "RenderFlex overflowed by 76 pixels".
    tester.view.physicalSize = const Size(360, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    seedCache(
      questionsCache([
        question(1, 'Esta es una pregunta muy larga ' * 8, [
          for (var i = 1; i <= 6; i++) ('Opción número $i', i == 1),
        ], recommendation: 'Una recomendación también larga ' * 4),
      ]),
    );
    await openQuiz(tester);

    // Un desbordamiento haría fallar el test con una excepción de layout.
    expect(tester.takeException(), isNull);
    expect(find.text('Finalizar').hitTestable(), findsOneWidget);

    // Las últimas opciones se alcanzan con scroll.
    expect(find.text('Opción número 6').hitTestable(), findsNothing);
    await tester.dragUntilVisible(
      find.text('Opción número 6').hitTestable(),
      find.byType(ListView),
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();
    expect(find.text('Opción número 6').hitTestable(), findsOneWidget);
    await tester.tap(find.text('Opción número 6'));
    await tester.pump();
    expect(selectedOption(tester), 5);
  });

  testWidgets('avisa si el tema no tiene preguntas', (tester) async {
    seedCache(questionsCache([]));
    await openQuiz(tester);

    expect(find.text('No hay preguntas para este tema.'), findsOneWidget);
  });

  testWidgets('muestra el error si no hay red ni copia guardada', (
    tester,
  ) async {
    seedCache({});
    await openQuiz(tester);

    expect(find.text('Quiz'), findsOneWidget);
    expect(find.textContaining('preguntas_tema'), findsOneWidget);
  });
}
