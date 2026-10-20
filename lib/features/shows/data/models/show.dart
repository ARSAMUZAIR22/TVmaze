import 'package:equatable/equatable.dart';
import 'package:tv_show_tracker/core/utils/formatters.dart';

class Show extends Equatable {
  const Show({
    required this.id,
    required this.name,
    this.genres = const [],
    this.premiered,
    this.ended,
    this.status,
    this.rating,
    this.imageMedium,
    this.imageOriginal,
    this.summary,
    this.network,
    this.language,
    this.runtime,
    this.weight = 0,
  });

  /// Parses the TVMaze show object. [toJson] writes the same shape,
  /// so this also restores shows from local storage.
  factory Show.fromJson(Map<String, dynamic> json) {
    final image = json['image'] as Map<String, dynamic>?;
    final rating = json['rating'] as Map<String, dynamic>?;
    final network = json['network'] as Map<String, dynamic>?;
    final webChannel = json['webChannel'] as Map<String, dynamic>?;

    return Show(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? 'Untitled',
      genres: (json['genres'] as List<dynamic>?)?.whereType<String>().toList() ??
          const [],
      premiered: json['premiered'] as String?,
      ended: json['ended'] as String?,
      status: json['status'] as String?,
      rating: (rating?['average'] as num?)?.toDouble(),
      imageMedium: image?['medium'] as String?,
      imageOriginal: image?['original'] as String?,
      summary: json['summary'] as String?,
      network: (network?['name'] ?? webChannel?['name']) as String?,
      language: json['language'] as String?,
      runtime: ((json['runtime'] ?? json['averageRuntime']) as num?)?.toInt(),
      weight: (json['weight'] as num?)?.toInt() ?? 0,
    );
  }

  final int id;
  final String name;
  final List<String> genres;
  final String? premiered;
  final String? ended;
  final String? status;
  final double? rating;
  final String? imageMedium;
  final String? imageOriginal;
  final String? summary;
  final String? network;
  final String? language;
  final int? runtime;

  /// TVMaze popularity score (0 to 100).
  final int weight;

  String? get posterUrl => imageMedium ?? imageOriginal;
  String? get largePosterUrl => imageOriginal ?? imageMedium;
  String get plainSummary => Formatters.stripHtml(summary);
  String? get ratingLabel => rating?.toStringAsFixed(1);

  String genresLabel([int max = 2]) => genres.take(max).join(', ');

  /// `2008 - 2013`, `2023 - Present` or a single year.
  String get yearsLabel {
    final start = Formatters.year(premiered);
    if (start == null) return '';
    if (status == 'Running') return '$start - Present';
    final end = Formatters.year(ended);
    if (end == null || end == start) return start;
    return '$start - $end';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'genres': genres,
        'premiered': premiered,
        'ended': ended,
        'status': status,
        'rating': {'average': rating},
        'image': {'medium': imageMedium, 'original': imageOriginal},
        'summary': summary,
        'network': network == null ? null : {'name': network},
        'language': language,
        'runtime': runtime,
        'weight': weight,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        genres,
        premiered,
        ended,
        status,
        rating,
        imageMedium,
        imageOriginal,
        summary,
        network,
        language,
        runtime,
        weight,
      ];
}
