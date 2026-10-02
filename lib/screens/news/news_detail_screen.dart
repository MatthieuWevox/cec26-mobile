import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/news.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class NewsDetailScreen extends StatelessWidget {
  final News news;
  const NewsDetailScreen({super.key, required this.news});
  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(news.createdAt);
    return Scaffold(
      appBar: const CecGlassAppBar(title: Text('Le journal du Club')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          Hero(
            tag: 'news-image-${news.id}',
            child: Image.asset(
              'assets/actu.jpg',
              height: 214,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CecBadge(
                  label: 'LA VIE DU CLUB',
                  color: AppTheme.accentDark,
                ),
                const SizedBox(height: 16),
                Text(
                  news.titre,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                if (date != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    DateFormat('d MMMM yyyy', 'fr_FR').format(date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (news.sousTitre.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  Text(
                    news.sousTitre,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                Html(
                  data: news.contenu,
                  style: {
                    'body': Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      fontFamily: 'Manrope',
                      color: AppTheme.textPrimary,
                      fontSize: FontSize(15),
                      lineHeight: const LineHeight(1.75),
                    ),
                    'p': Style(margin: Margins.only(bottom: 16)),
                    'h1': Style(fontSize: FontSize(24)),
                    'h2': Style(fontSize: FontSize(20)),
                    'h3': Style(fontSize: FontSize(17)),
                    'a': Style(
                      color: AppTheme.accentDark,
                      textDecoration: TextDecoration.underline,
                    ),
                    'img': Style(width: Width(100, Unit.percent)),
                  },
                  onLinkTap: (url, _, _) {
                    if (url != null) {
                      launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
