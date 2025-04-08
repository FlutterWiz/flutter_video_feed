import 'package:video_player/video_player.dart';

/// A service that implements caching for VideoPlayerController instances
/// using a Least Recently Used (LRU) strategy.
///
/// This service manages the lifecycle and memory usage of VideoPlayerController
/// instances by maintaining a fixed-size cache using LRU eviction policy.
class VideoControllerCacheService {
  final int maxSize;
  final Map<String, VideoPlayerController> _cache = {};
  final List<String> _accessOrder = [];
  final Set<String> _disposingControllers = {};

  VideoControllerCacheService({this.maxSize = 5});

  VideoPlayerController? get(String id) {
    if (_cache.containsKey(id)) {
      _updateAccessOrder(id);
      return _cache[id];
    }
    return null;
  }

  void put(String id, VideoPlayerController controller) {
    if (_cache.length >= maxSize && !_cache.containsKey(id)) {
      _removeOldest();
    }
    _cache[id] = controller;
    _updateAccessOrder(id);
  }

  void _updateAccessOrder(String id) {
    _accessOrder.remove(id);
    _accessOrder.add(id);
  }

  Future<void> _removeOldest() async {
    if (_accessOrder.isNotEmpty) {
      final oldestId = _accessOrder.removeAt(0);
      await _disposeController(oldestId);
    }
  }

  Future<void> remove(String id) async {
    await _disposeController(id);
  }

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

  Future<void> clear() async {
    final ids = List.from(_cache.keys);
    for (final id in ids) {
      await _disposeController(id);
    }
  }

  bool contains(String id) => _cache.containsKey(id);

  int get length => _cache.length;

  Map<String, VideoPlayerController> get cache => _cache;

  /// Ensures only the current video is playing and others are paused
  Future<void> ensureOnlyCurrentPlaying(String currentId) async {
    for (final id in _cache.keys) {
      if (id != currentId) {
        final controller = _cache[id];
        if (controller != null && controller.value.isPlaying) {
          await controller.pause();
        }
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

  /// Checks if a controller is currently being disposed
  bool isDisposing(String id) => _disposingControllers.contains(id);
}
