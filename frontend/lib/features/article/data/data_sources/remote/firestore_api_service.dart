import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:news_app_clean_architecture/features/article/data/models/article.dart';

abstract class FirestoreApiService {
  Future<List<ArticleModel>> getArticles();
  Future<void> createArticle(ArticleModel article);
  Future<void> removeArticle(String articleId);
  Stream<List<ArticleModel>> getArticlesStream();
  Future<String> uploadImage(File imageFile);
  Stream<List<String>> getBookmarkedArticleIdsStream(String userId);
  Future<void> bookmarkArticle(String userId, String articleId);
  Future<void> unbookmarkArticle(String userId, String articleId);
}

class FirestoreApiServiceImpl implements FirestoreApiService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirestoreApiServiceImpl(this._firestore, this._storage);

  @override
  Future<List<ArticleModel>> getArticles() async {
    final querySnapshot = await _firestore.collection('articles').get();
    return querySnapshot.docs.map((doc) => ArticleModel.fromMap(doc.data()..['id'] = doc.id)).toList();
  }

  @override
  Future<void> createArticle(ArticleModel article) async {
    final Map<String, dynamic> data = article.toMap();
    await _firestore.collection('articles').add(data);
  }

  @override
  Future<void> removeArticle(String articleId) async {
    await _firestore.collection('articles').doc(articleId).delete();
  }

  @override
  Stream<List<ArticleModel>> getArticlesStream() {
    return _firestore.collection('articles').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ArticleModel.fromMap(doc.data()..['id'] = doc.id)).toList();
    });
  }

  @override
  Future<String> uploadImage(File imageFile) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final reference = _storage.ref().child('article_images/$fileName');
    final uploadTask = reference.putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() => {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Stream<List<String>> getBookmarkedArticleIdsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  @override
  Future<void> bookmarkArticle(String userId, String articleId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(articleId)
        .set({'bookmarkedAt': FieldValue.serverTimestamp()});
  }

  @override
  Future<void> unbookmarkArticle(String userId, String articleId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks')
        .doc(articleId)
        .delete();
  }
}