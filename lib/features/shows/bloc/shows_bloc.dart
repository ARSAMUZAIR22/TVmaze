import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv_show_tracker/core/network/api_exception.dart';
import 'package:tv_show_tracker/features/shows/data/models/show.dart';
import 'package:tv_show_tracker/features/shows/data/repositories/shows_repository.dart';

part 'shows_event.dart';
part 'shows_state.dart';

class ShowsBloc extends Bloc<ShowsEvent, ShowsState> {
  ShowsBloc({required ShowsRepository repository})
      : _repository = repository,
        super(const ShowsInitial()) {
    on<ShowsFetched>(_onFetched, transformer: droppable());
    on<ShowsRefreshed>(_onRefreshed, transformer: droppable());
    on<ShowsNextPageRequested>(_onNextPageRequested, transformer: droppable());
  }

  static const _trendingCount = 10;

  final ShowsRepository _repository;
  int _nextPage = 0;

  Future<void> _onFetched(ShowsFetched event, Emitter<ShowsState> emit) async {
    emit(const ShowsLoading());
    await _loadFirstPage(emit);
  }

  Future<void> _onRefreshed(ShowsRefreshed event, Emitter<ShowsState> emit) async {
    try {
      if (state is! ShowsSuccess) emit(const ShowsLoading());
      await _loadFirstPage(emit, keepExistingOnError: true);
    } finally {
      event.completer?.complete();
    }
  }

  Future<void> _onNextPageRequested(
    ShowsNextPageRequested event,
    Emitter<ShowsState> emit,
  ) async {
    final current = state;
    if (current is! ShowsSuccess || current.hasReachedMax || current.isLoadingMore) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true, clearLoadMoreError: true));
    try {
      final page = await _repository.getShows(_nextPage);
      _nextPage++;
      emit(current.copyWith(
        shows: [...current.shows, ...page.shows],
        hasReachedMax: !page.hasMore,
        isLoadingMore: false,
        clearLoadMoreError: true,
      ));
    } catch (error) {
      emit(current.copyWith(isLoadingMore: false, loadMoreError: _messageFor(error)));
    }
  }

  Future<void> _loadFirstPage(
    Emitter<ShowsState> emit, {
    bool keepExistingOnError = false,
  }) async {
    try {
      final page = await _repository.getShows(0);
      _nextPage = 1;
      if (page.shows.isEmpty) {
        emit(const ShowsEmpty());
        return;
      }
      emit(ShowsSuccess(
        shows: page.shows,
        trending: _pickTrending(page.shows),
        hasReachedMax: !page.hasMore,
      ));
    } catch (error) {
      if (keepExistingOnError && state is ShowsSuccess) return;
      emit(ShowsError(_messageFor(error)));
    }
  }

  /// TVMaze has no trending endpoint, so "Trending Now" is the highest
  /// rated shows with artwork from the first page.
  List<Show> _pickTrending(List<Show> shows) {
    final rated = shows
        .where((show) => show.rating != null && show.posterUrl != null)
        .toList()
      ..sort((a, b) => b.rating!.compareTo(a.rating!));
    return rated.take(_trendingCount).toList();
  }

  String _messageFor(Object error) => error is ApiException
      ? error.message
      : 'Something went wrong. Try again.';
}
