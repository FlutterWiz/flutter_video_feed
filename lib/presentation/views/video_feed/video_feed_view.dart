import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_video_feed/domain/models/video_item.dart';
import 'package:flutter_video_feed/presentation/blocs/video_feed/video_feed_cubit.dart';
import 'package:flutter_video_feed/presentation/blocs/video_feed/video_feed_state.dart';
import 'package:flutter_video_feed/presentation/views/video_feed/widgets/video_feed_item.dart';
import 'package:video_player/video_player.dart';

class VideoFeedView extends StatefulWidget {
  const VideoFeedView({Key? key}) : super(key: key);

  @override
  State<VideoFeedView> createState() => _VideoFeedViewState();
}

class _VideoFeedViewState extends State<VideoFeedView> {
  late final Map<String, VideoPlayerController> _controllers = {};

  late List<VideoItem> videoItemList;
  late int _currentPage;

  @override
  void initState() {
    super.initState();

    context.read<VideoFeedCubit>().loadVideos();
    videoItemList = context.read<VideoFeedCubit>().state.videos;
    _currentPage = 0;
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Create and initialize a controller for a given video, using the cached file.
  Future<void> _initializeControllerForVideo(VideoItem video) async {
    if (!_controllers.containsKey(video.id)) {
      final file = await context.read<VideoFeedCubit>().getCachedVideoFile(video.videoUrl);

      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      controller.setLooping(true);
      _controllers[video.id] = controller;
      if (mounted) {
        setState(() {}); // Trigger rebuild once the controller is ready.
      }
    }
  }

  // Ensure controllers for the current, previous, and next videos are initialized.
  void _ensureControllersForWindow() {
    final indices = [_currentPage - 1, _currentPage, _currentPage + 1];
    for (final i in indices) {
      if (i >= 0 && i < videoItemList.length) {
        final video = videoItemList[i];
        _initializeControllerForVideo(video);
      }
    }
  }

  // Dispose controllers that are outside the current window.
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
        // Auto-play the first video when the view loads.
        if (videoItemList.isNotEmpty && _currentPage == 0) {
          final firstVideo = videoItemList[0];
          if (_controllers.containsKey(firstVideo.id)) {
            _controllers[firstVideo.id]?.play();
          }
        }
      },
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videoItemList.length,
        onPageChanged: (newIndex) {
          // Pause previous video.
          if (_currentPage < videoItemList.length) {
            final previousVideo = videoItemList[_currentPage];
            _controllers[previousVideo.id]?.pause();
          }
          _currentPage = newIndex;
          _ensureControllersForWindow();
          _disposeControllersOutsideWindow();
          // Auto-play new current video.
          final currentVideo = videoItemList[_currentPage];
          if (_controllers.containsKey(currentVideo.id)) {
            _controllers[currentVideo.id]?.play();
          }
        },
        itemBuilder: (context, index) {
          final VideoItem videoItem = videoItemList[index];
          final controller = _controllers[videoItem.id];

          return VideoFeedItem(controller: controller, videoItem: videoItem);
        },
      ),
    );
  }
}
