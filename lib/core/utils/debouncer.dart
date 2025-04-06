import 'dart:async';
import 'package:flutter/foundation.dart';

/// A utility class that helps to debounce repeated actions by introducing a delay.
/// 
/// This is particularly useful for:
/// - Preventing multiple rapid-fire events (like scroll events)
/// - Reducing API calls
/// - Optimizing performance for frequent state changes
/// 
class Debouncer {
  /// The duration to wait before executing the action
  final int milliseconds;
  
  /// Internal timer that manages the delay
  Timer? _timer;

  /// Creates a new Debouncer instance with the specified delay
  /// 
  /// [milliseconds] is the amount of time to wait after the last call
  /// before executing the action
  Debouncer({required this.milliseconds});

  /// Runs the provided action after the specified delay
  /// 
  /// If [run] is called again before the delay has expired,
  /// the previous action is cancelled and a new delay starts
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Cancels any pending actions and cleans up resources
  /// 
  /// Should be called when the debouncer is no longer needed
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
} 