import 'package:flutter/material.dart';

import '../../models/meeting.dart';
import '../../services/api_service.dart';
import '../../widgets/common_widgets.dart';
import 'meeting_detail_screen.dart';

class MeetingNotificationScreen extends StatefulWidget {
  final int meetingId;
  final Future<List<Meeting>> Function()? loadMeetings;

  const MeetingNotificationScreen({
    super.key,
    required this.meetingId,
    this.loadMeetings,
  });

  @override
  State<MeetingNotificationScreen> createState() =>
      _MeetingNotificationScreenState();
}

class _MeetingNotificationScreenState extends State<MeetingNotificationScreen> {
  late Future<List<Meeting>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = (widget.loadMeetings ?? const ApiService().getMeetings)().timeout(
      const Duration(seconds: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Meeting>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          for (final meeting in snapshot.data!) {
            if (meeting.id == widget.meetingId) {
              return MeetingDetailScreen(meeting: meeting);
            }
          }
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Réunion')),
          body: snapshot.connectionState != ConnectionState.done
              ? const CecLoadingWidget(message: 'Chargement de la réunion...')
              : snapshot.hasError
              ? CecErrorWidget(
                  message: 'Impossible de charger la réunion.',
                  onRetry: () => setState(_load),
                )
              : const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Cette réunion n’est plus disponible.'),
                  ),
                ),
        );
      },
    );
  }
}
