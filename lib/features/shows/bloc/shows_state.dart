part of 'shows_bloc.dart';

sealed class ShowsState extends Equatable {
  const ShowsState();

  @override
  List<Object?> get props => const [];
}

final class ShowsInitial extends ShowsState {
  const ShowsInitial();
}

final class ShowsLoading extends ShowsState {
  const ShowsLoading();
}

final class ShowsEmpty extends ShowsState {
  const ShowsEmpty();
}

final class ShowsError extends ShowsState {
  const ShowsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ShowsSuccess extends ShowsState {
  const ShowsSuccess({
    required this.shows,
    required this.trending,
    required this.hasReachedMax,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final List<Show> shows;
  final List<Show> trending;
  final bool hasReachedMax;
  final bool isLoadingMore;

  /// Set when loading the next page fails. Existing results stay visible.
  final String? loadMoreError;

  ShowsSuccess copyWith({
    List<Show>? shows,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? loadMoreError,
    bool clearLoadMoreError = false,
  }) {
    return ShowsSuccess(
      shows: shows ?? this.shows,
      trending: trending,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError:
          clearLoadMoreError ? null : (loadMoreError ?? this.loadMoreError),
    );
  }

  @override
  List<Object?> get props =>
      [shows, trending, hasReachedMax, isLoadingMore, loadMoreError];
}
