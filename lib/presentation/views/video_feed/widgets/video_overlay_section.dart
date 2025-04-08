import 'package:flutter/material.dart';
import 'package:flutter_video_feed/presentation/views/video_feed/widgets/interaction_buttons.dart';
import 'package:flutter_video_feed/presentation/views/video_feed/widgets/user_info_section.dart';

class VideoOverlaySection extends StatelessWidget {
  const VideoOverlaySection({
    Key? key,
    required this.profileImageUrl,
    required this.username,
    required this.description,
    required this.isBookmarked,
    required this.isLiked,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
  }) : super(key: key);

  final String profileImageUrl;
  final String username;
  final String description;
  final bool isBookmarked;
  final bool isLiked;
  final int likeCount;
  final int commentCount;
  final int shareCount;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          UserInfoSection(profileImageUrl: profileImageUrl, username: username, description: description),
          InteractionButtons(
            isLiked: isLiked,
            isBookmarked: isBookmarked,
            likeCount: likeCount,
            commentCount: commentCount,
            shareCount: shareCount,
          ),
        ],
      ),
    );
  }
}
