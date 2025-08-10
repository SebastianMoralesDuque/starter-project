import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ionicons/ionicons.dart';
import 'package:news_app_clean_architecture/core/dependencies/injection_container.dart';
import '../../domain/entities/article.dart';
import '../bloc/local_article_bloc.dart';
import '../bloc/local_article_event.dart';
import '../bloc/local_article_state.dart';
import '../widgets/article_detail_skeleton.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ArticleDetailsView extends HookWidget {
  final ArticleEntity? article;
  final bool isGuest;
 
  const ArticleDetailsView({super.key, this.article, this.isGuest = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>(),
      child: BlocListener<LocalArticleBloc, LocalArticlesState>(
        listener: (context, state) {
          if (state is LocalArticleBookmarked) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                content: Text(
                  'Artículo guardado en favoritos.',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            );
          } else if (state is LocalArticleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(state.error),
              ),
            );
          }
        },
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: _buildBody(context),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: Builder(
        builder: (context) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _onBackButtonTapped(context),
          child: const Icon(Ionicons.chevron_back),
        ),
      ),
      actions: isGuest
          ? []
          : [
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(
                    article!.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  ),
                  onPressed: () => _onBookmarkPressed(context),
                ),
              ),
            ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (article == null) {
      return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.surfaceVariant,
        highlightColor: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1),
        child: const ArticleDetailSkeleton(),
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildArticleImage(context),
          _buildArticleTitleAndDate(context),
          _buildArticleDescription(context),
        ],
      ),
    );
  }

  Widget _buildArticleTitleAndDate(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            article!.title!,
            style: const TextStyle(
              fontFamily: 'Butler',
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Ionicons.time_outline, size: 16),
              const SizedBox(width: 4),
              Text(
                article!.publishedAt?.toLocal().toString().split(' ')[0] ?? '',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArticleImage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: Image.network(
          article!.urlToImage!,
          fit: BoxFit.cover,
          width: double.maxFinite,
          height: 250,
        ),
      ),
    );
  }

  Widget _buildArticleDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      child: MarkdownBody(
        data: '${article!.description ?? ''}\n\n${article!.content ?? ''}',
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }

  void _onBackButtonTapped(BuildContext context) {
    Navigator.pop(context);
  }

  void _onBookmarkPressed(BuildContext context) {
    final bookmarkedArticle = ArticleEntity(
      id: article!.id,
      author: article!.author,
      title: article!.title,
      description: article!.description,
      url: article!.url,
      urlToImage: article!.urlToImage,
      publishedAt: article!.publishedAt,
      content: article!.content,
      isBookmarked: !article!.isBookmarked,
    );
    BlocProvider.of<LocalArticleBloc>(context).add(BookmarkArticle(bookmarkedArticle));
  }
}
