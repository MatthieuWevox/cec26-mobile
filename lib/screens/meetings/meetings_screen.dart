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
  bool? _showPast;

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
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const CecPageHeader(
            eyebrow: 'Agenda du réseau',
            title: 'Réunions',
            subtitle: 'Vos prochains rendez-vous, clairement organisés.',
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
                final startOfToday = DateTime(now.year, now.month, now.day);
                final all = snapshot.data ?? [];
                final upcoming = all.where((meeting) {
                  final date = DateTime.tryParse(meeting.date);
                  return date != null && !date.isBefore(startOfToday);
                }).toList()..sort((a, b) => a.date.compareTo(b.date));
                final past = all.where((meeting) {
                  final date = DateTime.tryParse(meeting.date);
                  return date == null || date.isBefore(startOfToday);
                }).toList()..sort((a, b) => b.date.compareTo(a.date));
                final showPast = _showPast ?? upcoming.isEmpty;

                if (all.isEmpty) {
                  return const CecEmptyWidget(
                    message: 'Aucune réunion planifiée pour le moment.',
                    icon: Icons.event_busy_rounded,
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
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          126,
                        ),
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<bool>(
                              showSelectedIcon: false,
                              segments: [
                                ButtonSegment(
                                  value: false,
                                  label: Text('À venir (${upcoming.length})'),
                                  icon: const Icon(
                                    Icons.event_available_outlined,
                                    size: 18,
                                  ),
                                ),
                                ButtonSegment(
                                  value: true,
                                  label: Text('Passées (${past.length})'),
                                  icon: const Icon(
                                    Icons.history_rounded,
                                    size: 18,
                                  ),
                                ),
                              ],
                              selected: {showPast},
                              onSelectionChanged: (selection) =>
                                  setState(() => _showPast = selection.first),
                              style: ButtonStyle(
                                side: const WidgetStatePropertyAll(
                                  BorderSide.none,
                                ),
                                backgroundColor:
                                    WidgetStateProperty.resolveWith(
                                      (states) =>
                                          states.contains(WidgetState.selected)
                                          ? AppTheme.primaryColor
                                          : AppTheme.surfaceMuted,
                                    ),
                                foregroundColor:
                                    WidgetStateProperty.resolveWith(
                                      (states) =>
                                          states.contains(WidgetState.selected)
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                    ),
                                minimumSize: const WidgetStatePropertyAll(
                                  Size(0, 48),
                                ),
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radius,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if ((!showPast && upcoming.isEmpty) ||
                              (showPast && past.isEmpty))
                            Padding(
                              padding: const EdgeInsets.only(top: 32),
                              child: CecEmptyWidget(
                                message: showPast
                                    ? 'Vos réunions passées apparaîtront ici.'
                                    : 'Les prochaines rencontres seront annoncées ici.',
                                icon: Icons.event_outlined,
                              ),
                            ),
                          if (!showPast && upcoming.isNotEmpty) ...[
                            _SectionLabel(
                              title: 'À venir',
                              count: upcoming.length,
                              highlighted: true,
                            ),
                            const SizedBox(height: 12),
                            CecReveal(
                              child: _NextMeetingCard(meeting: upcoming.first),
                            ),
                            if (upcoming.length > 1) ...[
                              const SizedBox(height: 12),
                              for (
                                var index = 1;
                                index < upcoming.length;
                                index++
                              ) ...[
                                CecReveal(
                                  delay: Duration(
                                    milliseconds: index.clamp(0, 5) * 45,
                                  ),
                                  child: _MeetingCard(
                                    meeting: upcoming[index],
                                    isUpcoming: true,
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ],
                          ],
                          if (showPast && past.isNotEmpty) ...[
                            Padding(
                              padding: EdgeInsets.only(top: 0),
                              child: _SectionLabel(
                                title: 'Dernières rencontres',
                                count: past.length,
                              ),
                            ),
                            const SizedBox(height: 12),
                            for (
                              var index = 0;
                              index < past.length;
                              index++
                            ) ...[
                              CecReveal(
                                delay: Duration(
                                  milliseconds: index.clamp(0, 5) * 35,
                                ),
                                child: _MeetingCard(
                                  meeting: past[index],
                                  isUpcoming: false,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ],
                        ],
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
          label: '$count',
          color: highlighted ? AppTheme.accentDark : AppTheme.textSecondary,
        ),
      ],
    );
  }
}

class _NextMeetingCard extends StatelessWidget {
  final Meeting meeting;

  const _NextMeetingCard({required this.meeting});

  @override
  Widget build(BuildContext context) {
    final data = _MeetingDateData.from(meeting);

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        boxShadow: AppTheme.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openMeeting(context, meeting),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 68,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(18),
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                        border: Border.all(color: Colors.white.withAlpha(28)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            data.day,
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(color: Colors.white, fontSize: 26),
                          ),
                          Text(
                            data.month,
                            style: const TextStyle(
                              color: AppTheme.accentColor,
                              fontSize: 10,
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
                          const CecBadge(
                            label: 'PROCHAIN RENDEZ-VOUS',
                            color: AppTheme.accentDark,
                            icon: Icons.bolt_rounded,
                            inverted: true,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            meeting.adresse,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(height: 1, color: Colors.white.withAlpha(22)),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          CecMeta(
                            icon: Icons.schedule_rounded,
                            text: data.time,
                            color: Colors.white.withAlpha(210),
                          ),
                          CecMeta(
                            icon: Icons.people_outline_rounded,
                            text:
                                '${meeting.guests.length} invité${meeting.guests.length > 1 ? 's' : ''}',
                            color: Colors.white.withAlpha(210),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(18),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withAlpha(28)),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final Meeting meeting;
  final bool isUpcoming;

  const _MeetingCard({required this.meeting, required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    final data = _MeetingDateData.from(meeting);

    return CecSurface(
      onTap: () => _openMeeting(context, meeting),
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 70,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
              decoration: BoxDecoration(
                color: isUpcoming ? AppTheme.accentSoft : AppTheme.surfaceMuted,
                border: Border(
                  right: BorderSide(color: AppTheme.primaryColor.withAlpha(16)),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.day,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontSize: 22,
                    ),
                  ),
                  Text(
                    data.month,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isUpcoming
                          ? AppTheme.accentDark
                          : AppTheme.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CecMeta(
                            icon: Icons.schedule_rounded,
                            text: data.time,
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
                    const SizedBox(height: 9),
                    Text(
                      meeting.adresse,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 9),
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

class _MeetingDateData {
  final String day;
  final String month;
  final String time;

  const _MeetingDateData({
    required this.day,
    required this.month,
    required this.time,
  });

  factory _MeetingDateData.from(Meeting meeting) {
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
    return _MeetingDateData(day: day, month: month, time: time);
  }
}

void _openMeeting(BuildContext context, Meeting meeting) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => MeetingDetailScreen(meeting: meeting)),
  );
}
