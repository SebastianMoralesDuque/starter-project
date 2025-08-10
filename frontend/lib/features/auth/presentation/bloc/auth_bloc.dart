import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_google_use_case.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/article/domain/repository/article_repository.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignOutUseCase _signOutUseCase;
  final ArticleRepository _articleRepository;

  AuthBloc(this._signInWithGoogleUseCase, this._signOutUseCase, this._articleRepository) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SignInEvent>(_onSignInEvent);
    on<SignOutEvent>(_onSignOutEvent);
  }

  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthUnauthenticated());
  }

  void _onSignInEvent(SignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _signInWithGoogleUseCase();
      if (result.data != null) {
        emit(AuthAuthenticated(result.data!));
      } else {
        emit(AuthError(result.error?.toString() ?? 'Error desconocido al iniciar sesión'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }


  void _onSignOutEvent(SignOutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _signOutUseCase();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}

