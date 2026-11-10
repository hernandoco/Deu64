import 'package:flutter_cache_manager/flutter_cache_manager.dart';

final sceneImagesCacheManager = CacheManager(
  Config(
    'sceneImagesCacheV1',
    stalePeriod: const Duration(days: 30),
    maxNrOfCacheObjects: 500,
  ),
);