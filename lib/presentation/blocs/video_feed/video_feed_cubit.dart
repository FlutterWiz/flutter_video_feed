import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_video_feed/core/interfaces/i_video_feed_repository.dart';
import 'package:flutter_video_feed/domain/models/video_item.dart';
import 'package:flutter_video_feed/presentation/blocs/video_feed/video_feed_state.dart';

class VideoFeedCubit extends Cubit<VideoFeedState> {
  VideoFeedCubit(this.videoRepository) : super(VideoFeedState.initial()) {
    loadVideos();
  }

  final IVideoFeedRepository videoRepository;

  Future<void> loadVideos() async {
    emit(state.copyWith(isLoading: true));
    try {
      final videos = await videoRepository.fetchVideos();
      // If we receive a full batch (i.e. 2), we assume there may be more.
      final hasMore = videos.length == 2;
      emit(state.copyWith(isLoading: false, videos: videos, hasMoreVideos: hasMore));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadMoreVideos() async {
    if (state.isPaginating || !state.hasMoreVideos) return;
    emit(state.copyWith(isPaginating: true));

    try {
      if (state.videos.isNotEmpty) {
        final lastVideo = state.videos.last;
        final moreVideos = await videoRepository.fetchMoreVideos(lastVideo: lastVideo);
        final hasMore = moreVideos.length == 2;
        final updatedVideos = List<VideoItem>.from(state.videos)..addAll(moreVideos);
        emit(state.copyWith(videos: updatedVideos, isPaginating: false, hasMoreVideos: hasMore));
      }
    } catch (e) {
      emit(state.copyWith(isPaginating: false, error: e.toString()));
    }
  }

  /// Called from the view when the page changes.
  /// If the user is at the last page and more videos are available, we trigger pagination.
  void onPageChanged(int newIndex) {
    if (state.hasMoreVideos && newIndex >= state.videos.length - 1) {
      loadMoreVideos();
    }
  }

  Future<File> getCachedVideoFile(String videoUrl) async {
    final cacheManager = DefaultCacheManager();
    final fileInfo = await cacheManager.getFileFromCache(videoUrl);
    return fileInfo?.file ?? await cacheManager.getSingleFile(videoUrl);
  }
}
