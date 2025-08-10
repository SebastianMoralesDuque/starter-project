import 'package:equatable/equatable.dart';

class ArticleEntity extends Equatable{
  final String ? id;
  final String ? author;
  final String ? title;
  final String ? description;
  final String ? url;
  final String ? urlToImage;
  final DateTime ? publishedAt;
  final String ? content;
  final bool isBookmarked;

  const ArticleEntity({
    this.id,
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
    this.isBookmarked = false,
  });

  @override
  List < Object ? > get props {
    return [
      id,
      author,
      title,
      description,
      url,
      urlToImage,
      publishedAt,
      content,
      isBookmarked,
    ];
  }
}