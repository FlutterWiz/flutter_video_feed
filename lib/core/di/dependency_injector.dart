import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_video_feed/core/init/router/app_router.dart';
import 'package:flutter_video_feed/core/interfaces/i_video_feed_repository.dart';
import 'package:flutter_video_feed/core/services/video_feed_service.dart';
import 'package:flutter_video_feed/data/repository/video_feed_repository.dart';
import 'package:flutter_video_feed/presentation/blocs/video_feed/video_feed_cubit.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void injectionSetup() {
  getIt.registerSingleton<AppRouter>(AppRouter());

  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  getIt.registerLazySingleton<IVideoFeedRepository>(() => VideoFeedRepository(getIt<FirebaseFirestore>()));

  getIt.registerFactory<VideoFeedCubit>(() => VideoFeedCubit(getIt<IVideoFeedRepository>()));

  getIt.registerLazySingleton<VideoFeedService>(() => VideoFeedService());
}
