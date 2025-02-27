import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_video_feed/core/constants/enums/video_property_enums.dart';
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

  /// Toggles a specific videoProperty (like or bookmark) for a video.
  /// This method updates Firestore and then updates the local state.
  Future<void> toggleVideoProperty({
    required String docId,
    required VideoPropertyEnums videoProperty,
    required bool newValue,
    int? likeCount,
  }) async {
    try {
      // Update Firestore via repository.
      await videoRepository.updateVideoProperty(docId, videoProperty, newValue, likeCount);

      // Update local state optimistically by recreating the VideoItem.
      final updatedVideos =
          state.videos.map((video) {
            if (video.id == docId) {
              if (videoProperty == VideoPropertyEnums.like) {
                // Instead of recalculating the new like count here, we use the UI-passed likeCount.
                return VideoItem(
                  id: video.id,
                  username: video.username,
                  description: video.description,
                  videoUrl: video.videoUrl,
                  profileImageUrl: video.profileImageUrl,
                  likeCount: likeCount!, // Use the value provided from the UI.
                  commentCount: video.commentCount,
                  shareCount: video.shareCount,
                  isBookmarked: video.isBookmarked,
                  isLiked: newValue,
                );
              } else if (videoProperty == VideoPropertyEnums.bookmark) {
                return VideoItem(
                  id: video.id,
                  username: video.username,
                  description: video.description,
                  videoUrl: video.videoUrl,
                  profileImageUrl: video.profileImageUrl,
                  likeCount: video.likeCount,
                  commentCount: video.commentCount,
                  shareCount: video.shareCount,
                  isBookmarked: newValue,
                  isLiked: video.isLiked,
                );
              }
            }
            return video;
          }).toList();

      emit(state.copyWith(videos: updatedVideos));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
