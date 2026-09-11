import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/news.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'news_detail_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<News>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = const ApiService().getNews();
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CecPageHeader(
            eyebrow: 'Le club en mouvement',
            title: 'Actualités',
            subtitle: 'Les nouvelles, initiatives et temps forts du réseau.',
            icon: Icons.auto_awesome_rounded,
          ),
          Expanded(
            child: FutureBuilder<List<News>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CecLoadingWidget(
                    message: 'Chargement des actualités...',
                  );
                }
                if (snapshot.hasError) {
                  return CecErrorWidget(
                    message: snapshot.error.toString(),
                    onRetry: () => setState(_load),
                  );
                }

                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const CecEmptyWidget(
                    message: 'Aucune actualité disponible pour le moment.',
                    icon: Icons.newspaper_rounded,
                  );
                }

                return RefreshIndicator(
                  color: AppTheme.primaryColor,
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                    itemCount: items.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'À la une',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                              ),
                              Text(
                                '${items.length} publication${items.length > 1 ? 's' : ''}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        );
                      }

                      final news = items[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: index == 1
                            ? _FeaturedNewsCard(news: news)
                            : _NewsCard(news: news),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedNewsCard extends StatelessWidget {
  final News news;

  const _FeaturedNewsCard({required this.news});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        boxShadow: AppTheme.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openNews(context, news),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 8.5,
                child: Hero(
                  tag: 'news-image-${news.id}',
                  child: Image.asset('assets/actu.jpg', fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CecMeta(
                      icon: Icons.schedule_rounded,
                      text: _formatDate(news.createdAt),
                      color: AppTheme.accentColor,
                    ),
                    const SizedBox(height: 11),
                    Text(
                      news.titre,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(color: Colors.white),
                    ),
                    if (news.sousTitre.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        news.sousTitre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withAlpha(178),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Lire l’article',
                          style: TextStyle(
                            color: AppTheme.accentColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 17,
                          color: AppTheme.accentColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final News news;

  const _NewsCard({required this.news});

  @override
  Widget build(BuildContext context) {
    return CecSurface(
      onTap: () => _openNews(context, news),
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: AppTheme.accentColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CecMeta(
                      icon: Icons.schedule_rounded,
                      text: _formatDate(news.createdAt),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      news.titre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (news.sousTitre.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        news.sousTitre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(String value) {
  final date = DateTime.tryParse(value);
  return date == null ? '' : DateFormat('d MMMM yyyy', 'fr_FR').format(date);
}

void _openNews(BuildContext context, News news) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => NewsDetailScreen(news: news)),
  );
}
