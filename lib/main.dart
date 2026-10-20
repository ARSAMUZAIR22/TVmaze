import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tv_show_tracker/app/app.dart';
import 'package:tv_show_tracker/core/network/api_client.dart';
import 'package:tv_show_tracker/features/shows/data/datasources/shows_remote_data_source.dart';
import 'package:tv_show_tracker/features/shows/data/repositories/shows_repository.dart';
import 'package:tv_show_tracker/features/watchlist/data/datasources/watchlist_local_data_source.dart';
import 'package:tv_show_tracker/features/watchlist/data/repositories/watchlist_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final showsRepository = ShowsRepositoryImpl(ShowsRemoteDataSource(ApiClient()));
  final watchlistRepository = WatchlistRepositoryImpl(WatchlistLocalDataSource(prefs));

  runApp(
    TvShowTrackerApp(
      showsRepository: showsRepository,
      watchlistRepository: watchlistRepository,
    ),
  );
}
