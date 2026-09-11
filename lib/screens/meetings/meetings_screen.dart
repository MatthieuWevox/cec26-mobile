import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/meeting.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'meeting_detail_screen.dart';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({super.key});

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  late Future<List<Meeting>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = const ApiService().getMeetings();
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
            eyebrow: 'Agenda du réseau',
            title: 'Réunions',
            subtitle:
                'Préparez vos prochains rendez-vous et retrouvez les archives.',
            icon: Icons.calendar_month_rounded,
          ),
          Expanded(
            child: FutureBuilder<List<Meeting>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CecLoadingWidget(
                    message: 'Chargement des réunions...',
                  );
                }
                if (snapshot.hasError) {
                  return CecErrorWidget(
                    message: snapshot.error.toString(),
                    onRetry: () => setState(_load),
                  );
                }

                final now = DateTime.now();
                final all = snapshot.data ?? [];
                final upcoming = all.where((meeting) {
                  final date = DateTime.tryParse(meeting.date);
                  return date != null &&
                      date.isAfter(DateTime(now.year, now.month, now.day - 1));
                }).toList()..sort((a, b) => a.date.compareTo(b.date));
                final past = all.where((meeting) {
                  final date = DateTime.tryParse(meeting.date);
                  return date == null ||
                      date.isBefore(DateTime(now.year, now.month, now.day));
                }).toList()..sort((a, b) => b.date.compareTo(a.date));

                if (all.isEmpty) {
                  return const CecEmptyWidget(
                    message: 'Aucune réunion planifiée pour le moment.',
                    icon: Icons.event_busy_rounded,
                  );
                }

                return RefreshIndicator(
                  color: AppTheme.primaryColor,
                  onRefresh: _refresh,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                    children: [
                      if (upcoming.isNotEmpty) ...[
                        _SectionLabel(
                          title: 'Prochains rendez-vous',
                          count: upcoming.length,
                          highlighted: true,
                        ),
                        const SizedBox(height: 10),
                        for (final meeting in upcoming) ...[
                          _MeetingCard(meeting: meeting, isUpcoming: true),
                          const SizedBox(height: 12),
                        ],
                      ],
                      if (past.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.only(
                            top: upcoming.isEmpty ? 0 : 14,
                          ),
                          child: _SectionLabel(
                            title: 'Réunions passées',
                            count: past.length,
                          ),
                        ),
                        const SizedBox(height: 10),
                        for (final meeting in past) ...[
                          _MeetingCard(meeting: meeting, isUpcoming: false),
                          const SizedBox(height: 12),
                        ],
                      ],
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

class _SectionLabel extends StatelessWidget {
  final String title;
  final int count;
  final bool highlighted;

  const _SectionLabel({
    required this.title,
    required this.count,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ),
        CecBadge(
          label: count.toString(),
          color: highlighted ? AppTheme.accentDark : AppTheme.textSecondary,
        ),
      ],
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final Meeting meeting;
  final bool isUpcoming;

  const _MeetingCard({required this.meeting, required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(meeting.date);
    final day = date == null ? '--' : DateFormat('dd', 'fr_FR').format(date);
    final month = date == null
        ? ''
        : DateFormat(
            'MMM',
            'fr_FR',
          ).format(date).replaceAll('.', '').toUpperCase();
    final time = meeting.heure.length >= 5
        ? '${meeting.heure.substring(0, 2)}h${meeting.heure.substring(3, 5)}'
        : meeting.heure;

    return CecSurface(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MeetingDetailScreen(meeting: meeting),
        ),
      ),
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 78,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 17),
              color: isUpcoming ? AppTheme.primaryColor : AppTheme.surfaceMuted,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: isUpcoming ? Colors.white : AppTheme.primaryColor,
                      fontSize: 27,
                    ),
                  ),
                  Text(
                    month,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isUpcoming
                          ? AppTheme.accentColor
                          : AppTheme.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CecMeta(
                            icon: Icons.schedule_rounded,
                            text: time,
                            color: isUpcoming
                                ? AppTheme.accentDark
                                : AppTheme.textSecondary,
                          ),
                        ),
                        if (isUpcoming)
                          const CecBadge(
                            label: 'À VENIR',
                            color: AppTheme.successColor,
                          ),
                      ],
                    ),
                    const SizedBox(height: 11),
                    Text(
                      meeting.adresse,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: CecMeta(
                            icon: Icons.people_outline_rounded,
                            text:
                                '${meeting.guests.length} invité${meeting.guests.length > 1 ? 's' : ''}',
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: AppTheme.primaryColor,
                        ),
                      ],
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
