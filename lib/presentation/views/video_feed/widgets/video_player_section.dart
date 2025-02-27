import 'package:flutter/material.dart';
import 'package:flutter_video_feed/presentation/design_system/colors.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerSection extends StatelessWidget {
  const VideoPlayerSection({Key? key, required this.controller}) : super(key: key);

  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return GestureDetector(
      onTap: () {
        if (controller!.value.isPlaying) {
          controller!.pause();
        } else {
          controller!.play();
        }
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: black, // in case video doesn't fill entirely
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller!.value.size.width,
            height: controller!.value.size.height,
            child: VideoPlayer(controller!),
          ),
        ),
      ),
    );
  }
}
