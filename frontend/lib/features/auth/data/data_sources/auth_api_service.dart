import 'package:firebase_auth/firebase_auth.dart'; // Importar User de Firebase Auth

abstract class AuthApiService {
  Future<User> signInWithGoogle();
  Future<void> signOut();
  Future<User?> getCurrentUser();
}