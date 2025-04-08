import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class OptimizedVideoPlayer extends StatefulWidget {
  const OptimizedVideoPlayer({Key? key, required this.controller, required this.videoId}) : super(key: key);

  final VideoPlayerController? controller;
  final String videoId;

  @override
  State<OptimizedVideoPlayer> createState() => _OptimizedVideoPlayerState();
}

class _OptimizedVideoPlayerState extends State<OptimizedVideoPlayer> with SingleTickerProviderStateMixin {
  late AnimationController _loadingController;
  bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();

    widget.controller?.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _loadingController.dispose();
    widget.controller?.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (!mounted) return;

    final controller = widget.controller;
    if (controller == null) return;

    final isBuffering = controller.value.isBuffering;
    if (_isBuffering != isBuffering) {
      setState(() {
        _isBuffering = isBuffering;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: () {
        if (controller.value.isPlaying) {
          controller.pause();
        } else {
          controller.play();
        }
      },
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: Stack(
              children: [VideoPlayer(controller), if (_isBuffering) const Center(child: CircularProgressIndicator())],
            ),
          ),
        ),
      ),
    );
  }
}
