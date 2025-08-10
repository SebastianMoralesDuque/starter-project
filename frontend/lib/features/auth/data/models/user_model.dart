import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    super.uid,
    super.email,
    super.displayName,
    super.photoURL,
  });

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      photoURL: entity.photoURL,
    );
  }
}