import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/article/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/article/domain/use_cases/get_article.dart';
import 'package:news_app_clean_architecture/features/article/domain/use_cases/create_article.dart';
import 'package:news_app_clean_architecture/features/article/presentation/bloc/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/article/presentation/bloc/remote_article_state.dart';
import '../../domain/entities/article.dart';

class RemoteArticlesBloc extends Bloc<RemoteArticlesEvent,RemoteArticlesState> {
  
  final GetArticleUseCase _getArticleUseCase;
  final CreateArticleUseCase _createArticleUseCase;
  final ArticleRepository _articleRepository;

  List<ArticleEntity> _allArticles = [];
  
  RemoteArticlesBloc(this._getArticleUseCase, this._createArticleUseCase, this._articleRepository) : super(const RemoteArticlesLoading()){
    on <GetArticles> (onGetArticles);
    on <SaveArticle> (onSaveArticle);
    on <FilterArticles> (onFilterArticles);
    on <StopListeningToArticles> (onStopListeningToArticles);
  }


  void onGetArticles(GetArticles event, Emitter < RemoteArticlesState > emit) async {
    final dataStateStream = await _getArticleUseCase();

    await emit.forEach(
      dataStateStream,
      onData: (dataState) {
        if (dataState is DataSuccess) {
          _allArticles = dataState.data!;
          return RemoteArticlesDone(_allArticles);
        } else if (dataState is DataFailed) {
          return RemoteArticlesError(dataState.error!.toString());
        }
        return state;
      },
      onError: (error, stackTrace) => RemoteArticlesError(error.toString()),
    );
  }

  void onFilterArticles(FilterArticles event, Emitter<RemoteArticlesState> emit) {
    if (state is! RemoteArticlesDone) return;

    List<ArticleEntity> filteredArticles = List.from(_allArticles);

    if (event.searchQuery.isNotEmpty) {
      filteredArticles = filteredArticles.where((ArticleEntity article) {
        return article.title!.toLowerCase().contains(event.searchQuery.toLowerCase());
      }).toList();
    }

    final now = DateTime.now();
    switch (event.dateFilter) {
      case DateFilter.last24Hours:
        filteredArticles = filteredArticles.where((ArticleEntity article) {
          return article.publishedAt!.isAfter(now.subtract(const Duration(days: 1)));
        }).toList();
        break;
      case DateFilter.last7Days:
        filteredArticles = filteredArticles.where((ArticleEntity article) {
          return article.publishedAt!.isAfter(now.subtract(const Duration(days: 7)));
        }).toList();
        break;
      case DateFilter.lastMonth:
        filteredArticles = filteredArticles.where((ArticleEntity article) {
          return article.publishedAt!.isAfter(now.subtract(const Duration(days: 30)));
        }).toList();
        break;
      case DateFilter.all:
        break;
    }

    emit(RemoteArticlesDone(filteredArticles));
  }

  void onSaveArticle(SaveArticle event, Emitter<RemoteArticlesState> emit) async {
    try {
      await _createArticleUseCase(params: event.article);
      emit(const RemoteArticleCreated());
    } catch (e) {
      emit(RemoteArticlesError(e.toString()));
    }
  }

  void onStopListeningToArticles(StopListeningToArticles event, Emitter<RemoteArticlesState> emit) {
    _articleRepository.dispose();
  }

  @override
  Future<void> close() {
    _articleRepository.dispose();
    return super.close();
  }
}