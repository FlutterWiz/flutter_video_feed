import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_video_feed/domain/models/video_item.dart';
import 'package:video_player/video_player.dart';

/// Manages video playback, initialization, lifecycle, and caching for the video feed.
/// Implements LRU (Least Recently Used) caching to efficiently manage video controllers.
class VideoFeedService {
  final int maxCacheSize;

  final Map<String, VideoPlayerController> _controllerCache = {};
  final List<String> _accessOrder = [];
  final Set<String> _disposingControllers = {};
  bool _isAppActive = true;

  VideoFeedService({this.maxCacheSize = 5});

  bool get isAppActive => _isAppActive;
  set isAppActive(bool value) => _isAppActive = value;

  /// Gets a controller from cache and updates its access order
  VideoPlayerController? getController(String id) {
    if (!_controllerCache.containsKey(id)) return null;
    _updateAccessOrder(id);
    return _controllerCache[id];
  }

  /// Initializes the first video in the feed
  Future<void> initializeFirstVideo(List<VideoItem> videos, Future<File> Function(String) getCachedVideoFile) async {
    if (videos.isNotEmpty) {
      await initializeController(videos.first, getCachedVideoFile);
    }
  }

  /// Plays the current video if conditions are met
  Future<void> playCurrentVideo(List<VideoItem> videos, int currentPage) async {
    if (videos.isEmpty || currentPage >= videos.length || !_isAppActive) return;

    final currentVideo = videos[currentPage];
    final controller = getController(currentVideo.id);

    if (controller != null) {
      await ensureOnlyCurrentPlaying(currentVideo.id);
      if (_isAppActive && !controller.value.isPlaying) {
        await controller.play();
      }
    }
  }

  /// Initializes a video controller with proper error handling and lifecycle management
  Future<void> initializeController(VideoItem video, Future<File> Function(String) getCachedVideoFile) async {
    if (_controllerCache.containsKey(video.id) || _disposingControllers.contains(video.id)) return;

    try {
      final file = await getCachedVideoFile(video.videoUrl);
      final controller = VideoPlayerController.file(file);

      await Future.wait([controller.initialize(), Future.delayed(const Duration(milliseconds: 100))]);

      controller.setLooping(true);
      _addToCache(video.id, controller);
    } catch (e) {
      debugPrint('Error initializing controller for video ${video.id}: $e');
    }
  }

  /// Manages the window of active video controllers
  Future<void> manageControllerWindow(
    List<VideoItem> videos,
    int currentPage,
    Future<File> Function(String) getCachedVideoFile,
  ) async {
    if (videos.isEmpty) return;

    // Calculate the window of videos to keep active
    final windowIndices = <int>{
      if (currentPage > 0) currentPage - 1,
      currentPage,
      if (currentPage < videos.length - 1) currentPage + 1,
    };

    // Initialize controllers within the window
    for (final index in windowIndices) {
      if (index >= 0 && index < videos.length) {
        await initializeController(videos[index], getCachedVideoFile);
      }
    }

    // Get IDs that should be kept
    final idsToKeep = windowIndices.where((i) => i >= 0 && i < videos.length).map((i) => videos[i].id).toSet();

    // Remove controllers outside the window
    final currentIds = Set.from(_controllerCache.keys);
    for (final id in currentIds) {
      if (!idsToKeep.contains(id) && !_disposingControllers.contains(id)) {
        await _disposeController(id);
      }
    }
  }

  /// Handles page changes in the video feed
  Future<void> handlePageChange(
    List<VideoItem> videos,
    int previousPage,
    int newPage,
    Future<File> Function(String) getCachedVideoFile,
    void Function(int) onPageChanged,
  ) async {
    // Pause the previous video if it exists and is playing
    if (previousPage < videos.length) {
      final previousVideo = videos[previousPage];
      final controller = getController(previousVideo.id);
      if (controller?.value.isPlaying ?? false) {
        await controller?.pause();
      }
    }

    // Manage the controller window and play the new video
    await manageControllerWindow(videos, newPage, getCachedVideoFile);
    await playCurrentVideo(videos, newPage);

    // Notify the page change
    onPageChanged(newPage);
  }

  /// Ensures only the current video is playing
  Future<void> ensureOnlyCurrentPlaying(String currentId) async {
    final entries = List.from(_controllerCache.entries);
    for (final entry in entries) {
      if (entry.key != currentId) {
        final controller = entry.value;
        if (controller.value.isPlaying) {
          await controller.pause();
        }
      }
    }
  }

  /// Pauses all videos in the cache
  Future<void> pauseAll() async {
    final controllers = List.from(_controllerCache.values);
    for (final controller in controllers) {
      if (controller.value.isPlaying) {
        await controller.pause();
      }
    }
  }

  /// Adds a controller to cache, managing LRU eviction if needed
  void _addToCache(String id, VideoPlayerController controller) {
    if (_controllerCache.length >= maxCacheSize && !_controllerCache.containsKey(id)) {
      _removeLeastRecentlyUsed();
    }

    _controllerCache[id] = controller;
    _updateAccessOrder(id);
  }

  /// Updates the access order for LRU cache management
  void _updateAccessOrder(String id) {
    _accessOrder.remove(id);
    _accessOrder.add(id);
  }

  /// Removes the least recently used controller
  Future<void> _removeLeastRecentlyUsed() async {
    if (_accessOrder.isEmpty) return;

    final id = _accessOrder.first;
    await _disposeController(id);
  }

  /// Disposes a controller and removes it from cache
  Future<void> _disposeController(String id) async {
    if (_disposingControllers.contains(id)) return;

    _disposingControllers.add(id);

    try {
      final controller = _controllerCache[id];
      if (controller != null) {
        if (controller.value.isPlaying) {
          await controller.pause();
        }
        await controller.dispose();
        _controllerCache.remove(id);
        _accessOrder.remove(id);
      }
    } finally {
      _disposingControllers.remove(id);
    }
  }

  /// Cleans up resources when the feed is disposed
  Future<void> dispose() async {
    await pauseAll();
    final ids = List.from(_controllerCache.keys);
    for (final id in ids) {
      await _disposeController(id);
    }
  }
}
