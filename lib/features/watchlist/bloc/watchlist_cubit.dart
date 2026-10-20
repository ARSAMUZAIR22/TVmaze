import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv_show_tracker/features/shows/data/models/show.dart';
import 'package:tv_show_tracker/features/watchlist/data/repositories/watchlist_repository.dart';

part 'watchlist_state.dart';

/// App-wide watchlist. Updates are optimistic: the UI changes immediately
/// and rolls back if writing to storage fails.
class WatchlistCubit extends Cubit<WatchlistState> {
  WatchlistCubit({required WatchlistRepository repository})
      : _repository = repository,
        super(const WatchlistInitial());

  final WatchlistRepository _repository;
  List<Show> _shows = const [];

  bool contains(int showId) => _shows.any((show) => show.id == showId);

  Future<void> load() async {
    emit(const WatchlistLoading());
    try {
      _shows = List.unmodifiable(await _repository.getWatchlist());
      if (isClosed) return;
      _emitCurrent();
    } catch (_) {
      if (isClosed) return;
      emit(const WatchlistError('Could not load your watchlist.'));
    }
  }

  Future<void> toggle(Show show) =>
      contains(show.id) ? remove(show.id) : add(show);

  /// Newest first by default. [index] restores a show to its old position
  /// (used by Undo).
  Future<void> add(Show show, {int index = 0}) async {
    if (contains(show.id)) return;
    final updated = [..._shows];
    updated.insert(math.max(0, math.min(index, updated.length)), show);
    await _update(updated);
  }

  Future<void> remove(int showId) async {
    if (!contains(showId)) return;
    await _update(_shows.where((show) => show.id != showId).toList());
  }

  Future<void> clear() => _update(const []);

  Future<void> _update(List<Show> updated) async {
    final previous = _shows;
    _shows = List.unmodifiable(updated);
    _emitCurrent();
    try {
      await _repository.saveWatchlist(_shows);
    } catch (error) {
      developer.log('Watchlist save failed', error: error, name: 'WatchlistCubit');
      _shows = previous;
      if (!isClosed) _emitCurrent();
    }
  }

  void _emitCurrent() =>
      emit(_shows.isEmpty ? const WatchlistEmpty() : WatchlistSuccess(_shows));
}
