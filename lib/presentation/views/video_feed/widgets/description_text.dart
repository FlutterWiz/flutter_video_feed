import 'package:flutter/material.dart';
import 'package:flutter_video_feed/presentation/design_system/colors.dart';

class DescriptionText extends StatelessWidget {
  const DescriptionText({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.length > 30 ? '${text.substring(0, 30)}...' : text,
      style: const TextStyle(color: white, fontSize: 18),
    );
  }
}
