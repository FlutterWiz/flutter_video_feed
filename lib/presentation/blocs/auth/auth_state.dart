import 'package:equatable/equatable.dart';
import 'package:flutter_video_feed/domain/models/user.dart';

class AuthState extends Equatable {
  const AuthState({
    this.user = const User(email: '', uid: ''),
    this.error = '',
    this.isLoading = false,
    this.isLoggedIn = false,
  });

  final User user;
  final String error;
  final bool isLoading;
  final bool isLoggedIn;

  @override
  List<Object> get props => [user, error, isLoading, isLoggedIn];

  AuthState copyWith({User? user, String? error, bool? isLoading, bool? isLoggedIn}) {
    return AuthState(
      user: user ?? this.user,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  factory AuthState.initial() => const AuthState();
}
