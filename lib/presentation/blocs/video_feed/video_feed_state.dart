import 'package:equatable/equatable.dart';
import 'package:flutter_video_feed/domain/models/video_item.dart';

class VideoFeedState extends Equatable {
  const VideoFeedState({
    this.videos = const [],
    this.isLoading = false,
    this.isPaginating = false,
    this.hasMoreVideos = true,
    this.error = '',
  });

  final List<VideoItem> videos;
  final bool isLoading;
  final bool isPaginating;
  final bool hasMoreVideos;
  final String error;

  @override
  List<Object> get props => [videos, isLoading, isPaginating, hasMoreVideos, error];

  VideoFeedState copyWith({
    List<VideoItem>? videos,
    bool? isLoading,
    bool? isPaginating,
    bool? hasMoreVideos,
    String? error,
  }) {
    return VideoFeedState(
      videos: videos ?? this.videos,
      isLoading: isLoading ?? this.isLoading,
      isPaginating: isPaginating ?? this.isPaginating,
      hasMoreVideos: hasMoreVideos ?? this.hasMoreVideos,
      error: error ?? this.error,
    );
  }

  factory VideoFeedState.initial() => const VideoFeedState();
}
