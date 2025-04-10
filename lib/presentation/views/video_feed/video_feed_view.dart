import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_video_feed/domain/models/video_item.dart';
import 'package:flutter_video_feed/presentation/blocs/video_feed/video_feed_cubit.dart';
import 'package:flutter_video_feed/presentation/blocs/video_feed/video_feed_state.dart';
import 'package:flutter_video_feed/presentation/views/video_feed/widgets/video_feed_item.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:video_player/video_player.dart';

class VideoFeedView extends StatefulWidget {
  const VideoFeedView({Key? key}) : super(key: key);

  @override
  State<VideoFeedView> createState() => _VideoFeedViewState();
}

class _VideoFeedViewState extends State<VideoFeedView> with WidgetsBindingObserver {
  /// Maximum number of controllers to keep in cache
  final int _maxCacheSize = 3;

  /// The current videos to display
  List<VideoItem> _videos = [];

  /// Current visible page
  int _currentPage = 0;

  /// PageView controller
  final PreloadPageController _pageController = PreloadPageController();

  /// Whether the app is currently active
  bool _isAppActive = true;

  /// LRU cache of video controllers by video ID
  final Map<String, VideoPlayerController> _controllerCache = {};

  /// Ordered list of video IDs by most recently accessed
  final List<String> _accessOrder = [];

  /// Set of video IDs currently being disposed to prevent race conditions
  final Set<String> _disposingControllers = Set<String>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeFirstVideo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeAllControllers();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final wasActive = _isAppActive;
    _isAppActive = state == AppLifecycleState.resumed;

    if (_isAppActive && !wasActive) {
      // App has come back to foreground
      _cleanupAndReinitializeCurrentVideo();
    } else if (!_isAppActive && wasActive) {
      // App is going to background - pause all videos
      _pauseAllControllers();
    }
  }

  /// Initialize the first video when the view loads
  void _initializeFirstVideo() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = context.read<VideoFeedCubit>().state;
      if (state.videos.isNotEmpty) {
        setState(() => _videos = state.videos);

        await _initAndPlayVideo(0);
      }
    });
  }

  /// Clean up and reinitialize the current video when coming back from background
  Future<void> _cleanupAndReinitializeCurrentVideo() async {
    if (_videos.isEmpty || _currentPage >= _videos.length) return;

    await _pauseAllControllers();

    final videoId = _videos[_currentPage].id;
    final controller = _getController(videoId);

    // If controller exists but has errors, dispose it
    if (controller != null && (controller.value.hasError || !controller.value.isInitialized)) {
      await _removeController(videoId);
      await Future.delayed(const Duration(milliseconds: 50));
    }

    // Reinitialize and play current video
    await _initAndPlayVideo(_currentPage);
  }

  /// Initialize and play a video at the given index
  Future<void> _initAndPlayVideo(int index) async {
    if (_videos.isEmpty || index >= _videos.length) return;

    final video = _videos[index];
    await _getOrCreateController(video);
    await _playController(video.id);

    if (mounted) setState(() {});
  }

  /// Get a controller for a video ID if it exists in the cache
  VideoPlayerController? _getController(String videoId) {
    return _controllerCache[videoId];
  }

  /// Touch a controller to mark it as recently used
  void _touchController(String videoId) {
    _accessOrder.remove(videoId);
    _accessOrder.add(videoId);
  }

  /// Get or create a controller for a video
  Future<VideoPlayerController?> _getOrCreateController(VideoItem video) async {
    // Return the existing controller if available
    if (_controllerCache.containsKey(video.id)) {
      _touchController(video.id);
      return _controllerCache[video.id];
    }

    try {
      // Get cached file from the cubit
      final videoFile = await context.read<VideoFeedCubit>().getCachedVideoFile(video.videoUrl);

      // Create a new controller
      final controller = VideoPlayerController.file(videoFile);

      // Initialize the controller
      await controller.initialize();

      // Set looping
      controller.setLooping(true);

      // Add to cache and update access order
      _controllerCache[video.id] = controller;
      _touchController(video.id);

      // Enforce cache size limit
      _enforceCacheLimit();

      return controller;
    } catch (e) {
      debugPrint('Error initializing controller: $e');
      return null;
    }
  }

  /// Play a controller if it exists and is initialized
  Future<void> _playController(String videoId) async {
    final controller = _controllerCache[videoId];
    if (controller != null && controller.value.isInitialized && !controller.value.isPlaying) {
      try {
        await controller.play();
      } catch (e) {
        debugPrint('Error playing video: $e');
      }
    }
  }

  /// Pause all controllers
  Future<void> _pauseAllControllers() async {
    // Create a copy of the controllers to avoid concurrent modification
    final controllers = List<VideoPlayerController>.from(_controllerCache.values);

    for (final controller in controllers) {
      try {
        if (controller.value.isInitialized && controller.value.isPlaying) {
          await controller.pause();
          await controller.seekTo(Duration.zero);
        }
      } catch (e) {
        debugPrint('Error pausing video: $e');
      }
    }
  }

  /// Remove a controller from cache and dispose it
  Future<void> _removeController(String videoId) async {
    if (_disposingControllers.contains(videoId)) return;

    _disposingControllers.add(videoId);

    try {
      final controller = _controllerCache[videoId];
      if (controller != null) {
        // Remove from cache immediately
        _controllerCache.remove(videoId);
        _accessOrder.remove(videoId);

        // Pause and dispose
        try {
          if (controller.value.isInitialized) {
            await controller.pause();
          }
          await controller.dispose();
        } catch (e) {
          debugPrint('Error disposing controller: $e');
        }
      }
    } finally {
      _disposingControllers.remove(videoId);
    }
  }

  /// Enforce the cache size limit by removing least recently used controllers
  void _enforceCacheLimit() {
    // Only keep max number of controllers
    while (_controllerCache.length > _maxCacheSize && _accessOrder.isNotEmpty) {
      final oldestId = _accessOrder.first;
      _removeController(oldestId);
    }
  }

  /// Dispose all controllers
  Future<void> _disposeAllControllers() async {
    _pageController.dispose();

    final controllerIds = List<String>.from(_controllerCache.keys);
    for (final id in controllerIds) {
      await _removeController(id);
    }
    _controllerCache.clear();
    _accessOrder.clear();
  }

  /// Manage the window of controllers around the current page
  Future<void> _manageControllerWindow(int currentPage) async {
    if (_videos.isEmpty) return;

    // Define window of pages to keep
    final windowStart = (currentPage - 1).clamp(0, _videos.length - 1);
    final windowEnd = (currentPage + 1).clamp(0, _videos.length - 1);

    // Get IDs in window
    final idsToKeep = <String>{};
    for (int i = windowStart; i <= windowEnd; i++) {
      if (i < _videos.length) {
        idsToKeep.add(_videos[i].id);
      }
    }

    // Dispose controllers outside window
    final idsToDispose = _controllerCache.keys.where((id) => !idsToKeep.contains(id)).toList();
    for (final id in idsToDispose) {
      await _removeController(id);
    }

    // Initialize controllers in window, prioritizing current page
    if (currentPage < _videos.length) {
      // Current page first
      await _getOrCreateController(_videos[currentPage]);

      // Then previous page if in range
      if (windowStart < currentPage && windowStart >= 0) {
        await _getOrCreateController(_videos[windowStart]);
      }

      // Then next page if in range
      if (windowEnd > currentPage && windowEnd < _videos.length) {
        await _getOrCreateController(_videos[windowEnd]);
      }
    }
  }

  /// Handle page changes in the video feed
  Future<void> _handlePageChange(int newPage) async {
    if (_videos.isEmpty || newPage >= _videos.length) return;

    final previousPage = _currentPage;
    _currentPage = newPage;

    // For fast scrolling, be more aggressive
    final isFastScroll = (newPage - previousPage).abs() > 1;

    // First pause all videos
    await _pauseAllControllers();

    try {
      if (isFastScroll) {
        // In fast scroll, dispose all except target
        final videoId = _videos[newPage].id;
        final idsToDispose = List<String>.from(_controllerCache.keys);

        for (final id in idsToDispose) {
          if (id != videoId) {
            await _removeController(id);
          }
        }
      }

      // Manage the window controllers
      await _manageControllerWindow(newPage);

      // Play only the current video
      if (_videos.isNotEmpty && newPage < _videos.length) {
        await _initAndPlayVideo(newPage);
      }

      // Notify the cubit
      context.read<VideoFeedCubit>().onPageChanged(newPage);
    } catch (e) {
      debugPrint('Error handling page change: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: BlocListener<VideoFeedCubit, VideoFeedState>(
        listenWhen:
            (p, c) =>
                p.videos != c.videos || p.isLoading != c.isLoading || p.preloadedVideoUrls != c.preloadedVideoUrls,
        listener: (context, state) {
          setState(() => _videos = state.videos);
          _manageControllerWindow(_currentPage);
        },
        child: PreloadPageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          itemCount: _videos.length,
          physics: const AlwaysScrollableScrollPhysics(),
          onPageChanged: (index) => _handlePageChange(index),
          itemBuilder: (context, index) {
            return RepaintBoundary(
              child: VideoFeedItem(
                key: ValueKey(_videos[index].id),
                controller: _getController(_videos[index].id),
                videoItem: _videos[index],
              ),
            );
          },
        ),
      ),
    );
  }
}
