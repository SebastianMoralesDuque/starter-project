import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  final UserEntity? user;
  final String? error;

  const AuthState({this.user, this.error});

  @override
  List<Object?> get props => [user, error];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(UserEntity user) : super(user: user);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  const AuthError(String error) : super(error: error);
}