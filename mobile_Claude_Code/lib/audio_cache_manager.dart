import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Caché del mensaje de voz del día. Se renueva cada día; si no hay red se
/// usa la última copia guardada aunque esté vencida.
final audioCacheManager = CacheManager(
  Config(
    'audioMessageCacheV1',
    stalePeriod: const Duration(days: 1),
    maxNrOfCacheObjects: 5,
  ),
);

/// Devuelve el archivo local del audio: lo descarga si no existe o ya venció.
/// Si la descarga falla, usa la copia vencida. Null si no hay nada guardado.
Future<File?> getAudioFile(String url) async {
  try {
    return await audioCacheManager
        .getSingleFile(url)
        .timeout(const Duration(seconds: 20));
  } catch (_) {
    final cached = await audioCacheManager.getFileFromCache(url);
    return cached?.file;
  }
}
