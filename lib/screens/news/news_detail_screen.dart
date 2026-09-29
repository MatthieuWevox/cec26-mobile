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
      body: CecBackground(
        accentTop: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 310,
              pinned: true,
              stretch: true,
              toolbarHeight: 64,
              backgroundColor: AppTheme.primaryDark,
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
              leadingWidth: 68,
              leading: Padding(
                padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
                child: CecGlassIconButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Retour',
                  dark: true,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              surfaceTintColor: Colors.transparent,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                stretchModes: const [StretchMode.zoomBackground],
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
                          colors: [Color(0x0D000000), Color(0xD9151234)],
                          stops: [0.32, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 24,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CecBadge(
                          label: dateLabel.toUpperCase(),
                          icon: Icons.schedule_rounded,
                          color: AppTheme.primaryColor,
                          inverted: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: CecContentWidth(
                maxWidth: 760,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 52),
                  child: CecReveal(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          news.titre,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        if (news.sousTitre.isNotEmpty) ...[
                          const SizedBox(height: 11),
                          Text(
                            news.sousTitre,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 12,
                              height: 3,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withAlpha(50),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Html(
                          data: news.contenu,
                          style: {
                            'body': Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              color: AppTheme.textPrimary,
                              fontSize: FontSize(15),
                              lineHeight: const LineHeight(1.72),
                            ),
                            'p': Style(margin: Margins.only(bottom: 15)),
                            'h1': Style(
                              fontSize: FontSize(23),
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                            'h2': Style(
                              fontSize: FontSize(20),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
