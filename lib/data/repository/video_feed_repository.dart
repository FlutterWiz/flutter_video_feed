import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_video_feed/core/interfaces/i_video_feed_repository.dart';
import 'package:flutter_video_feed/domain/models/video_item.dart';

class VideoFeedRepository implements IVideoFeedRepository {
  VideoFeedRepository(this._firestore);

  final FirebaseFirestore _firestore;
  final String _collectionPath = 'videos';

  @override
  Future<List<VideoItem>> fetchVideos() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection(_collectionPath).get();
      return snapshot.docs.map((doc) => VideoItem.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error fetching videos: $e');
    }
  }
}
