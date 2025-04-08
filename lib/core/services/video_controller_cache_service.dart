import 'package:video_player/video_player.dart';

/// A service that manages VideoPlayerController instances with LRU caching.
/// LRU (Least Recently Used) ensures we keep the most recently accessed controllers
/// and remove the least recently used ones when the cache is full.
class VideoControllerCacheService {
  final int maxSize;
  final Map<String, VideoPlayerController> _cache = {};
  final List<String> _accessOrder = [];
  final Set<String> _disposingControllers = {};

  VideoControllerCacheService({this.maxSize = 5});

  /// Checks if a controller exists in cache
  bool contains(String id) => _cache.containsKey(id);

  /// Gets the IDs of cached controllers
  Set<String> get cachedIds => Set.from(_cache.keys);

  /// Checks if a controller is being disposed
  bool isDisposing(String id) => _disposingControllers.contains(id);

  /// Gets a controller from cache and updates its access order
  VideoPlayerController? get(String id) {
    if (!_cache.containsKey(id)) return null;

    _updateAccessOrder(id);
    return _cache[id];
  }

  /// Adds a controller to cache, removing least recently used if full
  void put(String id, VideoPlayerController controller) {
    if (_cache.length >= maxSize && !_cache.containsKey(id)) {
      _removeLeastRecentlyUsed();
    }

    _cache[id] = controller;
    _updateAccessOrder(id);
  }

  /// Removes a specific controller
  Future<void> remove(String id) async {
    await _disposeController(id);
  }

  /// Clears all controllers from cache
  Future<void> clear() async {
    final ids = List.from(_cache.keys);

    for (final id in ids) {
      await _disposeController(id);
    }
  }

  /// Ensures only the current video is playing
  Future<void> ensureOnlyCurrentPlaying(String currentId) async {
    for (final entry in _cache.entries) {
      if (entry.key != currentId && entry.value.value.isPlaying) {
        await entry.value.pause();
      }
    }
  }

  /// Pauses all videos
  Future<void> pauseAll() async {
    for (final controller in _cache.values) {
      if (controller.value.isPlaying) {
        await controller.pause();
      }
    }
  }

  /// Updates the access order by moving the id to the end of the list
  void _updateAccessOrder(String id) {
    _accessOrder.remove(id);
    _accessOrder.add(id);
  }

  /// Removes the least recently used controller
  Future<void> _removeLeastRecentlyUsed() async {
    if (_accessOrder.isEmpty) return;

    await _disposeController(_accessOrder.removeAt(0));
  }

  /// Disposes a controller and removes it from cache
  Future<void> _disposeController(String id) async {
    if (_disposingControllers.contains(id)) return;

    _disposingControllers.add(id);

    try {
      final controller = _cache[id];

      if (controller != null) {
        await controller.pause();
        await controller.dispose();
        _cache.remove(id);
      }
      _accessOrder.remove(id);
    } finally {
      _disposingControllers.remove(id);
    }
  }
}
