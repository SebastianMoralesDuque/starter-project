import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/article/domain/entities/article.dart';

enum DateFilter { last24Hours, last7Days, lastMonth, all }

abstract class RemoteArticlesEvent extends Equatable {
  const RemoteArticlesEvent();

  @override
  List<Object?> get props => [];
}

class GetArticles extends RemoteArticlesEvent {
  const GetArticles();
}

class SaveArticle extends RemoteArticlesEvent {
  final ArticleEntity article;

  const SaveArticle(this.article);

  @override
  List<Object?> get props => [article];
}

class FilterArticles extends RemoteArticlesEvent {
  final String searchQuery;
  final DateFilter dateFilter;

  const FilterArticles({required this.searchQuery, required this.dateFilter});

  @override
  List<Object?> get props => [searchQuery, dateFilter];
}

class StopListeningToArticles extends RemoteArticlesEvent {
  const StopListeningToArticles();
}