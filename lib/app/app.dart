import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv_show_tracker/app/app_shell.dart';
import 'package:tv_show_tracker/core/theme/app_theme.dart';
import 'package:tv_show_tracker/features/search/bloc/search_bloc.dart';
import 'package:tv_show_tracker/features/shows/bloc/shows_bloc.dart';
import 'package:tv_show_tracker/features/shows/data/repositories/shows_repository.dart';
import 'package:tv_show_tracker/features/watchlist/bloc/watchlist_cubit.dart';
import 'package:tv_show_tracker/features/watchlist/data/repositories/watchlist_repository.dart';

class TvShowTrackerApp extends StatelessWidget {
  const TvShowTrackerApp({
    super.key,
    required this.showsRepository,
    required this.watchlistRepository,
  });

  final ShowsRepository showsRepository;
  final WatchlistRepository watchlistRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ShowsRepository>.value(value: showsRepository),
        RepositoryProvider<WatchlistRepository>.value(value: watchlistRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                ShowsBloc(repository: showsRepository)..add(const ShowsFetched()),
          ),
          BlocProvider(
            create: (context) => SearchBloc(repository: showsRepository),
          ),
          BlocProvider(
            create: (context) =>
                WatchlistCubit(repository: watchlistRepository)..load(),
          ),
        ],
        child: MaterialApp(
          title: 'TVMaze',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.dark,
          home: const AppShell(),
        ),
      ),
    );
  }
}
