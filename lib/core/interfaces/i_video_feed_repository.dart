import 'package:flutter_video_feed/core/constants/enums/video_property_enums.dart';
import 'package:flutter_video_feed/domain/models/video_item.dart';

abstract class IVideoFeedRepository {
  /// Fetch the list of video items from Firestore.
  Future<List<VideoItem>> fetchVideos();

  /// Update a specific property (like or bookmark) for a given video.
  ///
  /// [docId] is the Firestore document ID.
  ///
  /// [videoProperty] indicates which field to update. For example, like or bookmark from [VideoPropertyEnums].
  ///
  /// [newValue] is the new boolean value.
  ///
  /// [likeCount] is the new like count value. This is only used when [videoProperty] is [VideoPropertyEnums.like].
  Future<void> updateVideoProperty(String docId, VideoPropertyEnums videoProperty, bool newValue, int? likeCount);
}
