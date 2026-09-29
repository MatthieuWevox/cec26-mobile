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
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const CecPageHeader(
            eyebrow: 'Le club en mouvement',
            title: 'Actualités',
            subtitle: 'Les idées, initiatives et temps forts de votre réseau.',
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
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 40),
                        CecEmptyWidget(
                          message:
                              'Aucune actualité disponible pour le moment.',
                          icon: Icons.newspaper_rounded,
                        ),
                      ],
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final horizontalPadding = constraints.maxWidth > 800
                        ? (constraints.maxWidth - 760) / 2
                        : 16.0;

                    return RefreshIndicator(
                      color: AppTheme.primaryColor,
                      onRefresh: _refresh,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          126,
                        ),
                        itemCount: items.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(2, 0, 2, 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'À découvrir',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineSmall,
                                    ),
                                  ),
                                  CecBadge(
                                    label:
                                        '${items.length} PUBLICATION${items.length > 1 ? 'S' : ''}',
                                    color: AppTheme.accentDark,
                                  ),
                                ],
                              ),
                            );
                          }

                          final news = items[index - 1];
                          final delay = Duration(
                            milliseconds: ((index - 1).clamp(0, 5)) * 55,
                          );
                          return CecReveal(
                            delay: delay,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: index == 1
                                  ? _FeaturedNewsCard(news: news)
                                  : _NewsCard(news: news),
                            ),
                          );
                        },
                      ),
                    );
                  },
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
    return CecLayeredCard(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          boxShadow: AppTheme.softShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: AppTheme.primaryDark,
          child: InkWell(
            onTap: () => _openNews(context, news),
            child: AspectRatio(
              aspectRatio: 1.08,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'news-image-${news.id}',
                    child: Image.asset('assets/actu.jpg', fit: BoxFit.cover),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x12000000),
                          Color(0x18000000),
                          Color(0xF0151234),
                        ],
                        stops: [0, 0.38, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CecBadge(
                          label: 'À LA UNE',
                          color: AppTheme.primaryColor,
                          icon: Icons.auto_awesome_rounded,
                          inverted: true,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryDark.withAlpha(142),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSmall,
                            ),
                            border: Border.all(
                              color: Colors.white.withAlpha(34),
                            ),
                          ),
                          child: CecMeta(
                            icon: Icons.schedule_rounded,
                            text: _formatDate(news.createdAt),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          news.titre,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontSize: 22,
                                height: 1.22,
                              ),
                        ),
                        if (news.sousTitre.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            news.sousTitre,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white.withAlpha(188)),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Lire l’article',
                                style: TextStyle(
                                  color: AppTheme.accentColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0,
                                ),
                              ),
                            ),
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(22),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withAlpha(34),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 17,
                                color: Colors.white,
                              ),
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
    final parsedDate = DateTime.tryParse(news.createdAt);
    final day = parsedDate == null
        ? '--'
        : DateFormat('dd', 'fr_FR').format(parsedDate);
    final month = parsedDate == null
        ? ''
        : DateFormat(
            'MMM',
            'fr_FR',
          ).format(parsedDate).replaceAll('.', '').toUpperCase();

    return CecSurface(
      onTap: () => _openNews(context, news),
      padding: const EdgeInsets.all(15),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.accentSoft,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppTheme.accentColor.withAlpha(38)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontSize: 18,
                  ),
                ),
                Text(
                  month,
                  style: const TextStyle(
                    color: AppTheme.accentDark,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news.titre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (news.sousTitre.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    news.sousTitre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.arrow_forward_rounded,
            size: 18,
            color: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}

String _formatDate(String value) {
  final date = DateTime.tryParse(value);
  return date == null ? '' : DateFormat('d MMM yyyy', 'fr_FR').format(date);
}

void _openNews(BuildContext context, News news) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => NewsDetailScreen(news: news)),
  );
}
