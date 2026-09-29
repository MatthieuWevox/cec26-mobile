import 'package:cec2026/models/notification_target.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('private exchange notifications require a member session', () {
    for (final type in ['recommendation', 'thanks']) {
      final target = NotificationTarget.fromData({'type': type, 'id': '12'});
      expect(target, isNotNull);
      expect(target!.requiresAuthentication, isTrue);
      expect(target.id, 12);
    }
  });

  test('meeting creation and updates open the current public meeting', () {
    for (final event in ['created', 'updated']) {
      final target = NotificationTarget.fromData({
        'type': 'meeting',
        'event': event,
        'id': '42',
      });
      expect(target!.kind, NotificationKind.meeting);
      expect(target.id, 42);
      expect(target.requiresAuthentication, isFalse);
    }
  });

  test('unknown or malformed destinations are ignored', () {
    for (final data in <Map<String, dynamic>>[
      {},
      {'type': 'other'},
      {'type': 'meeting'},
      {'type': 'meeting', 'id': '-1'},
      {'type': 'meeting', 'id': 'not-an-id'},
      {'type': 'meeting', 'id': '0'},
    ]) {
      expect(NotificationTarget.fromData(data), isNull);
    }
  });
}
