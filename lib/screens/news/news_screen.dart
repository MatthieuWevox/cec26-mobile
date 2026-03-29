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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actualités'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() => _load()),
          ),
        ],
      ),
      body: FutureBuilder<List<News>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CecLoadingWidget(message: 'Chargement des actualités…');
          }
          if (snapshot.hasError) {
            return CecErrorWidget(
              message: snapshot.error.toString(),
              onRetry: () => setState(() => _load()),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const CecEmptyWidget(
              message: 'Aucune actualité disponible.',
              icon: Icons.newspaper_rounded,
            );
          }
          return RefreshIndicator(
            color: AppTheme.primaryColor,
            onRefresh: () async => setState(() => _load()),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: items.length,
              itemBuilder: (context, index) =>
                  _NewsCard(news: items[index]),
            ),
          );
        },
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final News news;
  const _NewsCard({required this.news});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(news.createdAt);
    final dateStr = date != null
        ? DateFormat('d MMMM yyyy', 'fr_FR').format(date)
        : '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NewsDetailScreen(news: news),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: news.statut == 'publié'
                          ? AppTheme.accentColor.withAlpha(30)
                          : Colors.orange.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      news.statut,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: news.statut == 'publié'
                            ? AppTheme.accentColor
                            : Colors.orange,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (dateStr.isNotEmpty)
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                news.titre,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (news.sousTitre.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  news.sousTitre,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Lire la suite',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
