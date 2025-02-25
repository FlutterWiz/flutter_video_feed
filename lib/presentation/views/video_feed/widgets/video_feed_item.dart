import 'package:flutter/material.dart';
import 'package:flutter_video_feed/presentation/views/video_feed/widgets/video_overlay_section.dart';
import 'package:flutter_video_feed/presentation/views/video_feed/widgets/video_player_section.dart';

class VideoFeedItem extends StatelessWidget {
  const VideoFeedItem({
    super.key,
    required this.profileImageUrl,
    required this.username,
    required this.description,
    required this.isBookmarked,
    required this.isLiked,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.bookmarkOnPressed,
    required this.likeOnPressed,
  });

  final String profileImageUrl;
  final String username;
  final String description;
  final bool isBookmarked;
  final bool isLiked;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final VoidCallback bookmarkOnPressed;
  final VoidCallback likeOnPressed;

  @override
  Widget build(BuildContext context) {
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
