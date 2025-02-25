import 'package:flutter/material.dart';
import 'package:flutter_video_feed/presentation/design_system/colors.dart';

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
    required this.bookmarkOnPressed,
    required this.likeOnPressed,
  }) : super(key: key);

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 8,
            children: [
              Row(
                spacing: 8,
                children: [
                  CircleAvatar(radius: 20, backgroundImage: NetworkImage(profileImageUrl)),
                  Text(username, style: const TextStyle(color: white, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              Text(
                description.length > 30 ? description.substring(0, 30) + '...' : description,
                style: const TextStyle(color: white, fontSize: 18),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12, right: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 16,
            children: [
              Column(
                children: [
                  IconButton(
                    onPressed: likeOnPressed,
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? red : white,
                      size: 32,
                    ),
                  ),
                  Text(likeCount.toString(), style: const TextStyle(color: white, fontSize: 16)),
                ],
              ),
              Column(
                children: [
                  IconButton(icon: const Icon(Icons.comment, color: white, size: 32), onPressed: () {}),
                  Text(commentCount.toString(), style: const TextStyle(color: white, fontSize: 16)),
                ],
              ),
              Column(
                children: [
                  IconButton(icon: const Icon(Icons.share, color: white, size: 32), onPressed: () {}),
                  Text(shareCount.toString(), style: const TextStyle(color: white, fontSize: 16)),
                ],
              ),
              IconButton(
                onPressed: bookmarkOnPressed,
                icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: white, size: 32),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
