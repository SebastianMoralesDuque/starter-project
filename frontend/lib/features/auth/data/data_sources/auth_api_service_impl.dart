import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/auth_api_service.dart';

class AuthApiServiceImpl implements AuthApiService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthApiServiceImpl(this._auth, this._googleSignIn);

  @override
  Future<User> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google Sign-In aborted by user');
    }
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user!;
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }
}