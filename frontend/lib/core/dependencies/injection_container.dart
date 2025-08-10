import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:news_app_clean_architecture/features/auth/data/data_sources/auth_api_service.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/auth_api_service_impl.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/data/repository/auth_repository_impl.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_google_use_case.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/article/data/data_sources/remote/firestore_api_service.dart';
import 'package:news_app_clean_architecture/features/article/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/article/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/article/domain/use_cases/get_article.dart';
import 'package:news_app_clean_architecture/features/article/presentation/bloc/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/article/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/article/domain/use_cases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/article/domain/use_cases/remove_article.dart';
import 'package:news_app_clean_architecture/features/article/domain/use_cases/create_article.dart';
import 'package:news_app_clean_architecture/features/article/domain/use_cases/toggle_bookmark_use_case.dart';
import 'package:news_app_clean_architecture/features/article/presentation/bloc/local_article_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {

  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);
  
  // Dio

  // Firebase
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<GoogleSignIn>(GoogleSignIn());
  sl.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);

  // Dependencies
  sl.registerSingleton<FirestoreApiService>(FirestoreApiServiceImpl(FirebaseFirestore.instance, sl()));

  sl.registerSingleton<ArticleRepository>(
    ArticleRepositoryImpl(sl(), sl(), sl())
  );
  
  //UseCases
  sl.registerSingleton<GetArticleUseCase>(
    GetArticleUseCase(sl())
  );

  sl.registerSingleton<GetSavedArticleUseCase>(
    GetSavedArticleUseCase(sl())
  );

  sl.registerSingleton<CreateArticleUseCase>(
    CreateArticleUseCase(sl())
  );
  
  sl.registerSingleton<RemoveArticleUseCase>(
    RemoveArticleUseCase(sl())
  );

  sl.registerSingleton<ToggleBookmarkUseCase>(
    ToggleBookmarkUseCase(sl())
  );




  // Dependencies (Auth Feature)
  sl.registerSingleton<AuthApiService>(AuthApiServiceImpl(sl(), sl()));
  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(sl())
  );

  // UseCases (Auth Feature)
  sl.registerSingleton<SignInWithGoogleUseCase>(
    SignInWithGoogleUseCase(sl())
  );
  sl.registerSingleton<SignOutUseCase>(
    SignOutUseCase(sl())
  );

  // Blocs (Article Feature)
  sl.registerFactory<RemoteArticlesBloc>(
    ()=> RemoteArticlesBloc(sl(), sl(), sl())
  );
  sl.registerFactory<LocalArticleBloc>(
    ()=> LocalArticleBloc(sl(),sl(),sl())
  );

  // Blocs (Auth Feature)
  sl.registerFactory<AuthBloc>(
    ()=> AuthBloc(sl(), sl(), sl())
  );

  // Blocs (Theme)
  sl.registerFactory<ThemeCubit>(
    ()=> ThemeCubit()
  );
}