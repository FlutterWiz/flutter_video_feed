import 'package:flutter_video_feed/domain/models/video_item.dart';

abstract class IVideoFeedRepository {
  /// Fetch the initial batch of video items from Firestore.
  /// In this example, we fetch 2 items.
  Future<List<VideoItem>> fetchVideos();

  /// Fetch additional videos for pagination.
  Future<List<VideoItem>> fetchMoreVideos();
}
