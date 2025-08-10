import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/article/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/article/domain/repository/article_repository.dart';

class GetSavedArticleUseCase implements UseCase<Stream<List<ArticleEntity>>,void>{
  
  final ArticleRepository _articleRepository;

  GetSavedArticleUseCase(this._articleRepository);
  
  @override
  Future<Stream<List<ArticleEntity>>> call({void params}) async {
    return _articleRepository.getSavedArticles();
  }
  
}