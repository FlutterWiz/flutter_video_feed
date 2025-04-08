import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_video_feed/domain/models/video_item.dart';
import 'package:flutter_video_feed/core/services/video_controller_cache_service.dart';
import 'package:flutter_video_feed/presentation/blocs/video_feed/video_feed_cubit.dart';
import 'package:flutter_video_feed/presentation/blocs/video_feed/video_feed_state.dart';
import 'package:flutter_video_feed/presentation/views/video_feed/widgets/video_feed_item.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_video_feed/core/di/dependency_injector.dart';

class VideoFeedView extends StatefulWidget {
  const VideoFeedView({Key? key}) : super(key: key);

  @override
  State<VideoFeedView> createState() => _VideoFeedViewState();
}

class _VideoFeedViewState extends State<VideoFeedView> with WidgetsBindingObserver {
  late final VideoControllerCacheService _controllers;
  late final PreloadPageController _pageController;

  List<VideoItem> _videos = [];
  int _currentPage = 0;
  bool _isAppActive = true;

  @override
  void initState() {
    super.initState();
    _controllers = getIt<VideoControllerCacheService>();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PreloadPageController(initialPage: _currentPage);
    _initializeFirstVideo();
  }

  void _initializeFirstVideo() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<VideoFeedCubit>().state;
      if (state.videos.isNotEmpty) {
        setState(() => _videos = state.videos);
        _initializeController(_videos.first);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cleanupResources();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _cleanupResources() async {
    await _controllers.pauseAll();
    await _controllers.clear();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppActive = state == AppLifecycleState.resumed;

    if (_isAppActive) {
      _playCurrentVideo();
    } else {
      _pauseAllVideos();
    }
  }

  Future<void> _pauseAllVideos() async {
    await _controllers.pauseAll();
  }

  Future<void> _playCurrentVideo() async {
    if (_videos.isEmpty || _currentPage >= _videos.length) return;

    final currentVideo = _videos[_currentPage];
    final controller = _controllers.get(currentVideo.id);
    if (controller != null && _isAppActive) {
      await _controllers.ensureOnlyCurrentPlaying(currentVideo.id);
      await controller.play();
    }
  }

  Future<void> _initializeController(VideoItem video) async {
    if (!_controllers.contains(video.id)) {
      try {
        final file = await context.read<VideoFeedCubit>().getCachedVideoFile(video.videoUrl);
        final controller = VideoPlayerController.file(file);
        await controller.initialize();
        controller.setLooping(true);

        if (!mounted) return;

        _controllers.put(video.id, controller);
        await _manageControllerMemory();

        if (mounted) setState(() {});

        if (_isAppActive && _currentPage == _videos.indexOf(video)) {
          await _playCurrentVideo();
        }
      } catch (e) {
        debugPrint('Error initializing controller: $e');
      }
    }
  }

  Future<void> _manageControllerMemory() async {
    final currentIds = Set.from(_controllers.cache.keys);

    /// Maximum number of video controllers to keep in memory we select is 3.
    /// It represents the current video + 1 before + 1 after => in total 3.
    if (currentIds.length > 3) {
      final idsToRemove = currentIds.where(
        (id) =>
            _videos.indexOf(_videos.firstWhere((v) => v.id == id)) < _currentPage - 1 ||
            _videos.indexOf(_videos.firstWhere((v) => v.id == id)) > _currentPage + 1,
      );

      for (final id in idsToRemove) {
        if (!_controllers.isDisposing(id)) {
          await _controllers.remove(id);
        }
      }
    }
  }

  Future<void> _ensureControllersForWindow() async {
    if (_videos.isEmpty) return;

    final visibleIndices = [
      if (_currentPage > 0) _currentPage - 1,
      _currentPage,
      if (_currentPage < _videos.length - 1) _currentPage + 1,
    ];

    for (final index in visibleIndices) {
      if (index >= 0 && index < _videos.length) {
        final video = _videos[index];
        if (!_controllers.contains(video.id) && !_controllers.isDisposing(video.id)) {
          await _initializeController(video);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: BlocListener<VideoFeedCubit, VideoFeedState>(
        listenWhen:
            (prev, curr) =>
                prev.videos != curr.videos ||
                prev.isLoading != curr.isLoading ||
                prev.preloadedVideoUrls != curr.preloadedVideoUrls,
        listener: (context, state) {
          setState(() => _videos = state.videos);
          _ensureControllersForWindow();
        },
        child: PreloadPageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          itemCount: _videos.length,
          onPageChanged: (newIndex) async {
            if (_currentPage < _videos.length) {
              final previousVideo = _videos[_currentPage];
              final controller = _controllers.get(previousVideo.id);
              if (controller != null && controller.value.isPlaying) {
                await controller.pause();
              }
            }

            _currentPage = newIndex;
            await _ensureControllersForWindow();
            await _playCurrentVideo();

            context.read<VideoFeedCubit>().onPageChanged(newIndex);
          },
          itemBuilder: (context, index) {
            return RepaintBoundary(
              child: VideoFeedItem(
                key: ValueKey(_videos[index].id),
                controller: _controllers.get(_videos[index].id),
                videoItem: _videos[index],
              ),
            );
          },
        ),
      ),
    );
  }
}
