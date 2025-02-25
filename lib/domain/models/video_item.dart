class User {
  final String email;
  final String uid;

  const User({required this.email, required this.uid});
}

class VideoItem {
  final String username;
  final String description;
  final String imageUrl;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isBookmarked;
  final bool isLiked;

  VideoItem({
    required this.username,
    required this.description,
    required this.imageUrl,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.isBookmarked,
    required this.isLiked,
  });
}

/// Sample list of video items (update the image URLs as needed)
final List<VideoItem> videoItems = [
  VideoItem(
    username: 'john_doe',
    description:
        'Check out my new dance movesCheck out my new dance movesCheck out my new dance movesCheck out my new dance movesCheck out my new dance movesCheck out my new dance movesCheck out my new dance movesCheck out my new dance movesCheck out my new dance moves!',
    imageUrl: 'https://picsum.photos/200',
    likeCount: 123,
    commentCount: 45,
    shareCount: 67,
    isBookmarked: false,
    isLiked: true,
  ),
  VideoItem(
    username: 'jane_doe',
    description: 'Beautiful sunset at the beach.',
    imageUrl: 'https://picsum.photos/200',
    likeCount: 456,
    commentCount: 78,
    shareCount: 89,
    isBookmarked: true,
    isLiked: false,
  ),
  VideoItem(
    username: 'alex_smith',
    description: 'Loving the vibes in this city!',
    imageUrl: 'https://picsum.photos/200',
    likeCount: 234,
    commentCount: 56,
    shareCount: 34,
    isBookmarked: false,
    isLiked: false,
  ),
  VideoItem(
    username: 'emma_watson',
    description: 'A glimpse into my daily routine.',
    imageUrl: 'https://picsum.photos/200',
    likeCount: 345,
    commentCount: 67,
    shareCount: 78,
    isBookmarked: true,
    isLiked: true,
  ),
  VideoItem(
    username: 'chris_evans',
    description: 'Adventure time!',
    imageUrl: 'https://picsum.photos/200',
    likeCount: 567,
    commentCount: 89,
    shareCount: 90,
    isBookmarked: false,
    isLiked: false,
  ),
];
