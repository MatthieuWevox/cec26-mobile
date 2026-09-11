import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final dateLabel = date == null
        ? ''
        : DateFormat('d MMMM yyyy', 'fr_FR').format(date);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 255,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.primaryDark,
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            surfaceTintColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Stack(
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
                        colors: [Color(0x14000000), Color(0xD917143E)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CecMeta(
                    icon: Icons.schedule_rounded,
                    text: dateLabel,
                    color: AppTheme.accentDark,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    news.titre,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  if (news.sousTitre.isNotEmpty) ...[
                    const SizedBox(height: 11),
                    Text(
                      news.sousTitre,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Container(width: 52, height: 3, color: AppTheme.accentColor),
                  const SizedBox(height: 16),
                  Html(
                    data: news.contenu,
                    style: {
                      'body': Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        color: AppTheme.textPrimary,
                        fontSize: FontSize(15),
                        lineHeight: const LineHeight(1.7),
                      ),
                      'p': Style(margin: Margins.only(bottom: 14)),
                      'h1': Style(
                        fontSize: FontSize(22),
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      'h2': Style(
                        fontSize: FontSize(19),
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      'h3': Style(
                        fontSize: FontSize(17),
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      'a': Style(
                        color: AppTheme.accentDark,
                        textDecoration: TextDecoration.underline,
                      ),
                      'blockquote': Style(
                        padding: HtmlPaddings.only(left: 14),
                        border: const Border(
                          left: BorderSide(
                            color: AppTheme.accentColor,
                            width: 3,
                          ),
                        ),
                        color: AppTheme.textSecondary,
                      ),
                    },
                    onLinkTap: (url, _, __) {
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
          ),
        ],
      ),
    );
  }
}
