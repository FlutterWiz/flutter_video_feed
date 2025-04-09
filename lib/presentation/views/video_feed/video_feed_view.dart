import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_video_feed/core/di/dependency_injector.dart';
import 'package:flutter_video_feed/core/services/video_feed_service.dart';
import 'package:flutter_video_feed/domain/models/video_item.dart';
import 'package:flutter_video_feed/presentation/blocs/video_feed/video_feed_cubit.dart';
import 'package:flutter_video_feed/presentation/blocs/video_feed/video_feed_state.dart';
import 'package:flutter_video_feed/presentation/views/video_feed/widgets/video_feed_item.dart';
import 'package:preload_page_view/preload_page_view.dart';

class VideoFeedView extends StatefulWidget {
  const VideoFeedView({Key? key}) : super(key: key);

  @override
  State<VideoFeedView> createState() => _VideoFeedViewState();
}

class _VideoFeedViewState extends State<VideoFeedView> with WidgetsBindingObserver {
  late final PreloadPageController _pageController;
  late final VideoFeedService _videoService;

  List<VideoItem> _videos = [];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _videoService = getIt<VideoFeedService>();

    WidgetsBinding.instance.addObserver(this);
    _pageController = PreloadPageController(initialPage: _currentPage);
    _initializeFirstVideo();
  }

  void _initializeFirstVideo() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = context.read<VideoFeedCubit>().state;
      if (state.videos.isNotEmpty) {
        setState(() => _videos = state.videos);
        await _videoService.initializeFirstVideo(
          _videos,
          context.read<VideoFeedCubit>().getCachedVideoFile,
        );
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoService.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _reinitializeCurrentVideo() async {
    if (_videos.isEmpty || _currentPage >= _videos.length) return;
    
    final currentVideo = _videos[_currentPage];
    final controller = _videoService.getController(currentVideo.id);
    
    if (controller != null && !controller.value.isInitialized) {
      await _videoService.initializeController(
        currentVideo,
        context.read<VideoFeedCubit>().getCachedVideoFile,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _videoService.isAppActive = state == AppLifecycleState.resumed;
    
    if (_videoService.isAppActive) {
      _reinitializeCurrentVideo().then((_) {
        _videoService.playCurrentVideo(_videos, _currentPage);
      });
    } else {
      _videoService.pauseAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: BlocListener<VideoFeedCubit, VideoFeedState>(
        listenWhen: (p, c) =>
            p.videos != c.videos || p.isLoading != c.isLoading || p.preloadedVideoUrls != c.preloadedVideoUrls,
        listener: (context, state) {
          setState(() => _videos = state.videos);
          _videoService.manageControllerWindow(
            _videos,
            _currentPage,
            context.read<VideoFeedCubit>().getCachedVideoFile,
          );
        },
        child: PreloadPageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          itemCount: _videos.length,
          physics: const AlwaysScrollableScrollPhysics(),
          onPageChanged: (newIndex) async {
            final previousPage = _currentPage;
            _currentPage = newIndex;
            await _videoService.handlePageChange(
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
                controller: _videoService.getController(_videos[index].id),
                videoItem: _videos[index],
              ),
            );
          },
        ),
      ),
    );
  }
}
