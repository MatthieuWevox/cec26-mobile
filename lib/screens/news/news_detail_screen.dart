import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/news.dart';
import '../../theme/app_theme.dart';

class NewsDetailScreen extends StatelessWidget {
  final News news;
  const NewsDetailScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(news.createdAt);
    final dateStr = date != null
        ? DateFormat('d MMMM yyyy', 'fr_FR').format(date)
        : '';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'news-image-${news.id}',
                    child: Image.asset(
                      'assets/actu.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x33000000),
                          Color(0xB3000000),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                news.titre,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: news.statut == 'publié'
                              ? AppTheme.accentColor
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          news.statut.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (dateStr.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: AppTheme.accentColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateStr,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (news.sousTitre.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      news.sousTitre,
                      style: const TextStyle(
                        fontSize: 17,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 20),
                  Text(
                    news.contenu,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                      height: 1.75,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
