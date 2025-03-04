import 'dart:io';
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
  List<VideoItem> videoItemList = [];
  int _currentPage = 0;
  late final PreloadPageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PreloadPageController(initialPage: _currentPage);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<VideoFeedCubit>().state;
      if (state.videos.isNotEmpty) {
        setState(() {
          videoItemList = state.videos;
        });
        _initializeControllerForVideo(videoItemList[0]).then((_) {
          if (_controllers.containsKey(videoItemList[0].id)) {
            _controllers[videoItemList[0].id]?.play();
          }
        });
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

  Future<void> _initializeControllerForVideo(VideoItem video) async {
    if (!_controllers.containsKey(video.id)) {
      try {
        final File file = await context.read<VideoFeedCubit>().getCachedVideoFile(video.videoUrl);
        final controller = VideoPlayerController.file(file);
        await controller.initialize();
        controller.setLooping(true);
        _controllers[video.id] = controller;
        if (mounted) setState(() {});
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && _currentPage < videoItemList.length) {
            final currentVideo = videoItemList[_currentPage];
            if (currentVideo.id == video.id && !_controllers[video.id]!.value.isPlaying) {
              _controllers[video.id]?.play();
            }
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
      if (i >= 0 && i < videoItemList.length) {
        final video = videoItemList[i];
        _initializeControllerForVideo(video);
      }
    }
  }

  void _disposeControllersOutsideWindow() {
    final allowedIds = <String>{};
    final indices = [_currentPage - 1, _currentPage, _currentPage + 1];
    for (final i in indices) {
      if (i >= 0 && i < videoItemList.length) {
        allowedIds.add(videoItemList[i].id);
      }
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
      listenWhen: (previous, current) => previous.videos != current.videos || previous.isLoading != current.isLoading,
      listener: (context, state) {
        setState(() {
          videoItemList = state.videos;
        });
        _ensureControllersForWindow();
      },
      child: PreloadPageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: videoItemList.length,
        preloadPagesCount: 2,
        onPageChanged: (newIndex) {
          if (_currentPage < videoItemList.length) {
            final previousVideo = videoItemList[_currentPage];
            _controllers[previousVideo.id]?.pause();
          }
          _currentPage = newIndex;
          _ensureControllersForWindow();
          _disposeControllersOutsideWindow();
          final currentVideo = videoItemList[_currentPage];
          if (_controllers.containsKey(currentVideo.id)) {
            _controllers[currentVideo.id]?.play();
          }
          // Trigger pagination when on the last video.
          final cubitState = context.read<VideoFeedCubit>().state;
          if (cubitState.hasMoreVideos && _currentPage >= videoItemList.length - 1) {
            context.read<VideoFeedCubit>().loadMoreVideos();
          }
        },
        itemBuilder: (context, index) {
          final VideoItem videoItem = videoItemList[index];
          final controller = _controllers[videoItem.id];
          return VideoFeedItem(key: ValueKey(videoItem.id), controller: controller, videoItem: videoItem);
        },
      ),
    );
  }
}
