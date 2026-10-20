import 'package:equatable/equatable.dart';
import 'package:tv_show_tracker/core/utils/formatters.dart';

class Episode extends Equatable {
  const Episode({
    required this.id,
    required this.name,
    required this.season,
    this.number,
    this.airdate,
    this.runtime,
    this.imageMedium,
    this.summary,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    final image = json['image'] as Map<String, dynamic>?;
    return Episode(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? 'Untitled episode',
      season: (json['season'] as num?)?.toInt() ?? 0,
      number: (json['number'] as num?)?.toInt(),
      airdate: json['airdate'] as String?,
      runtime: (json['runtime'] as num?)?.toInt(),
      imageMedium: image?['medium'] as String?,
      summary: json['summary'] as String?,
    );
  }

  final int id;
  final String name;
  final int season;

  /// Null for specials.
  final int? number;
  final String? airdate;
  final int? runtime;
  final String? imageMedium;
  final String? summary;

  String get plainSummary => Formatters.stripHtml(summary);

  @override
  List<Object?> get props =>
      [id, name, season, number, airdate, runtime, imageMedium, summary];
}
