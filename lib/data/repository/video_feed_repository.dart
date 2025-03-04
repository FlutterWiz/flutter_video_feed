import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_video_feed/core/interfaces/i_video_feed_repository.dart';
import 'package:flutter_video_feed/domain/models/video_item.dart';

class VideoFeedRepository implements IVideoFeedRepository {
  VideoFeedRepository(this._firestore);

  final FirebaseFirestore _firestore;
  final String _collectionPath = 'videos';

  // Cursor for pagination.
  late DocumentSnapshot? _lastDocument;

  @override
  Future<List<VideoItem>> fetchVideos() async {
    try {
      final snapshot =
          await _firestore
              .collection(_collectionPath)
              .orderBy('timestamp', descending: false)
              .orderBy(FieldPath.documentId, descending: false)
              .limit(2)
              .get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }
      return snapshot.docs.map((doc) => VideoItem.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error fetching videos: $e');
    }
  }

  @override
  Future<List<VideoItem>> fetchMoreVideos({required VideoItem lastVideo}) async {
    if (_lastDocument == null) return [];
    try {
      final snapshot =
          await _firestore
              .collection(_collectionPath)
              .orderBy('timestamp', descending: false)
              .orderBy(FieldPath.documentId, descending: false)
              .startAfterDocument(_lastDocument!)
              .limit(2)
              .get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }
      return snapshot.docs.map((doc) => VideoItem.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Error fetching more videos: $e');
    }
  }
}
