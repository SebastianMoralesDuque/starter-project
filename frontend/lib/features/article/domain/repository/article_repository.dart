import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/article/domain/entities/article.dart';

abstract class ArticleRepository {
  Stream<DataState<List<ArticleEntity>>> getNewsArticles();

  Stream<List<ArticleEntity>> getSavedArticles();

  Future < void > createArticle(ArticleEntity article);
  Future < void > toggleBookmark(ArticleEntity article);
  Future < void > removeArticle(ArticleEntity article);
  void dispose();
}