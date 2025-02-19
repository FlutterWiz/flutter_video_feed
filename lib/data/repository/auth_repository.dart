import 'package:flutter_video_feed/core/interfaces/i_auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository implements IAuthRepository {
  AuthRepository(this.firebaseAuth);

  final FirebaseAuth firebaseAuth;

  @override
  Future<UserCredential> createUserWithEmailAndPassword({required String email, required String password}) {
    return firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({required String email, required String password}) {
    return firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return firebaseAuth.signOut();
  }
}
