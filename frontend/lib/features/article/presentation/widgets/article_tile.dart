import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/article.dart';

class ArticleWidget extends StatelessWidget {
  final ArticleEntity? article;
  final bool? isRemovable;
  final void Function(ArticleEntity article)? onRemove;
  final void Function(ArticleEntity article)? onArticlePressed;
  const ArticleWidget({
    super.key,
    this.article,
    this.onArticlePressed,
    this.isRemovable = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildImage(context),
            ),
            Expanded(
              flex: 3,
              child: _buildTitleAndDescription(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: CachedNetworkImage(
            imageUrl: article!.urlToImage!,
            width: double.maxFinite,
            height: double.maxFinite,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: const Center(child: CupertinoActivityIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: const Icon(Icons.error),
            ),
          ),
        ),
        if (isRemovable!)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: _onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.red, size: 20),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitleAndDescription() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article!.title ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Butler',
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              article!.description ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.timeline_outlined, size: 14),
              const SizedBox(width: 4),
              Text(
                article!.publishedAt?.toLocal().toString().split(' ')[0] ?? '',
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
Widget _buildRemovableArea() {
  return const SizedBox.shrink();
}



  void _onTap() {
    if (onArticlePressed != null) {
      onArticlePressed!(article!);
    }
  }

  void _onRemove() {
    if (onRemove != null) {
      onRemove!(article!);
    }
  }

}
