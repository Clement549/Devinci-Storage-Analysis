import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class Manager{

  static final customCacheManager = CacheManager(
    Config(
      "customCacheKey",
      stalePeriod: const Duration(hours: 2),
      maxNrOfCacheObjects: 50,
      ),
    );
}