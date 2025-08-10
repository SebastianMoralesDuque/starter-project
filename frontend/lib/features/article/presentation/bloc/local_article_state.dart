import 'package:equatable/equatable.dart';

import 'package:news_app_clean_architecture/features/article/domain/entities/article.dart';

abstract class LocalArticlesState extends Equatable {
  final List<ArticleEntity> ? articles;

  const LocalArticlesState({this.articles});

  @override
  List<Object> get props => [articles!];
}

class LocalArticlesLoading extends LocalArticlesState {
  const LocalArticlesLoading();
}

class LocalArticlesDone extends LocalArticlesState {
  const LocalArticlesDone(List<ArticleEntity> articles) : super(articles: articles);
}

class LocalArticleBookmarked extends LocalArticlesState {
  const LocalArticleBookmarked();
}

class LocalArticleError extends LocalArticlesState {
  final String error;
  const LocalArticleError(this.error);

  @override
  List<Object> get props => [error];
}