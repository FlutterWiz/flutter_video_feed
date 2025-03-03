import 'package:flutter/material.dart';
import 'package:flutter_video_feed/domain/models/video_item.dart';
import 'package:flutter_video_feed/presentation/views/video_feed/widgets/video_overlay_section.dart';
import 'package:flutter_video_feed/presentation/views/video_feed/widgets/video_player_section.dart';
import 'package:video_player/video_player.dart';

class VideoFeedItem extends StatelessWidget {
  const VideoFeedItem({super.key, required this.videoItem, required this.controller});

  final VideoItem videoItem;
  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    final String profileImageUrl = videoItem.profileImageUrl;
    final String username = videoItem.username;
    final String description = videoItem.description;
    final int commentCount = videoItem.commentCount;
    final int shareCount = videoItem.shareCount;
    final int likeCount = videoItem.likeCount;
    final bool isBookmarked = videoItem.isBookmarked;
    final bool isLiked = videoItem.isLiked;

    return Stack(
      children: [
        VideoPlayerSection(controller: controller),
        VideoOverlaySection(
          profileImageUrl: profileImageUrl,
          username: username,
          description: description,
          isBookmarked: isBookmarked,
          isLiked: isLiked,
          likeCount: likeCount,
          commentCount: commentCount,
          shareCount: shareCount,
        ),
      ],
    );
  }
}
