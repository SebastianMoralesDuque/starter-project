import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_event.dart';
import 'package:news_app_clean_architecture/features/article/presentation/bloc/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/article/presentation/bloc/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/article/presentation/bloc/remote_article_state.dart';

import '../../domain/entities/article.dart';
import '../widgets/article_tile.dart';
import '../widgets/article_tile_skeleton.dart';
import 'package:shimmer/shimmer.dart';
import '../../../auth/presentation/screens/auth_page.dart';
import '../../../../config/theme/theme_cubit.dart';

class DailyNews extends StatefulWidget {
  final bool isGuest;
  const DailyNews({super.key, this.isGuest = false});

  @override
  State<DailyNews> createState() => _DailyNewsState();
}

class _DailyNewsState extends State<DailyNews> {
  final TextEditingController _searchController = TextEditingController();
  DateFilter _selectedFilter = DateFilter.all;

  @override
  void initState() {
    super.initState();
    context.read<RemoteArticlesBloc>().add(const GetArticles());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFilterChanged(DateFilter filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _filterArticles();
  }

  void _filterArticles() {
    context.read<RemoteArticlesBloc>().add(
          FilterArticles(
            searchQuery: _searchController.text,
            dateFilter: _selectedFilter,
          ),
        );
  }

  PreferredSizeWidget _buildAppbar(BuildContext context) {
    return AppBar(
      title: const Text('Noticias Diarias'),
      actions: _buildAppBarActions(context),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    List<Widget> actions = [
      PopupMenuButton<DateFilter>(
        onSelected: _onFilterChanged,
        icon: const Icon(Icons.filter_list),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<DateFilter>>[
          const PopupMenuItem<DateFilter>(
            value: DateFilter.all,
            child: Text('Todos'),
          ),
          const PopupMenuItem<DateFilter>(
            value: DateFilter.last24Hours,
            child: Text('Últimas 24 horas'),
          ),
          const PopupMenuItem<DateFilter>(
            value: DateFilter.last7Days,
            child: Text('Últimos 7 días'),
          ),
          const PopupMenuItem<DateFilter>(
            value: DateFilter.lastMonth,
            child: Text('Último mes'),
          ),
        ],
      ),
      IconButton(
        icon: const Icon(Icons.brightness_6),
        onPressed: () {
          context.read<ThemeCubit>().setTheme(
                Theme.of(context).brightness == Brightness.dark
                    ? ThemeModeOption.light
                    : ThemeModeOption.dark,
              );
        },
      ),
    ];

    if (widget.isGuest) {
      actions.add(
        TextButton(
          onPressed: () => _onSignInTapped(context),
          child: const Text('Iniciar Sesión'),
        ),
      );
    } else {
      actions.addAll([
        GestureDetector(
          onTap: () => _onShowSavedArticlesViewTapped(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.bookmark),
          ),
        ),
        GestureDetector(
          onTap: _signOut,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.logout),
          ),
        ),
      ]);
    }

    return actions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(context),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
              builder: (context, state) {
                if (state is RemoteArticlesLoading) {
            return Shimmer.fromColors(
              baseColor: Theme.of(context).colorScheme.surfaceVariant,
              highlightColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 5,
                itemBuilder: (context, index) => const ArticleTileSkeleton(),
              ),
            );
          }
          if (state is RemoteArticlesError) {
            return Center(child: Text('Error: ${state.error ?? "Unknown error"}'));
          }
          if (state is RemoteArticlesDone) {
            if (state.articles!.isEmpty) {
              return const Center(child: Text('No hay noticias disponibles.'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<RemoteArticlesBloc>().add(const GetArticles());
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: state.articles!.length,
                  itemBuilder: (context, index) {
                    final article = state.articles![index];
                    return ArticleWidget(
                      article: article,
                      onArticlePressed: (article) =>
                          _onArticlePressed(context, article),
                    );
                  },
                ),
              ),
            );
          }
          return const SizedBox();
        },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isGuest
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/AddArticle');
              },
              child: const Icon(Icons.add),
            ),
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: {'article': article, 'isGuest': widget.isGuest});
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, '/SavedArticles');
  }


  void _signOut() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                context.read<RemoteArticlesBloc>().add(const StopListeningToArticles());
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(SignOutEvent());
              },
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }

  void _onSignInTapped(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => _filterArticles(),
        decoration: InputDecoration(
          labelText: 'Buscar por título',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
