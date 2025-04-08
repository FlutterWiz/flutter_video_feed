import 'package:flutter/material.dart';
import 'package:flutter_video_feed/presentation/design_system/colors.dart';
import 'package:flutter_video_feed/presentation/l10n/app_localizations.dart';

class FollowButton extends StatelessWidget {
  const FollowButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      margin: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(border: Border.all(color: white), borderRadius: BorderRadius.circular(8)),
      child: Text(AppLocalizations.of(context)!.follow, style: const TextStyle(color: white, fontSize: 16)),
    );
  }
}
