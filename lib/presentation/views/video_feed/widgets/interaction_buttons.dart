import 'package:flutter/material.dart';
import 'package:flutter_video_feed/presentation/design_system/colors.dart';
import 'package:flutter_video_feed/presentation/views/video_feed/widgets/interaction_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class InteractionButtons extends StatelessWidget {
  const InteractionButtons({
    super.key,
    required this.isLiked,
    required this.isBookmarked,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
  });

  final bool isLiked;
  final bool isBookmarked;
  final int likeCount;
  final int commentCount;
  final int shareCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 20,
        children: [
          InteractionButton(
            icon: isLiked ? Icons.favorite : Icons.favorite_border,
            count: likeCount,
            color: isLiked ? red : white,
          ),
          InteractionButton(icon: LucideIcons.messageCircle, count: commentCount),
          InteractionButton(icon: LucideIcons.send, count: shareCount),
          Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: white, size: 36),
        ],
      ),
    );
  }
}
