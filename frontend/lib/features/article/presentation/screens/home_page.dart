import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/article/presentation/screens/daily_news.dart';
import 'package:news_app_clean_architecture/features/article/presentation/screens/saved_article.dart';
import 'package:news_app_clean_architecture/features/article/presentation/screens/add_article_page.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/screens/auth_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: <Widget>[
            _buildDashboardItem(context, 'Noticias Diarias', Icons.article_outlined, '/DailyNews'),
            _buildDashboardItem(context, 'Artículos Guardados', Icons.bookmark_border, '/SavedArticles'),
            _buildDashboardItem(context, 'Añadir Noticia', Icons.add_circle_outline, '/AddArticle'),
            _buildDashboardItem(context, 'Autenticación', Icons.login_outlined, '/Auth'),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardItem(BuildContext context, String title, IconData icon, String routeName) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      color: theme.colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, routeName),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}