import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<DataState<UserEntity>> signInWithGoogle();
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
}