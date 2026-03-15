import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchProvider extends ChangeNotifier {
  static const String _recentKey = 'recent_searches';

  List<String> _recentSearches = <String>[];

  List<String> get recentSearches => _recentSearches;

  Future<void> loadRecentSearches() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _recentSearches = prefs.getStringList(_recentKey) ?? <String>[];
    notifyListeners();
  }

  Future<void> addRecentSearch(String query) async {
    final String normalized = query.trim();
    if (normalized.isEmpty) {
      return;
    }

    _recentSearches.removeWhere(
      (String item) => item.toLowerCase() == normalized.toLowerCase(),
    );
    _recentSearches.insert(0, normalized);
    if (_recentSearches.length > 8) {
      _recentSearches = _recentSearches.take(8).toList();
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentKey, _recentSearches);
    notifyListeners();
  }
}
