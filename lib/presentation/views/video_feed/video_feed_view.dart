import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_video_feed/core/constants/enums/video_property_enums.dart';
import 'package:flutter_video_feed/domain/models/video_item.dart';
import 'package:flutter_video_feed/presentation/blocs/video_feed/video_feed_cubit.dart';
import 'package:flutter_video_feed/presentation/blocs/video_feed/video_feed_state.dart';
import 'package:flutter_video_feed/presentation/views/video_feed/widgets/video_feed_item.dart';

class VideoFeedView extends StatefulWidget {
  const VideoFeedView({Key? key}) : super(key: key);

  @override
  State<VideoFeedView> createState() => _VideoFeedViewState();
}

class _VideoFeedViewState extends State<VideoFeedView> {
  List<VideoItem> videoItemList = [];
  bool isBookmarked = false;
  bool isLiked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    context.read<VideoFeedCubit>().loadVideos();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VideoFeedCubit, VideoFeedState>(
      listener: (context, state) {
        // When new data is loaded, update local lists.
        setState(() {
          videoItemList = state.videos;
        });
      },
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videoItemList.length,
        onPageChanged: (index) {
          // Optionally handle page changes (e.g., preload, analytics)
        },
        itemBuilder: (context, index) {
          final VideoItem videoItem = videoItemList[index];
          isBookmarked = videoItem.isBookmarked;
          isLiked = videoItem.isLiked;
          likeCount = videoItem.likeCount;

          return VideoFeedItem(
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
