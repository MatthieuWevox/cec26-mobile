import 'package:shared_preferences/shared_preferences.dart';

class ContentVisibilityService {
  const ContentVisibilityService._();

  static String _key(String contentType) => 'hidden_content_${contentType}_ids';

  static Future<Set<int>> hiddenIds(String contentType) async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getStringList(_key(contentType)) ?? const [])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
  }

  static Future<void> hide(String contentType, int contentId) async {
    final preferences = await SharedPreferences.getInstance();
    final ids = await hiddenIds(contentType)
      ..add(contentId);
    await preferences.setStringList(
      _key(contentType),
      ids.map((id) => id.toString()).toList(),
    );
  }
}
