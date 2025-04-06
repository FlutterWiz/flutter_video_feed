# Flutter Video Feed

**Flutter Video Feed** is an open-source Flutter project that demonstrates how to build a performant social media-style video feed similar to TikTok, Instagram Reels, or YouTube Shorts. The project showcases video handling, memory management, and smooth scrolling using MVVM architecture.

## 🎥 Showcase

Coming Soon

## ✨ Features

* **High-Performance Video Playback**
  * Smart video controller management
  * Efficient memory usage with controller limiting
  * Smooth scrolling with preloading
  * Optimized video state management

* **MVVM Architecture**
  * Clean separation of concerns
  * Dependency injection using `get_it`
  * Repository pattern for data handling
  * BLoC pattern for state management

* **Firebase Integration**
  * Cloud Firestore for video data
  * Firebase Storage for video files
  * Efficient video caching
  * Real-time updates

* **Performance Optimizations**
  * Smart controller lifecycle management
  * Efficient memory cleanup
  * Debounced scroll handling
  * RepaintBoundary optimizations

## 📦 Packages Used

* **State Management & DI**
  * `flutter_bloc` - For state management
  * `get_it` - For dependency injection
  * `equatable` - For value equality

* **Video & UI**
  * `video_player` - For video playback
  * `preload_page_view` - For smooth scrolling
  * `cached_network_image` - For image caching

* **Firebase**
  * `firebase_core`
  * `firebase_storage`
  * `cloud_firestore`

## 🏗 Project Structure

The project follows a clean architecture approach:

```
lib/
├─ core/
│  ├─ services/
│  ├─ utils/
│  ├─ constants/
│  ├─ di/
│  ├─ init/
│  ├─ interfaces/
├─ data/
│  ├─ repository/
├─ domain/
│  ├─ models/
├─ presentation/
│  ├─ views/
│  ├─ blocs/
│  ├─ design_system/
│  ├─ l10/
├─ main.dart
```

## 📱 Usage

The video feed implements several key features:

* **Smooth Scrolling**
  * Vertical scrolling similar to TikTok
  * Automatic video playback on visibility
  * Smart preloading of adjacent videos

* **Memory Management**
  * Maximum of 3 video controllers at any time
  * Automatic cleanup of unused controllers
  * Efficient resource management

* **Performance**
  * Optimized rebuilds
  * Efficient state updates
  * Smart video quality management

## 📚 Tutorials

* **YouTube Videos** 🎥
  * Coming Soon

* **Medium Article** ✍️
  * Coming Soon

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

FlutterWiz - Alper Efe Sahin
- GitHub: [@FlutterWiz](https://github.com/FlutterWiz)
- Medium: [Coming Soon]
- YouTube: [Coming Soon]
 
