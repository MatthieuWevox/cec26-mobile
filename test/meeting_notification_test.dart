import 'package:cec2026/models/meeting.dart';
import 'package:cec2026/providers/auth_provider.dart';
import 'package:cec2026/screens/meetings/meeting_detail_screen.dart';
import 'package:cec2026/screens/meetings/meeting_notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  Widget page(Future<List<Meeting>> Function() load) => ChangeNotifierProvider(
    create: (_) => AuthProvider(),
    child: MaterialApp(
      home: MeetingNotificationScreen(meetingId: 12, loadMeetings: load),
    ),
  );

  testWidgets('meeting notification loads the current meeting', (tester) async {
    const meeting = Meeting(
      id: 12,
      date: '2026-10-12',
      heure: '08:30',
      adresse: 'Nouvelle adresse',
      createdAt: '',
      updatedAt: '',
      guests: [],
    );
    await tester.pumpWidget(page(() async => [meeting]));
    await tester.pumpAndSettle();
    expect(find.byType(MeetingDetailScreen), findsOneWidget);
    expect(find.text('Nouvelle adresse'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('deleted meeting is handled', (tester) async {
    await tester.pumpWidget(page(() async => []));
    await tester.pumpAndSettle();
    expect(find.byType(MeetingDetailScreen), findsNothing);
    expect(find.textContaining('disponible'), findsOneWidget);
  });

  testWidgets('network error offers retry', (tester) async {
    var attempts = 0;
    await tester.pumpWidget(
      page(() async {
        if (attempts++ == 0) throw Exception('offline');
        return [];
      }),
    );
    await tester.pumpAndSettle();
    expect(find.text('Impossible de charger la réunion.'), findsOneWidget);
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.textContaining('disponible'), findsOneWidget);
  });
}
