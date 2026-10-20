import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv_show_tracker/core/network/api_exception.dart';
import 'package:tv_show_tracker/core/utils/event_transformers.dart';
import 'package:tv_show_tracker/features/shows/data/models/show.dart';
import 'package:tv_show_tracker/features/shows/data/repositories/shows_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({
    required ShowsRepository repository,
    Duration debounce = const Duration(milliseconds: 400),
  })  : _repository = repository,
        super(const SearchInitial()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: debounceRestartable(debounce),
    );
  }

  final ShowsRepository _repository;

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    emit(SearchLoading(query));
    try {
      final results = await _repository.searchShows(query);
      emit(results.isEmpty ? SearchEmpty(query) : SearchSuccess(query, results));
    } catch (error) {
      emit(SearchError(
        query,
        error is ApiException ? error.message : 'Something went wrong. Try again.',
      ));
    }
  }
}
