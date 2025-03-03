import 'package:flutter_video_feed/domain/models/video_item.dart';

abstract class IVideoFeedRepository {
  /// Fetch the list of video items from Firestore.
  Future<List<VideoItem>> fetchVideos();
}
