import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:news_app_clean_architecture/core/dependencies/injection_container.dart'; 
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/core/resources/firebase_options.dart'; 
import 'package:news_app_clean_architecture/features/auth/presentation/screens/auth_page.dart';
import 'package:news_app_clean_architecture/features/article/presentation/bloc/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/article/presentation/screens/daily_news.dart';
import 'package:news_app_clean_architecture/features/article/presentation/bloc/local_article_bloc.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/config/theme/theme_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDependencies(); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RemoteArticlesBloc>(
          create: (context) => sl(),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => sl()..add(AppStarted()),
        ),
        BlocProvider<LocalArticleBloc>(
          create: (context) => sl(),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => sl(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Firebase Auth Example',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            onGenerateRoute: AppRoutes.onGenerateRoutes,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return const DailyNews();
                } else {
                  return const AuthPage();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
