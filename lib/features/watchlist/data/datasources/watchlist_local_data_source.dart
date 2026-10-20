import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tv_show_tracker/features/shows/data/models/show.dart';

/// Persists the watchlist as a JSON string in shared_preferences.
class WatchlistLocalDataSource {
  WatchlistLocalDataSource(this._prefs);

  static const storageKey = 'watchlist.shows.v1';

  final SharedPreferences _prefs;

  List<Show> readShows() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(Show.fromJson)
          .toList();
    } on Object {
      // Corrupt data is discarded. The next save overwrites it.
      return [];
    }
  }

  Future<void> writeShows(List<Show> shows) async {
    final encoded = jsonEncode(shows.map((show) => show.toJson()).toList());
    final saved = await _prefs.setString(storageKey, encoded);
    if (!saved) throw StateError('Failed to persist the watchlist.');
  }
}
