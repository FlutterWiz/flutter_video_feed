import 'package:flutter/material.dart';
import 'package:flutter_video_feed/domain/models/video_item.dart';
import 'package:flutter_video_feed/presentation/views/video_feed/widgets/video_overlay_section.dart';
import 'package:flutter_video_feed/presentation/views/video_feed/widgets/video_player_section.dart';

class VideoFeedItem extends StatelessWidget {
  const VideoFeedItem({
    super.key,
    required this.videoItem,
    required this.bookmarkOnPressed,
    required this.likeOnPressed,
    required this.isBookmarked,
    required this.isLiked,
    required this.likeCount,
  });

  final VideoItem videoItem;
  final bool isBookmarked;
  final bool isLiked;
  final int likeCount;
  final VoidCallback bookmarkOnPressed;
  final VoidCallback likeOnPressed;

  @override
  Widget build(BuildContext context) {
    final String profileImageUrl = videoItem.profileImageUrl;
    final String username = videoItem.username;
    final String description = videoItem.description;
    final int commentCount = videoItem.commentCount;
    final int shareCount = videoItem.shareCount;

    return Stack(
      children: [
        VideoPlayerSection(profileImageUrl: profileImageUrl),
        VideoOverlaySection(
          profileImageUrl: profileImageUrl,
          username: username,
          description: description,
          isBookmarked: isBookmarked,
          isLiked: isLiked,
          likeCount: likeCount,
          commentCount: commentCount,
          shareCount: shareCount,
          bookmarkOnPressed: bookmarkOnPressed,
          likeOnPressed: likeOnPressed,
        ),
      ],
    );
  }
}
