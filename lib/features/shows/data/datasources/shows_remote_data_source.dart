import 'package:tv_show_tracker/core/network/api_client.dart';
import 'package:tv_show_tracker/core/network/api_exception.dart';
import 'package:tv_show_tracker/features/shows/data/models/show.dart';
import 'package:tv_show_tracker/features/shows/data/models/show_details.dart';

class ShowsRemoteDataSource {
  ShowsRemoteDataSource(this._client);

  final ApiClient _client;

  /// `/shows?page={page}`. Returns 250 shows per page, 404 past the last page.
  Future<List<Show>> fetchShows(int page) async {
    final data = await _client.get('/shows', query: {'page': '$page'});
    return _parse(() => (data as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(Show.fromJson)
        .toList());
  }

  /// `/search/shows?q={query}`.
  Future<List<Show>> searchShows(String query) async {
    final data = await _client.get('/search/shows', query: {'q': query});
    return _parse(() => (data as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map((result) => Show.fromJson(result['show'] as Map<String, dynamic>))
        .toList());
  }

  /// `/shows/{id}?embed[]=cast&embed[]=episodes`.
  Future<ShowDetails> fetchShowDetails(int id) async {
    final data = await _client.get(
      '/shows/$id',
      query: {
        'embed[]': ['cast', 'episodes'],
      },
    );
    return _parse(() => ShowDetails.fromJson(data as Map<String, dynamic>));
  }

  T _parse<T>(T Function() parser) {
    try {
      return parser();
    } on Object {
      throw const ApiException('Received data in an unexpected format.');
    }
  }
}
