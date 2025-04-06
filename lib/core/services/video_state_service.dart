import 'package:flutter_video_feed/core/constants/enums/video_quality_enum.dart';

/// Service to manage video states and improve performance
class VideoStateService {
  final _videoStates = <String, _VideoState>{};

  void markVideoVisible(String videoId) {
    _videoStates[videoId] = _videoStates[videoId] ?? _VideoState();
    _videoStates[videoId]!.isVisible = true;
  }

  void markVideoInvisible(String videoId) {
    _videoStates[videoId] = _videoStates[videoId] ?? _VideoState();
    _videoStates[videoId]!.isVisible = false;
  }

  bool isVideoVisible(String videoId) {
    return _videoStates[videoId]?.isVisible ?? false;
  }

  void updatePlaybackQuality(String videoId, double visibility) {
    final state = _videoStates[videoId];
    if (state == null) return;

    // Adjust quality based on visibility
    if (visibility > 0.8) {
      state.quality = VideoQualityEnum.high;
    } else if (visibility > 0.5) {
      state.quality = VideoQualityEnum.medium;
    } else {
      state.quality = VideoQualityEnum.low;
    }
  }

  VideoQualityEnum getVideoQuality(String videoId) {
    return _videoStates[videoId]?.quality ?? VideoQualityEnum.medium;
  }

  void clear() {
    _videoStates.clear();
  }
}

class _VideoState {
  bool isVisible = false;
  VideoQualityEnum quality = VideoQualityEnum.medium;
}
