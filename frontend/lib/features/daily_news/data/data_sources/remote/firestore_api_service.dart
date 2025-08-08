import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';

abstract class FirestoreApiService {
  Future<List<ArticleModel>> getArticles();
  Future<void> saveArticle(ArticleModel article);
  Future<void> removeArticle(int articleId);
}

class FirestoreApiServiceImpl implements FirestoreApiService {
  final FirebaseFirestore _firestore;

  FirestoreApiServiceImpl(this._firestore);

  @override
  Future<List<ArticleModel>> getArticles() async {
    final querySnapshot = await _firestore.collection('articles').get();
    return querySnapshot.docs.map((doc) => ArticleModel.fromMap(doc.data()..['id'] = doc.id)).toList();
  }

  @override
  Future<void> saveArticle(ArticleModel article) async {
    await _firestore.collection('articles').doc(article.id.toString()).set(article.toMap());
  }

  @override
  Future<void> removeArticle(int articleId) async {
    await _firestore.collection('articles').doc(articleId.toString()).delete();
  }
}