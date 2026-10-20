part of 'show_details_cubit.dart';

sealed class ShowDetailsState extends Equatable {
  const ShowDetailsState();

  @override
  List<Object?> get props => const [];
}

final class ShowDetailsInitial extends ShowDetailsState {
  const ShowDetailsInitial();
}

final class ShowDetailsLoading extends ShowDetailsState {
  const ShowDetailsLoading();
}

final class ShowDetailsSuccess extends ShowDetailsState {
  const ShowDetailsSuccess(this.details);

  final ShowDetails details;

  @override
  List<Object?> get props => [details];
}

final class ShowDetailsError extends ShowDetailsState {
  const ShowDetailsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
