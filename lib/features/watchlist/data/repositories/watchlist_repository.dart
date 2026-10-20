import 'package:tv_show_tracker/features/shows/data/models/show.dart';
import 'package:tv_show_tracker/features/watchlist/data/datasources/watchlist_local_data_source.dart';

abstract interface class WatchlistRepository {
  Future<List<Show>> getWatchlist();
  Future<void> saveWatchlist(List<Show> shows);
}

class WatchlistRepositoryImpl implements WatchlistRepository {
  WatchlistRepositoryImpl(this._local);

  final WatchlistLocalDataSource _local;

  @override
  Future<List<Show>> getWatchlist() async => _local.readShows();

  @override
  Future<void> saveWatchlist(List<Show> shows) => _local.writeShows(shows);
}
