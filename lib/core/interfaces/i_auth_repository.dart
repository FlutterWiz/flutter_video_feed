import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthRepository {
  Future<UserCredential> createUserWithEmailAndPassword({required String email, required String password});

  Future<UserCredential> signInWithEmailAndPassword({required String email, required String password});

  Future<void> signOut();
}
