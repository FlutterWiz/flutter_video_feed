import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_video_feed/domain/models/video_item.dart';
import 'package:flutter_video_feed/presentation/blocs/video_feed/video_feed_cubit.dart';
import 'package:flutter_video_feed/presentation/blocs/video_feed/video_feed_state.dart';
import 'package:flutter_video_feed/presentation/views/video_feed/widgets/video_feed_item.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:video_player/video_player.dart';

/// Main view for the video feed
class VideoFeedView extends StatefulWidget {
  const VideoFeedView({Key? key}) : super(key: key);

  @override
  State<VideoFeedView> createState() => _VideoFeedViewState();
}

class _VideoFeedViewState extends State<VideoFeedView> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  late final PreloadPageController _pageController;

  // Video controller cache and management
  final Map<String, VideoPlayerController> _controllerCache = {};
  final List<String> _accessOrder = [];
  final Set<String> _disposingControllers = {};
  bool _isAppActive = true;
  final int _maxCacheSize = 3;

  List<VideoItem> _videos = [];
  int _currentPage = 0;

  @override
  bool get wantKeepAlive => false; // Don't keep alive to ensure proper cleanup

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PreloadPageController(initialPage: _currentPage);
    _initializeFirstVideo();
  }

  void _initializeFirstVideo() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = context.read<VideoFeedCubit>().state;
      if (state.videos.isNotEmpty) {
        setState(() => _videos = state.videos);
        await initializeFirstVideo(_videos, context.read<VideoFeedCubit>().getCachedVideoFile);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Clean up all resources
    disposeAllControllers();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    // Widget is about to be removed from the tree
    // Pause all videos and reset positions
    pauseAll();
    super.deactivate();
  }

  // VIDEO CONTROLLER MANAGEMENT METHODS

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

      // Initialize with timeout
      await controller.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Video initialization timed out: ${video.id}');
          throw Exception('Timeout');
        },
      );

      controller.setLooping(true);
      _addToCache(video.id, controller);
    } catch (e) {
      debugPrint('Error initializing video ${video.id}: $e');
      _disposingControllers.remove(video.id);
    }
  }

  /// Manages the window of active video controllers
  Future<void> manageControllerWindow(
    List<VideoItem> videos,
    int currentPage,
    Future<File> Function(String) getCachedVideoFile,
  ) async {
    if (videos.isEmpty) return;

    // Calculate the window of videos to keep active (current and adjacent)
    final windowIndices = <int>{
      if (currentPage > 0) currentPage - 1, // Previous
      currentPage,                           // Current
      if (currentPage < videos.length - 1) currentPage + 1, // Next
    };

    // Get IDs that should be kept in the active window
    final idsToKeep = windowIndices
        .where((i) => i >= 0 && i < videos.length)
        .map((i) => videos[i].id)
        .toSet();

    // First, dispose controllers outside the window to free resources
    final currentIds = Set.from(_controllerCache.keys);
    for (final id in currentIds) {
      if (!idsToKeep.contains(id) && !_disposingControllers.contains(id)) {
        await _disposeController(id);
      }
    }

    // Then initialize controllers within the window, prioritizing current page
    if (currentPage < videos.length) {
      // First initialize current page
      await initializeController(videos[currentPage], getCachedVideoFile);
      
      // Then initialize adjacent pages if we still have room in the cache
      if (_controllerCache.length < _maxCacheSize) {
        // Initialize previous page if it exists
        if (currentPage > 0) {
          await initializeController(videos[currentPage - 1], getCachedVideoFile);
        }
        
        // Initialize next page if it exists and we still have room
        if (_controllerCache.length < _maxCacheSize && currentPage < videos.length - 1) {
          await initializeController(videos[currentPage + 1], getCachedVideoFile);
        }
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
    // Emergency stop - immediately pause all videos
    final controllers = List.from(_controllerCache.values);
    for (final controller in controllers) {
      try {
        if (controller.value.isInitialized) {
          // Immediately pause without waiting for async completion
          controller.pause();
        }
      } catch (e) {
        // Ignore errors during emergency stop
      }
    }
    
    // For fast scrolling, dispose ALL controllers except target
    final isFastScroll = (newPage - previousPage).abs() > 1;
    if (isFastScroll) {
      // Keep only the controller for the new page
      final keepId = newPage < videos.length ? videos[newPage].id : null;
      
      // Dispose all other controllers
      final idsToDispose = List.from(_controllerCache.keys.where((id) => id != keepId));
      for (final id in idsToDispose) {
        await _disposeController(id);
      }
      
      // Short delay to ensure disposal completes
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // Manage controllers and play new video
    await manageControllerWindow(videos, newPage, getCachedVideoFile);
    
    // Short delay before playing to avoid audio issues
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Play the current video only
    await playCurrentVideo(videos, newPage);

    // Notify page change
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
      try {
        if (controller.value.isInitialized) {
          // Pause playback
          await controller.pause();
          
          // Reset position to beginning
          await controller.seekTo(Duration.zero);
        }
      } catch (e) {
        debugPrint('Error pausing video: $e');
      }
    }
  }

  /// Adds a controller to cache, managing LRU eviction if needed
  void _addToCache(String id, VideoPlayerController controller) {
    if (_controllerCache.length >= _maxCacheSize && !_controllerCache.containsKey(id)) {
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
        // Properly pause playback
        try {
          await controller.pause();
        } catch (e) {
          // Ignore pause errors
        }
        
        // Dispose the controller
        try {
          await controller.dispose();
        } catch (e) {
          debugPrint('Error disposing controller: $e');
        }
        
        // Remove from cache even if dispose fails
        _controllerCache.remove(id);
        _accessOrder.remove(id);
      }
    } finally {
      _disposingControllers.remove(id);
    }
  }

  /// Cleans up resources when the feed is disposed
  Future<void> disposeAllControllers() async {
    // First pause all players
    await pauseAll();
    
    // Then dispose all controllers
    final ids = List.from(_controllerCache.keys);
    for (final id in ids) {
      await _disposeController(id);
    }
    
    // Clear all caches to prevent memory leaks
    _controllerCache.clear();
    _accessOrder.clear();
    _disposingControllers.clear();
    
    debugPrint('Video feed: All controllers disposed');
  }

  /// Reinitializes the video controller when coming back from background
  Future<void> _reinitializeCurrentVideo() async {
    if (_videos.isEmpty || _currentPage >= _videos.length) return;

    final currentVideo = _videos[_currentPage];
    final controller = getController(currentVideo.id);

    // If controller is missing or not initialized, create a new one
    if (controller == null || !controller.value.isInitialized) {
      await initializeController(currentVideo, context.read<VideoFeedCubit>().getCachedVideoFile);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppActive = state == AppLifecycleState.resumed;
    
    if (_isAppActive) {
      // App has come back to foreground
      _reinitializeCurrentVideo().then((_) {
        playCurrentVideo(_videos, _currentPage);
      });
    } else {
      // App is going to background
      pauseAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return RepaintBoundary(
      child: BlocListener<VideoFeedCubit, VideoFeedState>(
        listenWhen:
            (p, c) =>
                p.videos != c.videos || p.isLoading != c.isLoading || p.preloadedVideoUrls != c.preloadedVideoUrls,
        listener: (context, state) {
          setState(() => _videos = state.videos);
          manageControllerWindow(_videos, _currentPage, context.read<VideoFeedCubit>().getCachedVideoFile);
        },
        child: PreloadPageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          itemCount: _videos.length,
          physics: const AlwaysScrollableScrollPhysics(),
          onPageChanged: (newIndex) async {
            final previousPage = _currentPage;
            _currentPage = newIndex;
            await handlePageChange(
              _videos,
              previousPage,
              newIndex,
              context.read<VideoFeedCubit>().getCachedVideoFile,
              context.read<VideoFeedCubit>().onPageChanged,
            );
          },
          itemBuilder: (context, index) {
            return RepaintBoundary(
              child: VideoFeedItem(
                key: ValueKey(_videos[index].id),
                controller: getController(_videos[index].id),
                videoItem: _videos[index],
              ),
            );
          },
        ),
      ),
    );
  }
}
