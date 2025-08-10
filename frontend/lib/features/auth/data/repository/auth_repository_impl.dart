import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/auth_api_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/models/user_model.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _authApiService;

  AuthRepositoryImpl(this._authApiService);

  @override
  Future<DataState<UserEntity>> signInWithGoogle() async {
    try {
      final user = await _authApiService.signInWithGoogle();
      return DataSuccess(UserModel.fromFirebaseUser(user));
    } on DioException catch (e) {
      return DataFailed(e);
    } catch (e) {
      return DataFailed(DioException(requestOptions: RequestOptions(path: ''), error: e.toString()));
    }
  }

  @override
  Future<void> signOut() async {
    await _authApiService.signOut();
  }


  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = await _authApiService.getCurrentUser();
    if (user != null) {
      return UserModel.fromFirebaseUser(user);
    }
    return null;
  }
}