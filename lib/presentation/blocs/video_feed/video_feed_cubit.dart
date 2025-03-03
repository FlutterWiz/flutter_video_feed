import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_video_feed/core/interfaces/i_video_feed_repository.dart';
import 'package:flutter_video_feed/domain/models/video_item.dart';
import 'package:flutter_video_feed/presentation/blocs/video_feed/video_feed_state.dart';

class VideoFeedCubit extends Cubit<VideoFeedState> {
  VideoFeedCubit(this.videoRepository) : super(VideoFeedState.initial());

  final IVideoFeedRepository videoRepository;

  /// Loads videos from Firestore and updates the state.
  Future<void> loadVideos() async {
    emit(state.copyWith(isLoading: true));

    try {
      final List<VideoItem> videos = await videoRepository.fetchVideos();

      emit(state.copyWith(isLoading: false, videos: videos));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Returns the cached file for the video URL if available,
  /// or downloads it if not.
  Future<File> getCachedVideoFile(String videoUrl) async {
    final cacheManager = DefaultCacheManager();
    final fileInfo = await cacheManager.getFileFromCache(videoUrl);
    if (fileInfo != null) {
      return fileInfo.file;
    } else {
      return await cacheManager.getSingleFile(videoUrl);
    }
  }
}
