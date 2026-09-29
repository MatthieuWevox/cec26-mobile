enum NotificationKind { recommendation, thanks, meeting }

class NotificationTarget {
  final NotificationKind kind;
  final int? id;

  const NotificationTarget(this.kind, this.id);

  bool get requiresAuthentication => kind != NotificationKind.meeting;

  static NotificationTarget? fromData(Map<String, dynamic> data) {
    final kind = switch (data['type']) {
      'recommendation' => NotificationKind.recommendation,
      'thanks' => NotificationKind.thanks,
      'meeting' => NotificationKind.meeting,
      _ => null,
    };
    if (kind == null) return null;
    final id = int.tryParse(data['id']?.toString() ?? '');
    if (kind == NotificationKind.meeting && (id == null || id <= 0)) {
      return null;
    }
    return NotificationTarget(kind, id);
  }
}
