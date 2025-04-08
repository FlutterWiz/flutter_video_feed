import 'package:flutter/material.dart';
import 'package:flutter_video_feed/presentation/design_system/colors.dart';

class InteractionButton extends StatelessWidget {
  const InteractionButton({super.key, required this.icon, required this.count, this.color = white});

  final IconData icon;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4,
      children: [
        Icon(icon, color: color, size: 36),
        Text(count.toString(), style: const TextStyle(color: white, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
