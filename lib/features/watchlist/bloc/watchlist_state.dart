part of 'watchlist_cubit.dart';

sealed class WatchlistState extends Equatable {
  const WatchlistState();

  @override
  List<Object?> get props => const [];
}

final class WatchlistInitial extends WatchlistState {
  const WatchlistInitial();
}

final class WatchlistLoading extends WatchlistState {
  const WatchlistLoading();
}

final class WatchlistSuccess extends WatchlistState {
  const WatchlistSuccess(this.shows);

  final List<Show> shows;

  @override
  List<Object?> get props => [shows];
}

final class WatchlistEmpty extends WatchlistState {
  const WatchlistEmpty();
}

final class WatchlistError extends WatchlistState {
  const WatchlistError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
