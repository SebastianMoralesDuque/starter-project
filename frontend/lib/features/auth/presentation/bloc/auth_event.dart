import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}
class SignInEvent extends AuthEvent {}
class SignInAnonymouslyEvent extends AuthEvent {}
class SignOutEvent extends AuthEvent {}