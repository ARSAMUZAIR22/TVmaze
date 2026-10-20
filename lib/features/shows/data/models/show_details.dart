import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:tv_show_tracker/features/shows/data/models/cast_member.dart';
import 'package:tv_show_tracker/features/shows/data/models/episode.dart';
import 'package:tv_show_tracker/features/shows/data/models/show.dart';

/// Result of `/shows/{id}?embed[]=cast&embed[]=episodes`.
class ShowDetails extends Equatable {
  ShowDetails({
    required this.show,
    required this.cast,
    required this.episodes,
  }) : seasons = _groupBySeason(episodes);

  factory ShowDetails.fromJson(Map<String, dynamic> json) {
    final embedded =
        json['_embedded'] as Map<String, dynamic>? ?? const <String, dynamic>{};

    final cast = (embedded['cast'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(CastMember.fromJson)
        .toList();

    final episodes = (embedded['episodes'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Episode.fromJson)
        .toList();

    return ShowDetails(show: Show.fromJson(json), cast: cast, episodes: episodes);
  }

  final Show show;
  final List<CastMember> cast;
  final List<Episode> episodes;

  /// Episodes keyed by season number, seasons ascending, episodes in order.
  final Map<int, List<Episode>> seasons;

  int get seasonCount => seasons.length;

  static Map<int, List<Episode>> _groupBySeason(List<Episode> episodes) {
    final grouped = SplayTreeMap<int, List<Episode>>();
    for (final episode in episodes) {
      grouped.putIfAbsent(episode.season, () => <Episode>[]).add(episode);
    }
    const last = 1 << 20;
    for (final list in grouped.values) {
      list.sort((a, b) => (a.number ?? last).compareTo(b.number ?? last));
    }
    return grouped;
  }

  @override
  List<Object?> get props => [show, cast, episodes];
}
