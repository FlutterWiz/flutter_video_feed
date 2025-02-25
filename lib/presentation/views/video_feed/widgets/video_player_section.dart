import 'package:flutter/material.dart';

class VideoPlayerSection extends StatelessWidget {
  const VideoPlayerSection({Key? key, required this.profileImageUrl}) : super(key: key);

  final String profileImageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(profileImageUrl), fit: BoxFit.cover)),
    );
  }
}
