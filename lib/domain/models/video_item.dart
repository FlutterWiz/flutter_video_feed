import 'package:cloud_firestore/cloud_firestore.dart';

/// VideoItem model represents the video metadata used in the app.
class VideoItem {
  final String id;
  final String username;
  final String description;
  final String videoUrl;
  final String profileImageUrl;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isBookmarked;
  final bool isLiked;
  final DateTime timestamp;

  VideoItem({
    required this.id,
    required this.username,
    required this.description,
    required this.videoUrl,
    required this.profileImageUrl,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.isBookmarked,
    required this.isLiked,
    required this.timestamp,
  });

  /// Factory constructor to create a VideoItem from a Firestore DocumentSnapshot.
  factory VideoItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return VideoItem(
      id: doc.id,
      username: data['username'] is String ? data['username'] as String : '',
      description: data['description'] is String ? data['description'] as String : '',
      videoUrl: data['videoUrl'] is String ? data['videoUrl'] as String : '',
      profileImageUrl: data['profileImageUrl'] is String ? data['profileImageUrl'] as String : '',
      likeCount: _safeInt(data['likeCount']),
      commentCount: _safeInt(data['commentCount']),
      shareCount: _safeInt(data['shareCount']),
      isBookmarked: _safeBool(data['isBookmarked']),
      isLiked: _safeBool(data['isLiked']),
      timestamp: data['timestamp'] is Timestamp ? (data['timestamp'] as Timestamp).toDate() : DateTime.now(),
    );
  }
}

/// Helper function to safely convert a dynamic value to an int.
int _safeInt(dynamic value, {int defaultValue = 0}) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

/// Helper function to safely convert a dynamic value to a bool.
bool _safeBool(dynamic value, {bool defaultValue = false}) {
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  return defaultValue;
}
