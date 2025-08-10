import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/article/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/article/domain/repository/article_repository.dart';

class ToggleBookmarkUseCase implements UseCase<void, ArticleEntity> {
  final ArticleRepository _articleRepository;

  ToggleBookmarkUseCase(this._articleRepository);

  @override
  Future<void> call({ArticleEntity? params}) {
    return _articleRepository.toggleBookmark(params!);
  }
}