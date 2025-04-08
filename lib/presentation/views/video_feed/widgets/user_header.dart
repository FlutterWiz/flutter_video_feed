import 'package:flutter/material.dart';
import 'package:flutter_video_feed/presentation/design_system/colors.dart';
import 'package:flutter_video_feed/presentation/views/video_feed/widgets/follow_button.dart';

class UserHeader extends StatelessWidget {
  const UserHeader({super.key, required this.profileImageUrl, required this.username});

  final String profileImageUrl;
  final String username;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        CircleAvatar(radius: 20, backgroundImage: NetworkImage(profileImageUrl)),
        Text(username, style: const TextStyle(color: white, fontWeight: FontWeight.bold, fontSize: 18)),
        const FollowButton(),
      ],
    );
  }
}
