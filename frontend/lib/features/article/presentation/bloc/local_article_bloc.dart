import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/article/presentation/bloc/local_article_event.dart';
import 'package:news_app_clean_architecture/features/article/presentation/bloc/local_article_state.dart';

import '../../domain/use_cases/get_saved_article.dart';
import '../../domain/use_cases/remove_article.dart';
import '../../domain/use_cases/toggle_bookmark_use_case.dart';

class LocalArticleBloc extends Bloc<LocalArticlesEvent,LocalArticlesState> {
  final GetSavedArticleUseCase _getSavedArticleUseCase;
  final RemoveArticleUseCase _removeArticleUseCase;
  final ToggleBookmarkUseCase _toggleBookmarkUseCase;

  LocalArticleBloc(
    this._getSavedArticleUseCase,
    this._removeArticleUseCase,
    this._toggleBookmarkUseCase,
  ) : super(const LocalArticlesLoading()){
    on <GetSavedArticles> (onGetSavedArticles);
    on <RemoveArticle> (onRemoveArticle);
    on <BookmarkArticle> (onBookmarkArticle);
  }


  void onGetSavedArticles(GetSavedArticles event,Emitter<LocalArticlesState> emit) async {
    final stream = await _getSavedArticleUseCase();
    await emit.forEach(
      stream,
      onData: (articles) => LocalArticlesDone(articles),
    );
  }
  
  void onRemoveArticle(RemoveArticle removeArticle,Emitter<LocalArticlesState> emit) async {
    await _removeArticleUseCase(params: removeArticle.article);
  }

  void onBookmarkArticle(BookmarkArticle event, Emitter<LocalArticlesState> emit) async {
    try {
      await _toggleBookmarkUseCase(params: event.article);
      emit(const LocalArticleBookmarked());
    } catch (e) {
      emit(LocalArticleError(e.toString()));
    }
  }
}