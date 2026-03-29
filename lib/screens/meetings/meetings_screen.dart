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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réunions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() => _load()),
          ),
        ],
      ),
      body: FutureBuilder<List<Meeting>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CecLoadingWidget(message: 'Chargement des réunions…');
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
              message: 'Aucune réunion disponible.',
              icon: Icons.event_rounded,
            );
          }
          return RefreshIndicator(
            color: AppTheme.primaryColor,
            onRefresh: () async => setState(() => _load()),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: items.length,
              itemBuilder: (context, index) =>
                  _MeetingCard(meeting: items[index]),
            ),
          );
        },
      ),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final Meeting meeting;
  const _MeetingCard({required this.meeting});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(meeting.date);
    final isUpcoming = date != null && date.isAfter(DateTime.now());

    String dayStr = '';
    String monthStr = '';
    String yearStr = '';
    String timeStr = '';

    if (date != null) {
      dayStr = DateFormat('d', 'fr_FR').format(date);
      monthStr = DateFormat('MMM', 'fr_FR').format(date).toUpperCase();
      yearStr = DateFormat('yyyy').format(date);
    }

    final timeParts = meeting.heure.split(':');
    if (timeParts.length >= 2) {
      timeStr = '${timeParts[0]}h${timeParts[1]}';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MeetingDetailScreen(meeting: meeting),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date badge
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isUpcoming
                      ? AppTheme.primaryColor
                      : AppTheme.primaryColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dayStr,
                      style: TextStyle(
                        color: isUpcoming ? Colors.white : AppTheme.primaryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    Text(
                      monthStr,
                      style: TextStyle(
                        color: isUpcoming
                            ? Colors.white.withAlpha(200)
                            : AppTheme.primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      yearStr,
                      style: TextStyle(
                        color: isUpcoming
                            ? Colors.white.withAlpha(180)
                            : AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isUpcoming)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'À VENIR',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppTheme.accentColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accentColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            meeting.adresse,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (meeting.guests.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.people_outline_rounded,
                            size: 14,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${meeting.guests.length} invité${meeting.guests.length > 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
