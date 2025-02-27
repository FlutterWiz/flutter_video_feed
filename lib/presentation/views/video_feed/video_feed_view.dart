import 'package:flutter/material.dart';
import 'package:flutter_video_feed/domain/models/video_item.dart';
import 'package:flutter_video_feed/presentation/design_system/widgets/bare_bones_scaffold.dart';
import 'package:flutter_video_feed/presentation/views/video_feed/widgets/video_feed_item.dart';

class VideoFeedView extends StatefulWidget {
  const VideoFeedView({super.key});

  @override
  State<VideoFeedView> createState() => _VideoFeedViewState();
}

class _VideoFeedViewState extends State<VideoFeedView> {
  late List<VideoItem> videoItemList;
  late List<bool> likedStates;
  late List<int> likeCounts;
  late List<bool> bookmarkedStates;

  @override
  void initState() {
    super.initState();
    videoItemList = List.from(videoItems);
    likedStates = videoItemList.map((video) => video.isLiked).toList();
    likeCounts = videoItemList.map((video) => video.likeCount).toList();
    bookmarkedStates = videoItemList.map((video) => video.isBookmarked).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BareBonesScaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videoItemList.length,
        onPageChanged: (index) {
          // Handle video preload or analytics here
        },
        itemBuilder: (context, index) {
          final videoItem = videoItemList[index];

          return VideoFeedItem(
            likeCount: likeCounts[index],
            commentCount: videoItem.commentCount,
            shareCount: videoItem.shareCount,
            isLiked: likedStates[index],
            isBookmarked: bookmarkedStates[index],
            profileImageUrl: videoItem.profileImageUrl,
            username: videoItem.username,
            description: videoItem.description,
            likeOnPressed: () {
              setState(() {
                if (likedStates[index]) {
                  likedStates[index] = false;
                  likeCounts[index]--;
                } else {
                  likedStates[index] = true;
                  likeCounts[index]++;
                }
              });
              // TODO: Call Firebase update method (optimistic UI update)
            },
            bookmarkOnPressed: () {
              setState(() {
                bookmarkedStates[index] = !bookmarkedStates[index];
              });
              // TODO: Call Firebase bookmark update (optimistic UI update)
            },
          );
        },
      ),
    );
  }
}
