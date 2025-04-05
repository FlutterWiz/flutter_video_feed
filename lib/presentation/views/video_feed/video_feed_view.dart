import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_video_feed/domain/models/video_item.dart';
import 'package:flutter_video_feed/core/services/video_controller_cache_service.dart';
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
  final VideoControllerCacheService _controllers = VideoControllerCacheService();
  late final PreloadPageController _pageController;
  List<VideoItem> _videos = [];
  int _currentPage = 0;
  bool _isAppActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PreloadPageController(initialPage: _currentPage);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<VideoFeedCubit>().state;
      if (state.videos.isNotEmpty) {
        setState(() {
          _videos = state.videos;
        });
        _initializeController(_videos.first);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controllers.clear();
    _pageController.dispose();
    super.dispose();
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
      // Ensure other videos are paused before playing current
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
        setState(() {});

        if (_isAppActive && _currentPage == _videos.indexOf(video)) {
          await _playCurrentVideo();
        }
      } catch (e) {
        debugPrint('Error initializing controller: $e');
      }
    }
  }

  void _handleVideoPreloading() {
    final cubit = context.read<VideoFeedCubit>();
    if (_controllers.length >= 2) {
      cubit.preloadNextVideos();
    }
  }

  Future<void> _ensureControllersForWindow() async {
    final indices = [
      if (_currentPage > 0) _currentPage - 1,
      _currentPage,
      if (_currentPage < _videos.length - 1) _currentPage + 1,
    ];

    // Initialize controllers for the window
    for (final index in indices) {
      if (index >= 0 && index < _videos.length) {
        await _initializeController(_videos[index]);
      }
    }

    // Remove controllers outside the window
    final validIds = indices
        .where((i) => i >= 0 && i < _videos.length)
        .map((i) => _videos[i].id)
        .toSet();

    final currentIds = Set.from(_controllers.cache.keys);
    for (final id in currentIds) {
      if (!validIds.contains(id)) {
        await _controllers.remove(id);
      }
    }

    _handleVideoPreloading();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VideoFeedCubit, VideoFeedState>(
      listenWhen: (prev, curr) =>
          prev.videos != curr.videos ||
          prev.isLoading != curr.isLoading ||
          prev.preloadedVideoUrls != curr.preloadedVideoUrls,
      listener: (context, state) {
        setState(() {
          _videos = state.videos;
        });
        _ensureControllersForWindow();
      },
      child: PreloadPageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: _videos.length,
        preloadPagesCount: 2,
        onPageChanged: (newIndex) async {
          if (_currentPage < _videos.length) {
            final previousVideo = _videos[_currentPage];
            await _controllers.get(previousVideo.id)?.pause();
          }

          _currentPage = newIndex;
          await _ensureControllersForWindow();
          await _playCurrentVideo();

          context.read<VideoFeedCubit>().onPageChanged(newIndex);
        },
        itemBuilder: (context, index) {
          final videoItem = _videos[index];
          final controller = _controllers.get(videoItem.id);
          return VideoFeedItem(
            key: ValueKey(videoItem.id),
            controller: controller,
            videoItem: videoItem,
          );
        },
      ),
    );
  }
}
