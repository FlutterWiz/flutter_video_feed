import 'package:flutter/material.dart';
import 'package:flutter_video_feed/presentation/design_system/colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    margin: const EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(border: Border.all(color: white), borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      AppLocalizations.of(context)!.follow,
                      style: const TextStyle(color: white, fontSize: 16),
                    ),
                  ),
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
          padding: const EdgeInsets.only(bottom: 16, right: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 20,
            children: [
              Column(
                spacing: 4,
                children: [
                  Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? red : white, size: 36),
                  Text(
                    likeCount.toString(),
                    style: const TextStyle(color: white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Column(
                spacing: 4,
                children: [
                  const Icon(LucideIcons.messageCircle, color: white, size: 36),
                  Text(
                    commentCount.toString(),
                    style: const TextStyle(color: white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Column(
                spacing: 4,
                children: [
                  const Icon(LucideIcons.send, color: white, size: 32),
                  Text(
                    shareCount.toString(),
                    style: const TextStyle(color: white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: white, size: 36),
            ],
          ),
        ),
      ],
    );
  }
}
