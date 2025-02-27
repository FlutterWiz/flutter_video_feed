import 'package:equatable/equatable.dart';
import 'package:flutter_video_feed/domain/models/video_item.dart';

class VideoFeedState extends Equatable {
  const VideoFeedState({this.videos = const [], this.isLoading = false, this.error = ''});

  final List<VideoItem> videos;
  final bool isLoading;
  final String error;

  @override
  List<Object> get props => [videos, isLoading, error];

  VideoFeedState copyWith({List<VideoItem>? videos, bool? isLoading, String? error}) {
    return VideoFeedState(
      videos: videos ?? this.videos,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  factory VideoFeedState.initial() => const VideoFeedState();
}
