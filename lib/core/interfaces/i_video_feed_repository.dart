import 'package:flutter_video_feed/domain/models/video_item.dart';

abstract class IVideoFeedRepository {
  /// Fetch the initial batch of video items from Firestore.
  /// In this example, we fetch 2 items.
  Future<List<VideoItem>> fetchVideos();

  /// Fetch additional videos for pagination.
  /// [lastVideo] is the last video from the current list.
  Future<List<VideoItem>> fetchMoreVideos({required VideoItem lastVideo});
}
