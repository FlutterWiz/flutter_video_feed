import 'package:flutter_video_feed/core/di/dependency_injector.dart';
import 'package:flutter_video_feed/core/init/router/app_router.dart';
import 'package:flutter_video_feed/presentation/blocs/video_feed/video_feed_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();
    return BlocProvider(
      lazy: false,
      create: (context) => getIt<VideoFeedCubit>(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter.router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
