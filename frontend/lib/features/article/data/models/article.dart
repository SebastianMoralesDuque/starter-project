import 'package:floor/floor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_app_clean_architecture/features/article/domain/entities/article.dart';
import '../../../../core/constants/constants.dart';

@Entity(tableName: 'article', primaryKeys: ['id'])
class ArticleModel {
  final String id;
  final String? author;
  final String? title;
  final String? description;
  final String? url;
  final String? urlToImage;
  @ColumnInfo(name: 'publishedAt')
  final int? publishedAtTimestamp;
  final String? content;

  @ignore
  DateTime? get publishedAt => publishedAtTimestamp != null
      ? DateTime.fromMillisecondsSinceEpoch(publishedAtTimestamp!)
      : null;

  const ArticleModel({
    required this.id,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAtTimestamp,
    this.content,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> map) {
    final dateStr = map['publishedAt'];
    final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
    return ArticleModel(
      id: map['url'] ?? '',
      author: map['author'],
      title: map['title'],
      description: map['description'],
      url: map['url'],
      urlToImage: map['urlToImage'] ?? kDefaultImage,
      publishedAtTimestamp: date?.millisecondsSinceEpoch,
      content: map['content'],
    );
  }

  factory ArticleModel.fromEntity(ArticleEntity entity) {
    return ArticleModel(
      id: entity.id ?? '',
      author: entity.author,
      title: entity.title,
      description: entity.description,
      url: entity.url,
      urlToImage: entity.urlToImage,
      publishedAtTimestamp: entity.publishedAt?.millisecondsSinceEpoch,
      content: entity.content,
    );
  }

  ArticleEntity toEntity({bool isBookmarked = false}) {
    return ArticleEntity(
      id: id,
      author: author,
      title: title,
      description: description,
      url: url,
      urlToImage: urlToImage,
      publishedAt: publishedAt,
      content: content,
      isBookmarked: isBookmarked,
    );
  }
  factory ArticleModel.fromMap(Map<String, dynamic> map) {
    DateTime? date;
    final rawDate = map['publishedAt'];
    if (rawDate is Timestamp) {
      date = rawDate.toDate();
    } else if (rawDate is String) {
      date = DateTime.tryParse(rawDate);
    } else if (rawDate is int) {
      date = DateTime.fromMillisecondsSinceEpoch(rawDate);
    } else if (rawDate is DateTime) {
      date = rawDate;
    }

    return ArticleModel(
      id: map['id'] ?? '',
      author: map['author'],
      title: map['title'],
      description: map['description'],
      url: map['url'],
      urlToImage: map['urlToImage'] ?? kDefaultImage,
      publishedAtTimestamp: date?.millisecondsSinceEpoch,
      content: map['content'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'content': content,
    };
  }
}
