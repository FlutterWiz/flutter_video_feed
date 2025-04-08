import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_video_feed/core/interfaces/i_video_feed_repository.dart';
import 'package:flutter_video_feed/domain/models/video_item.dart';

class VideoFeedRepository implements IVideoFeedRepository {
  VideoFeedRepository(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentSnapshot? _lastDocument;

  @override
  Future<List<VideoItem>> fetchVideos() async {
    try {
      return await _fetchVideosHelper();
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch videos from Firestore: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while fetching videos: $e');
    }
  }

  @override
  Future<List<VideoItem>> fetchMoreVideos({required VideoItem lastVideo}) async {
    if (_lastDocument == null) {
      return [];
    }

    try {
      return await _fetchVideosHelper(startAfterDocument: _lastDocument);
    } on FirebaseException catch (e) {
      throw Exception('Failed to fetch more videos from Firestore: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while fetching more videos: $e');
    }
  }

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
    } on FirebaseException catch (e) {
      throw Exception('Firestore error while fetching videos: ${e.message}');
    } catch (e) {
      throw Exception('Error processing video data: $e');
    }
  }
}
