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
  bool _past = false;
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
    try {
      await _future;
    } catch (_) {
      /* Rendered by FutureBuilder. */
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        const CecPageHeader(
          eyebrow: 'Entrepreneurs du Cotentin',
          title: 'On se retrouve ?',
          subtitle: 'Les rendez-vous qui font vivre le réseau.',
          icon: Icons.calendar_month_outlined,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: false, label: Text('À venir')),
                ButtonSegment(value: true, label: Text('Passées')),
              ],
              selected: {_past},
              onSelectionChanged: (value) =>
                  setState(() => _past = value.first),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: FutureBuilder<List<Meeting>>(
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
              final today = DateUtils.dateOnly(DateTime.now());
              final items =
                  (snapshot.data ?? []).where((m) {
                    final date = DateTime.tryParse(m.date);
                    final past = date == null || date.isBefore(today);
                    return past == _past;
                  }).toList()..sort(
                    (a, b) => _past
                        ? b.date.compareTo(a.date)
                        : a.date.compareTo(b.date),
                  );
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 126),
                  children: [
                    if (items.isEmpty)
                      CecEmptyWidget(
                        message: _past
                            ? 'Les réunions passées apparaîtront ici.'
                            : 'Aucune réunion planifiée pour le moment.',
                        icon: Icons.event_outlined,
                      ),
                    for (final meeting in items) ...[
                      MeetingListRow(meeting: meeting),
                      const Divider(),
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

class MeetingListRow extends StatelessWidget {
  final Meeting meeting;
  const MeetingListRow({super.key, required this.meeting});
  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(meeting.date);
    final time = meeting.heure.split(':').take(2).join('h');
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MeetingDetailScreen(meeting: meeting),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 66,
              decoration: BoxDecoration(
                color: AppTheme.accentSoft,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date?.day.toString() ?? '--',
                    style: const TextStyle(
                      fontSize: 25,
                      color: AppTheme.accentDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    date == null
                        ? ''
                        : DateFormat(
                            'MMM',
                            'fr_FR',
                          ).format(date).replaceAll('.', '').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.accentDark,
                      fontWeight: FontWeight.w700,
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
                    date == null
                        ? 'Rencontre du Club'
                        : DateFormat('EEEE d MMMM', 'fr_FR').format(date),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$time · ${meeting.adresse}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
