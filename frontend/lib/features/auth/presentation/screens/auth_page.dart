import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/article/presentation/screens/daily_news.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  String? _errorMessage;


  void _signInWithGoogle() {
    context.read<AuthBloc>().add(SignInEvent());
  }

  void _signOut() {
    context.read<AuthBloc>().add(SignOutEvent());
  }

  void _signInAnonymously() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const DailyNews(isGuest: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              setState(() {
                _errorMessage = state.error;
              });
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 100,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Bienvenido a Noticias',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tu fuente diaria de información',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 40),
                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (state is AuthAuthenticated) ...[
                      CircleAvatar(
                        backgroundImage: NetworkImage(state.user!.photoURL ?? ''),
                        radius: 40,
                      ),
                      const SizedBox(height: 10),
                      Text('Hola, ${state.user!.displayName ?? 'Usuario'}'),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _signOut,
                        child: const Text('Cerrar sesión'),
                      ),
                    ] else ...[
                      ElevatedButton.icon(
                        icon: const Icon(Icons.login), // Placeholder for Google icon
                        onPressed: _signInWithGoogle,
                        label: const Text('Iniciar sesión con Google'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _signInAnonymously,
                        child: const Text('Entrar como Invitado'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
