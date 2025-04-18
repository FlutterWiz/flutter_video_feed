import 'package:flutter/material.dart';
import 'package:flutter_video_feed/presentation/l10n/app_localizations.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(AppLocalizations.of(context)!.dashboard, style: const TextStyle(fontSize: 20)));
  }
}
