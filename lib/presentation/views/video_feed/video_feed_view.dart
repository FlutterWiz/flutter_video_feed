import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_video_feed/core/constants/enums/video_property_enums.dart';
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
  final Map<String, VideoPlayerController> _controllers = {};

  late List<VideoItem> videoItemList;
  late bool isBookmarked;
  late bool isLiked;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    videoItemList = [];
    isBookmarked = false;
    isLiked = false;
    likeCount = 0;
    context.read<VideoFeedCubit>().loadVideos();
  }

  @override
  void dispose() {
    // Dispose all controllers.
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Initialize controllers for videos that don't have one yet.
  void _initializeControllers(List<VideoItem> videos) {
    for (final video in videos) {
      if (!_controllers.containsKey(video.id)) {
        final controller = VideoPlayerController.networkUrl(Uri.parse(video.videoUrl));
        controller.initialize().then((_) {
          setState(() {});
          // Optionally start playback automatically:
          // controller.play();
        });
        _controllers[video.id] = controller;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VideoFeedCubit, VideoFeedState>(
      listener: (context, state) {
        setState(() {
          videoItemList = state.videos;
        });
        _initializeControllers(state.videos);
      },
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videoItemList.length,
        onPageChanged: (index) {
          // Optionally handle page changes (e.g., pause off-screen videos)
        },
        itemBuilder: (context, index) {
          final VideoItem videoItem = videoItemList[index];
          final controller = _controllers[videoItem.id];
          isBookmarked = videoItem.isBookmarked;
          isLiked = videoItem.isLiked;
          likeCount = videoItem.likeCount;

          return VideoFeedItem(
            controller: controller,
            videoItem: videoItem,
            isBookmarked: isBookmarked,
            isLiked: isLiked,
            likeCount: likeCount,
            likeOnPressed: () {
              if (isLiked) {
                setState(() {
                  likeCount--;
                  isLiked = !isLiked;
                });
              } else {
                setState(() {
                  likeCount++;
                  isLiked = !isLiked;
                });
              }

              context.read<VideoFeedCubit>().toggleVideoProperty(
                docId: videoItem.id,
                videoProperty: VideoPropertyEnums.like,
                newValue: isLiked,
                likeCount: likeCount,
              );
            },
            bookmarkOnPressed: () {
              setState(() {
                isBookmarked = !isBookmarked;
              });

              context.read<VideoFeedCubit>().toggleVideoProperty(
                docId: videoItem.id,
                videoProperty: VideoPropertyEnums.bookmark,
                newValue: !videoItem.isBookmarked,
              );
            },
          );
        },
      ),
    );
  }
}
