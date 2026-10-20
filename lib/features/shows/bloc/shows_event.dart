part of 'shows_bloc.dart';

sealed class ShowsEvent extends Equatable {
  const ShowsEvent();

  @override
  List<Object?> get props => const [];
}

/// Initial load (also used by the Retry button).
final class ShowsFetched extends ShowsEvent {
  const ShowsFetched();
}

/// Pull to refresh. [completer] resolves when the refresh finishes.
final class ShowsRefreshed extends ShowsEvent {
  const ShowsRefreshed({this.completer});

  final Completer<void>? completer;
}

/// Infinite scroll trigger.
final class ShowsNextPageRequested extends ShowsEvent {
  const ShowsNextPageRequested();
}
