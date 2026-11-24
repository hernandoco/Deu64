import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/l10n/l10n.dart';

void main() {
  // Con el binding de test toda petición HTTP devuelve 400 (aunque haya un
  // backend real corriendo): ApiClient usa la caché.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    L10n.reset();
  });

  test('sin red ni caché usa el español embebido y reemplaza {args}', () async {
    await L10n.init();
    expect(L10n.lang, 'es');
    expect(L10n.t('quiz.next'), 'Siguiente');
    expect(L10n.t('result.score', {'score': 2, 'total': 3}), 'Puntos: 2/3');
  });

  test('una clave desconocida devuelve la propia clave', () {
    expect(L10n.t('no.existe'), 'no.existe');
  });

  test('setLanguage guarda el idioma y usa la caché de ese idioma', () async {
    SharedPreferences.setMockInitialValues({
      'cache_ui_v1_en': jsonEncode({'quiz.next': 'Next'}),
    });
    await L10n.setLanguage('en');
    expect(L10n.lang, 'en');
    expect(L10n.t('quiz.next'), 'Next');
    // clave que el archivo del idioma no trae: cae en español
    expect(L10n.t('quiz.prev'), 'Anterior');

    // al reabrir la app se recupera el idioma elegido
    L10n.reset();
    await L10n.init();
    expect(L10n.lang, 'en');
    expect(L10n.t('quiz.next'), 'Next');
  });

  test('un código no soportado se ignora', () async {
    await L10n.setLanguage('xx');
    expect(L10n.lang, 'es');
  });
}
