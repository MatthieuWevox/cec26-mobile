import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/news.dart';
import '../../models/meeting.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../legal_information_screen.dart';
import '../meetings/meetings_screen.dart';
import 'news_detail_screen.dart';

class NewsScreen extends StatefulWidget {
  final VoidCallback? onOpenAgenda;
  final VoidCallback? onOpenDirectory;
  const NewsScreen({super.key, this.onOpenAgenda, this.onOpenDirectory});
  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<News>> _future;
  late Future<List<Meeting>> _meetings;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = const ApiService().getNews();
    // The optional agenda preview must not hide the news when unavailable.
    _meetings = const ApiService()
        .getMeetings()
        .then((items) {
          final today = DateUtils.dateOnly(DateTime.now());
          return items.where((m) {
            final date = DateTime.tryParse(m.date);
            return date != null && !date.isBefore(today);
          }).toList()..sort((a, b) => a.date.compareTo(b.date));
        })
        .catchError((_) => <Meeting>[]);
  }

  Future<void> _refresh() async {
    setState(_load);
    try {
      await _future;
    } catch (_) {
      /* Rendered by FutureBuilder. */
    }
  }

  void _open(News news) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => NewsDetailScreen(news: news)),
  );

  @override
  Widget build(BuildContext context) {
    final member = context.watch<AuthProvider>().currentMember;
    return Scaffold(
      body: Column(
        children: [
          CecPageHeader(
            eyebrow: 'Entrepreneurs du Cotentin',
            title: member == null
                ? 'La vie du Club.'
                : 'Bonjour, ${member.prenom}.',
            subtitle: 'Les nouvelles de votre réseau.',
            icon: Icons.newspaper_outlined,
            trailing: IconButton(
              tooltip: 'À propos et assistance',
              icon: const Icon(Icons.info_outline_rounded),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LegalInformationScreen(),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<News>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const CecLoadingWidget();
                }
                if (snapshot.hasError) {
                  return CecErrorWidget(
                    message: snapshot.error.toString(),
                    onRetry: () => setState(_load),
                  );
                }
                final items = snapshot.data ?? [];
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 126),
                    children: [
                      if (items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  'assets/actu.jpg',
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 22),
                              Text(
                                'Des talents d’ici.\nDes projets en commun.',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Retrouvez les entrepreneurs du Cotentin et faites connaissance avec le réseau.',
                              ),
                              if (widget.onOpenDirectory != null) ...[
                                const SizedBox(height: 20),
                                OutlinedButton.icon(
                                  onPressed: widget.onOpenDirectory,
                                  icon: const Icon(Icons.people_outline),
                                  label: const Text('Explorer l’annuaire'),
                                ),
                              ],
                            ],
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: _FeaturedNewsCard(
                            news: items.first,
                            onTap: () => _open(items.first),
                          ),
                        ),
                      FutureBuilder<List<Meeting>>(
                        future: _meetings,
                        builder: (context, snapshot) {
                          final meetings = snapshot.data ?? [];
                          if (meetings.isEmpty) return const SizedBox.shrink();
                          return Container(
                            margin: const EdgeInsets.only(top: 24),
                            padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
                            color: AppTheme.backgroundLight,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'À vos agendas',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineSmall,
                                      ),
                                    ),
                                    if (widget.onOpenAgenda != null)
                                      TextButton(
                                        onPressed: widget.onOpenAgenda,
                                        child: const Text('Tout voir'),
                                      ),
                                  ],
                                ),
                                MeetingListRow(meeting: meetings.first),
                              ],
                            ),
                          );
                        },
                      ),
                      if (items.length > 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionHeader(title: 'Dans le réseau'),
                              for (final news in items.skip(1))
                                InkWell(
                                  onTap: () => _open(news),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          child: Image.asset(
                                            'assets/actu.jpg',
                                            width: 68,
                                            height: 76,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                news.titre,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.titleMedium,
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                _date(news.createdAt),
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
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
  final VoidCallback onTap;
  const _FeaturedNewsCard({required this.news, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        color: AppTheme.primaryColor,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: largeText ? 330 : 248,
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
                      colors: [Color(0x00000000), Color(0xEA171827)],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CecBadge(label: 'LA VIE DU CLUB', inverted: true),
                      const Spacer(),
                      Text(
                        news.titre,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontSize: 25,
                              height: 1.2,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _date(news.createdAt),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.north_east_rounded,
                            color: Colors.white,
                            size: 19,
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
    );
  }
}

String _date(String value) {
  final date = DateTime.tryParse(value);
  return date == null ? '' : DateFormat('d MMM yyyy', 'fr_FR').format(date);
}
