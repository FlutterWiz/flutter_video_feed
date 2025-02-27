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
    );
  }

  /// Converts the VideoItem instance into a Map.
  /// This is used when saving/updating the document in Firestore.
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'description': description,
      'videoUrl': videoUrl,
      'profileImageUrl': profileImageUrl,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'shareCount': shareCount,
      'isBookmarked': isBookmarked,
      'isLiked': isLiked,
    };
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

/// Sample list of video items (update the image URLs as needed)
final List<VideoItem> videoItems = [
  VideoItem(
    username: 'efesahin',
    description:
        'Check out my new dance movesCheck out my new dance movesCheck out my new dance movesCheck out my new dance movesCheck out my new dance movesCheck out my new dance movesCheck out my new dance movesCheck out my new dance movesCheck out my new dance moves!',
    id: '5',
    videoUrl: 'try',
    profileImageUrl: 'https://picsum.photos/200',
    likeCount: 123,
    commentCount: 45,
    shareCount: 67,
    isBookmarked: false,
    isLiked: true,
  ),
  VideoItem(
    username: 'jane_doe',
    description: 'Beautiful sunset at the beach.',
    id: '4',
    videoUrl: 'try',
    profileImageUrl: 'https://picsum.photos/200',
    likeCount: 456,
    commentCount: 78,
    shareCount: 89,
    isBookmarked: true,
    isLiked: false,
  ),
  VideoItem(
    username: 'alex_smith',
    description: 'Loving the vibes in this city!',
    id: '3',
    videoUrl: 'try',
    profileImageUrl: 'https://picsum.photos/200',
    likeCount: 234,
    commentCount: 56,
    shareCount: 34,
    isBookmarked: false,
    isLiked: false,
  ),
  VideoItem(
    username: 'emma_watson',
    description: 'A glimpse into my daily routine.',
    id: '2',
    videoUrl: 'try',
    profileImageUrl: 'https://picsum.photos/200',
    likeCount: 345,
    commentCount: 67,
    shareCount: 78,
    isBookmarked: true,
    isLiked: true,
  ),
  VideoItem(
    username: 'chris_evans',
    description: 'Adventure time!',
    likeCount: 567,
    commentCount: 89,
    shareCount: 90,
    isBookmarked: false,
    isLiked: false,
    id: '1',
    videoUrl: 'try',
    profileImageUrl: 'https://picsum.photos/200',
  ),
];
