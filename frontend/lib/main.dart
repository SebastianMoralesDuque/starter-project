import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Importar flutter_bloc
import 'package:news_app_clean_architecture/injection_container.dart'; // Importar el contenedor de inyección de dependencias
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'firebase_options.dart'; // Generado con flutterfire CLI
import 'package:firebase_auth/firebase_auth.dart'; // Importar FirebaseAuth

import 'features/daily_news/presentation/pages/auth/auth_page.dart'; // Importar AuthPage
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/daily_news/presentation/pages/home/daily_news.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Activar App Check en modo debug (cambiar en producción)

  await initializeDependencies(); // Inicializar las dependencias

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RemoteArticlesBloc>(
          create: (context) => sl()..add(const GetArticles()),
        ),
      ],
      child: MaterialApp(
        title: 'Firebase Auth Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        onGenerateRoute: AppRoutes.onGenerateRoutes,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              return const DailyNews();
            }
            return const AuthPage();
          },
        ),
      ),
    );
  }
}
