import 'package:flutter/material.dart';

import '../../features/article/domain/entities/article.dart';
import '../../features/article/presentation/screens/article_detail.dart';
import '../../features/article/presentation/screens/daily_news.dart';
import '../../features/article/presentation/screens/saved_article.dart';
import '../../features/article/presentation/screens/add_article_page.dart';
import '../../features/auth/presentation/screens/auth_page.dart';


class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _materialRoute(const DailyNews());
      
      case '/DailyNews':
        return _materialRoute(const DailyNews());

      case '/ArticleDetails':
        final args = settings.arguments as Map<String, dynamic>;
        return _materialRoute(ArticleDetailsView(
          article: args['article'] as ArticleEntity,
          isGuest: args['isGuest'] as bool,
        ));

      case '/SavedArticles':
        return _materialRoute(const SavedArticles());


      case '/AddArticle':
        return _materialRoute(const AddArticlePage());

      case '/Auth':
        return _materialRoute(const AuthPage());
        
      default:
        return _materialRoute(const AuthPage());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}
