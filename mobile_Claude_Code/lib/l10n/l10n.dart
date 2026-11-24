import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api.dart';
import 'default_ui_es.dart';

/// Idioma de la app y textos de la interfaz.
///
/// Los textos vienen del backend (`/api/v1/ui?lang=xx` → `data/<lang>/ui.json`).
/// Orden de búsqueda: respuesta del backend → copia guardada → español
/// embebido ([defaultUiEs]) → la propia clave.
class L10n {
  L10n._();

  /// Códigos de idioma soportados y su nombre en su propio idioma.
  /// Para agregar uno: crear `backend/data/<código>/` y sumarlo aquí y en
  /// `supportedLangs` de `backend/main.go`.
  static const Map<String, String> languages = {
    'es': 'Español',
    'en': 'English',
    'pt': 'Português',
    'fr': 'Français',
    'de': 'Deutsch',
  };

  static const defaultLang = 'es';
  static const _prefKey = 'app_lang_v1';

  static String _lang = defaultLang;
  static Map<String, dynamic> _strings = defaultUiEs;

  /// Idioma activo.
  static String get lang => _lang;

  /// Lee el idioma guardado y carga sus textos. Se llama al abrir la app.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    _lang = languages.containsKey(saved) ? saved! : defaultLang;
    await _loadStrings();
  }

  /// Cambia el idioma, lo guarda y carga sus textos.
  static Future<void> setLanguage(String code) async {
    if (!languages.containsKey(code)) return;
    _lang = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, code);
    await _loadStrings();
  }

  static Future<void> _loadStrings() async {
    try {
      _strings = await ApiClient().fetchUi();
    } catch (_) {
      // Sin red ni copia guardada: queda el español embebido.
      _strings = defaultUiEs;
    }
  }

  /// Texto de [key]; cada `{nombre}` se reemplaza con [args].
  static String t(String key, [Map<String, Object?> args = const {}]) {
    final raw = _strings[key] ?? defaultUiEs[key];
    var s = raw is String ? raw : key;
    args.forEach((k, v) => s = s.replaceAll('{$k}', '$v'));
    return s;
  }

  /// Lista de [key] (p. ej. los segmentos del versículo del Home).
  static List<Map<String, dynamic>> segments(String key) {
    final raw = _strings[key] ?? defaultUiEs[key];
    if (raw is! List) return const [];
    return raw.whereType<Map<String, dynamic>>().toList();
  }

  /// Solo para tests: restablece el español.
  @visibleForTesting
  static void reset() {
    _lang = defaultLang;
    _strings = defaultUiEs;
  }

  static Map<String, dynamic> decode(String body) =>
      jsonDecode(body) as Map<String, dynamic>;
}
