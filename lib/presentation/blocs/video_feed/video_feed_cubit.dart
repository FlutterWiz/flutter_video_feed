import 'dart:io';

import 'package:flutter/material.dart';
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
      final List<VideoItem> videos = await videoRepository.fetchVideos();
      final hasMore = videos.length == 2;
      emit(state.copyWith(isLoading: false, videos: videos, hasMoreVideos: hasMore));
    } catch (e) {
      debugPrint("loadVideos error: $e");
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadMoreVideos() async {
    if (state.isPaginating || !state.hasMoreVideos) {
      // Already paginating or no more videos
      return;
    }

    emit(state.copyWith(isPaginating: true));

    try {
      if (state.videos.isNotEmpty) {
        final lastVideo = state.videos.last;

        final List<VideoItem> moreVideos = await videoRepository.fetchMoreVideos(lastVideo: lastVideo);

        final hasMore = moreVideos.length == 2;
        final updatedVideos = List<VideoItem>.from(state.videos)..addAll(moreVideos);
        emit(state.copyWith(videos: updatedVideos, isPaginating: false, hasMoreVideos: hasMore));
      }
    } catch (e) {
      debugPrint("loadMoreVideos error: $e");
      emit(state.copyWith(isPaginating: false, error: e.toString()));
    }
  }

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
