import 'package:floor/floor.dart';
import 'package:news_app_clean_architecture/features/article/data/models/article.dart';

@dao
abstract class ArticleDao {
  
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertArticle(ArticleModel article);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertArticles(List<ArticleModel> articles);
  
  @delete
  Future<void> deleteArticle(ArticleModel articleModel);
  
  @Query('SELECT * FROM article')
  Stream<List<ArticleModel>> getArticles();

  @Query('DELETE FROM article')
  Future<void> deleteAllArticles();

}