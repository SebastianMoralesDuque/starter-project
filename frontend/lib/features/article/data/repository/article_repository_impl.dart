import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/features/article/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/article/data/models/article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/article/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/article/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/article/data/data_sources/remote/firestore_api_service.dart';
import 'package:rxdart/rxdart.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final FirestoreApiService _firestoreApiService;
  final AppDatabase _appDatabase;
  final FirebaseAuth _auth;

  StreamSubscription? _firestoreSubscription;
  StreamSubscription? _combinedSubscription;
  StreamController<DataState<List<ArticleEntity>>>? _newsArticlesController;

  ArticleRepositoryImpl(this._firestoreApiService, this._appDatabase, this._auth);
  
  @override
  Stream<DataState<List<ArticleEntity>>> getNewsArticles() {
    _newsArticlesController ??= StreamController<DataState<List<ArticleEntity>>>.broadcast();

    final remoteArticlesStream = _firestoreApiService.getArticlesStream();
    final localArticlesStream = _appDatabase.articleDAO.getArticles();

    _firestoreSubscription?.cancel();
    _firestoreSubscription = remoteArticlesStream.listen((articles) async {
      await _appDatabase.articleDAO.deleteAllArticles();
      await _appDatabase.articleDAO.insertArticles(articles);
    }, onError: (error) {
      _newsArticlesController?.add(DataFailed(error));
    });

    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _combinedSubscription?.cancel();
      _combinedSubscription = localArticlesStream.listen((articles) {
        final entities = articles.map((model) => model.toEntity()).toList();
        _newsArticlesController?.add(DataSuccess(entities));
      });
      return _newsArticlesController!.stream;
    }

    final bookmarkedIdsStream = _firestoreApiService.getBookmarkedArticleIdsStream(userId);

    _combinedSubscription?.cancel();
    _combinedSubscription = Rx.combineLatest2(
      localArticlesStream,
      bookmarkedIdsStream,
      (List<ArticleModel> articles, List<String> bookmarkedIds) {
        final entities = articles.map((article) {
          return article.toEntity(isBookmarked: bookmarkedIds.contains(article.id));
        }).toList();
        return DataSuccess(entities);
      },
    ).listen(
      (dataState) => _newsArticlesController?.add(dataState),
      onError: (error) => _newsArticlesController?.add(DataFailed(error)),
    );

    return _newsArticlesController!.stream;
  }

  @override
  Stream<List<ArticleEntity>> getSavedArticles() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    final bookmarkedIdsStream = _firestoreApiService.getBookmarkedArticleIdsStream(userId);
    final allArticlesStream = _appDatabase.articleDAO.getArticles();

    return Rx.combineLatest2(
      allArticlesStream,
      bookmarkedIdsStream,
      (List<ArticleModel> allArticles, List<String> bookmarkedIds) {
        return allArticles
            .where((article) => bookmarkedIds.contains(article.id))
            .map((article) => article.toEntity(isBookmarked: true))
            .toList();
      },
    );
  }

  @override
  Future<void> removeArticle(ArticleEntity article) async {
    await _appDatabase.articleDAO.deleteArticle(ArticleModel.fromEntity(article));
    await _firestoreApiService.removeArticle(article.id!);
  }

  @override
  Future<void> createArticle(ArticleEntity article) async {
    final articleModel = ArticleModel.fromEntity(article);
    await _firestoreApiService.createArticle(articleModel);
  }

  @override
  Future<void> toggleBookmark(ArticleEntity article) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }

    if (article.isBookmarked) {
      await _firestoreApiService.bookmarkArticle(userId, article.id!);
    } else {
      await _firestoreApiService.unbookmarkArticle(userId, article.id!);
    }
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    _combinedSubscription?.cancel();
    _newsArticlesController?.close();
    _newsArticlesController = null;
  }
}