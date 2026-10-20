import 'package:tv_show_tracker/core/network/api_exception.dart';
import 'package:tv_show_tracker/features/shows/data/datasources/shows_remote_data_source.dart';
import 'package:tv_show_tracker/features/shows/data/models/show.dart';
import 'package:tv_show_tracker/features/shows/data/models/show_details.dart';
import 'package:tv_show_tracker/features/shows/data/models/shows_page.dart';

abstract interface class ShowsRepository {
  Future<ShowsPage> getShows(int page);
  Future<List<Show>> searchShows(String query);
  Future<ShowDetails> getShowDetails(int id);
}

class ShowsRepositoryImpl implements ShowsRepository {
  ShowsRepositoryImpl(this._remote);

  final ShowsRemoteDataSource _remote;

  @override
  Future<ShowsPage> getShows(int page) async {
    try {
      final shows = await _remote.fetchShows(page);
      // The index endpoint is ordered by id. Sorting each page by TVMaze
      // weight surfaces the most popular shows first.
      final sorted = [...shows]..sort((a, b) => b.weight.compareTo(a.weight));
      return ShowsPage(shows: sorted, hasMore: shows.isNotEmpty);
    } on ApiException catch (error) {
      if (error.isNotFound) return const ShowsPage(shows: [], hasMore: false);
      rethrow;
    }
  }

  @override
  Future<List<Show>> searchShows(String query) => _remote.searchShows(query);

  @override
  Future<ShowDetails> getShowDetails(int id) => _remote.fetchShowDetails(id);
}
