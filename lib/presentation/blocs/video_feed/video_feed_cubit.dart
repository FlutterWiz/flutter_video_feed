import 'dart:io';
import 'dart:collection';

import 'package:flutter/foundation.dart';
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
  final _preloadQueue = Queue<String>();
  final _preloadedFiles = <String, File>{};
  bool _isPreloadingMore = false;

  Future<void> loadVideos() async {
    emit(state.copyWith(isLoading: true));
    try {
      final videos = await videoRepository.fetchVideos();
      final hasMoreVideos = videos.length == 2;
      emit(
        state.copyWith(
          isLoading: false,
          videos: videos,
          hasMoreVideos: hasMoreVideos,
          currentVideoIndex: 0,
        ),
      );

      // Start preloading next videos after initial load
      if (videos.isNotEmpty) {
        preloadNextVideos();
      }
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
        final moreVideos = await videoRepository.fetchMoreVideos(
          lastVideo: lastVideo,
        );
        final hasMoreVideos = moreVideos.length == 2;
        final updatedVideos = List<VideoItem>.from(state.videos)
          ..addAll(moreVideos);
        emit(
          state.copyWith(
            videos: updatedVideos,
            isPaginating: false,
            hasMoreVideos: hasMoreVideos,
          ),
        );

        // Preload new videos after loading more
        preloadNextVideos();
      }
    } catch (e) {
      emit(state.copyWith(isPaginating: false, error: e.toString()));
    }
  }

  void onPageChanged(int newIndex) async {
    emit(state.copyWith(currentVideoIndex: newIndex));

    // Start preloading next videos
    preloadNextVideos();

    // Smart pagination trigger
    if (!_isPreloadingMore &&
        state.hasMoreVideos &&
        newIndex >= state.videos.length - 2) {
      _isPreloadingMore = true;
      await loadMoreVideos();
      _isPreloadingMore = false;
    }
  }

  Future<void> preloadNextVideos() async {
    if (state.videos.isEmpty) return;

    final currentIndex = state.currentVideoIndex;
    final videosToPreload = state.videos
        .skip(currentIndex + 1)
        .take(2)
        .map((v) => v.videoUrl)
        .where((url) => !_preloadedFiles.containsKey(url));

    for (final videoUrl in videosToPreload) {
      if (!_preloadQueue.contains(videoUrl)) {
        _preloadQueue.add(videoUrl);
        _preloadVideo(videoUrl);
      }
    }
  }

  Future<void> _preloadVideo(String videoUrl) async {
    try {
      final file = await getCachedVideoFile(videoUrl);
      _preloadedFiles[videoUrl] = file;

      final currentPreloaded = Set<String>.from(state.preloadedVideoUrls)
        ..add(videoUrl);
      emit(state.copyWith(preloadedVideoUrls: currentPreloaded));
    } catch (e) {
      debugPrint('Error preloading video: $e');
    } finally {
      _preloadQueue.remove(videoUrl);
    }
  }

  Future<File> getCachedVideoFile(String videoUrl) async {
    if (_preloadedFiles.containsKey(videoUrl)) {
      return _preloadedFiles[videoUrl]!;
    }

    final cacheManager = DefaultCacheManager();
    final fileInfo = await cacheManager.getFileFromCache(videoUrl);
    final file = fileInfo?.file ?? await cacheManager.getSingleFile(videoUrl);
    _preloadedFiles[videoUrl] = file;
    return file;
  }

  @override
  Future<void> close() {
    _preloadQueue.clear();
    _preloadedFiles.clear();
    return super.close();
  }
}
