import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/models.dart';
import 'package:mobile/screens/info_screen.dart';

import '../helpers.dart';

Future<void> openInfo(
  WidgetTester tester,
  Future<InfoContent> Function() load,
) async {
  await pumpScreen(
    tester,
    InfoScreen(
      title: 'Premios',
      load: load,
      icon: Icons.emoji_events_rounded,
      color: Colors.orange,
    ),
  );
  await waitForLoad(tester);
}

void main() {
  group('InfoContent.fromJson', () {
    test('lee título, subtítulo, texto y lista con las claves dadas', () {
      final info = InfoContent.fromJson(
        {
          'title': ' Premios ',
          'prayer': 'Lista de premios',
          'help': 'Texto',
          'awards': [
            {'award': 'Libro Animado'},
            {'award': ''},
            {'otra': 'se ignora'},
            {'award': 'Chocolatinas'},
          ],
        },
        subtitleKey: 'prayer',
        bodyKey: 'help',
        listKey: 'awards',
        itemKey: 'award',
      );

      expect(info.title, 'Premios');
      expect(info.subtitle, 'Lista de premios');
      expect(info.body, 'Texto');
      expect(info.items, ['Libro Animado', 'Chocolatinas']);
    });

    test('sin claves ni datos queda vacío', () {
      final info = InfoContent.fromJson({'awards': null}, listKey: 'awards');

      expect(info.title, '');
      expect(info.subtitle, '');
      expect(info.body, '');
      expect(info.items, isEmpty);
    });
  });

  group('InfoScreen', () {
    testWidgets('muestra el contenido', (tester) async {
      await openInfo(
        tester,
        () async => InfoContent(
          title: 'Sorpresas',
          subtitle: 'Lista de premios',
          body: 'Gana premios',
          items: ['Libro Animado', 'Chocolatinas'],
        ),
      );

      expect(find.widgetWithText(AppBar, 'Premios'), findsOneWidget);
      expect(find.byType(BackButton), findsNothing); // es la primera ruta
      for (final t in [
        'Sorpresas',
        'Lista de premios',
        'Gana premios',
        'Libro Animado',
        'Chocolatinas',
      ]) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
    });

    testWidgets('si falla, muestra el error y "Reintentar" vuelve a pedir', (
      tester,
    ) async {
      var calls = 0;
      await openInfo(tester, () async {
        calls++;
        if (calls == 1) throw Exception('sin red');
        return InfoContent(title: 'Sorpresas');
      });

      expect(find.text('No se pudo cargar el contenido.'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pump();
      await waitForLoad(tester);

      expect(calls, 2);
      expect(find.text('Sorpresas'), findsOneWidget);
    });
  });
}
