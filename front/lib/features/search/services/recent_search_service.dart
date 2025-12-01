import 'package:shared_preferences/shared_preferences.dart';

class RecentSearchService {
  static const String _key = 'recent_searches';

  Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? <String>[];
  }

  Future<void> save(List<String> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, values);
  }
}








