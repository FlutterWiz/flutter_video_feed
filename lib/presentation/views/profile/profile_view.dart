import 'package:flutter_video_feed/core/constants/enums/router_enums.dart';
import 'package:flutter_video_feed/presentation/blocs/auth/auth_cubit.dart';
import 'package:flutter_video_feed/presentation/blocs/auth/auth_state.dart';
import 'package:flutter_video_feed/presentation/design_system/colors.dart';
import 'package:flutter_video_feed/presentation/design_system/widgets/bare_bones_loading_indicator.dart';
import 'package:flutter_video_feed/presentation/design_system/widgets/bare_bones_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthCubit>().state.user.uid;

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (p, c) => p.isLoading != c.isLoading || p.isLoggedIn != c.isLoggedIn,
      listener: (context, state) {
        if (state.isLoading == true) {
          BareBonesLoadingIndicator.of(context).show();
        }
        if (state.isLoading == false) {
          BareBonesLoadingIndicator.of(context).hide();
        }
        if (state.isLoggedIn == false) {
          context.go(RouterEnums.signInView.routeName);
        }
      },
      child: BareBonesScaffold(
        backgroundColor: blue,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.profile),
              Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Text(uid)),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthCubit>().signOut();
                },
                child: Text(AppLocalizations.of(context)!.signOutExclamation),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
