import 'package:flutter_video_feed/presentation/design_system/widgets/bare_bones_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BareBonesScaffold(
      body: Center(child: Text(AppLocalizations.of(context)!.profile, style: const TextStyle(fontSize: 20))),
    );
  }
}
