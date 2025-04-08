import 'package:flutter/material.dart';
import 'package:flutter_video_feed/domain/models/video_item.dart';
import 'package:flutter_video_feed/presentation/views/video_feed/widgets/video_overlay_section.dart';
import 'package:flutter_video_feed/presentation/views/video_feed/widgets/optimized_video_player.dart';
import 'package:video_player/video_player.dart';

class VideoFeedItem extends StatelessWidget {
  const VideoFeedItem({super.key, required this.videoItem, required this.controller});

  final VideoItem videoItem;
  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        OptimizedVideoPlayer(controller: controller, videoId: videoItem.id),
        VideoOverlaySection(
          profileImageUrl: videoItem.profileImageUrl,
          username: videoItem.username,
          description: videoItem.description,
          isBookmarked: videoItem.isBookmarked,
          isLiked: videoItem.isLiked,
          likeCount: videoItem.likeCount,
          commentCount: videoItem.commentCount,
          shareCount: videoItem.shareCount,
        ),
      ],
    );
  }
}
