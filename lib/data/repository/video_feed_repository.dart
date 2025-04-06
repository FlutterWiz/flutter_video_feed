import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_video_feed/core/interfaces/i_video_feed_repository.dart';
import 'package:flutter_video_feed/domain/models/video_item.dart';

class VideoFeedRepository implements IVideoFeedRepository {
  VideoFeedRepository(this._firestore);

  final FirebaseFirestore _firestore;

  late DocumentSnapshot? _lastDocument;

  @override
  Future<List<VideoItem>> fetchVideos() async {
    return _fetchVideosHelper();
  }

  @override
  Future<List<VideoItem>> fetchMoreVideos({required VideoItem lastVideo}) async {
    if (_lastDocument == null) return [];
    return _fetchVideosHelper(startAfterDocument: _lastDocument);
  }

  // Common helper function for fetching a batch of videos.
  Future<List<VideoItem>> _fetchVideosHelper({DocumentSnapshot? startAfterDocument}) async {
    try {
      Query query = _firestore
          .collection('videos')
          .orderBy('timestamp', descending: false)
          .orderBy(FieldPath.documentId, descending: false)
          .limit(2);

      if (startAfterDocument != null) {
        query = query.startAfterDocument(startAfterDocument);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }

      return snapshot.docs.map((doc) => VideoItem.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error fetching videos: $e');
    }
  }
}
