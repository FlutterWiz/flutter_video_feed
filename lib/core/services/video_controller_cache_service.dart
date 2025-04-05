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
    final controller = _cache[id];
    if (controller != null) {
      await controller.pause();
      await controller.dispose();
      _cache.remove(id);
    }
    _accessOrder.remove(id);
  }

  Future<void> clear() async {
    for (final id in List.from(_cache.keys)) {
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
        await _cache[id]?.pause();
      }
    }
  }

  /// Pauses all videos
  Future<void> pauseAll() async {
    for (final controller in _cache.values) {
      await controller.pause();
    }
  }
}
