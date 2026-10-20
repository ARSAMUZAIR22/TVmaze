part of 'search_bloc.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => const [];
}

final class SearchInitial extends SearchState {
  const SearchInitial();
}

final class SearchLoading extends SearchState {
  const SearchLoading(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class SearchSuccess extends SearchState {
  const SearchSuccess(this.query, this.results);

  final String query;
  final List<Show> results;

  @override
  List<Object?> get props => [query, results];
}

final class SearchEmpty extends SearchState {
  const SearchEmpty(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class SearchError extends SearchState {
  const SearchError(this.query, this.message);

  final String query;
  final String message;

  @override
  List<Object?> get props => [query, message];
}
