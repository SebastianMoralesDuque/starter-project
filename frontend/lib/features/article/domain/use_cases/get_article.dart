import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/article/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/article/domain/repository/article_repository.dart';

class GetArticleUseCase implements UseCase<Stream<DataState<List<ArticleEntity>>>,void>{
  
  final ArticleRepository _articleRepository;

  GetArticleUseCase(this._articleRepository);
  
  @override
  Future<Stream<DataState<List<ArticleEntity>>>> call({void params}) async {
    return _articleRepository.getNewsArticles();
  }
  
}