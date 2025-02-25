import 'package:flutter_video_feed/core/interfaces/i_auth_repository.dart';
import 'package:flutter_video_feed/domain/models/video_item.dart';
import 'package:flutter_video_feed/presentation/blocs/auth/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.authRepo) : super(AuthState.initial());

  final IAuthRepository authRepo;

  Future<void> createUserWithEmailAndPassword({required String email, required String password}) async {
    emit(state.copyWith(isLoading: true));

    try {
      // to show properly, the loading indicator is working
      await Future.delayed(const Duration(seconds: 2));

      final userCredential = await authRepo.createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        final user = User(email: userCredential.user?.email ?? '', uid: userCredential.user?.uid ?? '');
        emit(state.copyWith(isLoading: false, user: user));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> signInWithEmailAndPassword({required String email, required String password}) async {
    emit(state.copyWith(isLoading: true));

    try {
      // to show properly, the loading indicator is working
      await Future.delayed(const Duration(seconds: 2));

      final userCredential = await authRepo.signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        final user = User(email: userCredential.user?.email ?? '', uid: userCredential.user?.uid ?? '');
        emit(state.copyWith(isLoading: false, user: user, isLoggedIn: true));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString(), isLoggedIn: false));
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(isLoading: true));

    try {
      // to show properly, the loading indicator is working
      await Future.delayed(const Duration(seconds: 2));

      await authRepo.signOut();

      emit(state.copyWith(isLoading: false, isLoggedIn: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
