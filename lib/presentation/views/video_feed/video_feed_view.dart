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

class _VideoFeedViewState extends State<VideoFeedView> {
  final Map<String, VideoPlayerController> _controllers = {};
  List<VideoItem> _videos = [];
  int _currentPage = 0;
  late final PreloadPageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PreloadPageController(initialPage: _currentPage);
    // Listen once to set up initial videos.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<VideoFeedCubit>().state;
      if (state.videos.isNotEmpty) {
        setState(() {
          _videos = state.videos;
        });
        _initializeAndPlay(_videos[0]);
      }
    });
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializeAndPlay(VideoItem video) async {
    if (!_controllers.containsKey(video.id)) {
      try {
        final file = await context.read<VideoFeedCubit>().getCachedVideoFile(video.videoUrl);
        final controller = VideoPlayerController.file(file);
        await controller.initialize();
        controller.setLooping(true);
        _controllers[video.id] = controller;
        if (mounted) setState(() {});
        // Play after a short delay.
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && _currentPage < _videos.length && _videos[_currentPage].id == video.id) {
            _controllers[video.id]?.play();
          }
        });
      } catch (e) {
        debugPrint("Error initializing controller for video ${video.id}: $e");
      }
    }
  }

  void _ensureControllersForWindow() {
    final indices = [_currentPage - 1, _currentPage, _currentPage + 1];
    for (final i in indices) {
      if (i >= 0 && i < _videos.length) {
        _initializeAndPlay(_videos[i]);
      }
    }
  }

  void _disposeControllersOutsideWindow() {
    final allowedIds = <String>{};
    for (final i in [_currentPage - 1, _currentPage, _currentPage + 1]) {
      if (i >= 0 && i < _videos.length) allowedIds.add(_videos[i].id);
    }
    final keysToRemove = _controllers.keys.where((id) => !allowedIds.contains(id)).toList();
    for (final id in keysToRemove) {
      _controllers[id]?.dispose();
      _controllers.remove(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VideoFeedCubit, VideoFeedState>(
      listenWhen: (prev, curr) => prev.videos != curr.videos || prev.isLoading != curr.isLoading,
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
        onPageChanged: (newIndex) {
          // Pause previous video.
          if (_currentPage < _videos.length) {
            _controllers[_videos[_currentPage].id]?.pause();
          }
          _currentPage = newIndex;
          _ensureControllersForWindow();
          _disposeControllersOutsideWindow();

          // Play current video.
          if (_controllers.containsKey(_videos[_currentPage].id)) {
            _controllers[_videos[_currentPage].id]?.play();
          }
          // Notify cubit about the page change to trigger loadMore if needed.
          context.read<VideoFeedCubit>().onPageChanged(newIndex);
        },
        itemBuilder: (context, index) {
          final videoItem = _videos[index];
          final controller = _controllers[videoItem.id];
          return VideoFeedItem(key: ValueKey(videoItem.id), controller: controller, videoItem: videoItem);
        },
      ),
    );
  }
}
