import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv_show_tracker/core/network/api_exception.dart';
import 'package:tv_show_tracker/features/shows/data/models/show_details.dart';
import 'package:tv_show_tracker/features/shows/data/repositories/shows_repository.dart';

part 'show_details_state.dart';

class ShowDetailsCubit extends Cubit<ShowDetailsState> {
  ShowDetailsCubit({required ShowsRepository repository, required this.showId})
      : _repository = repository,
        super(const ShowDetailsInitial());

  final ShowsRepository _repository;
  final int showId;

  Future<void> load() async {
    emit(const ShowDetailsLoading());
    try {
      final details = await _repository.getShowDetails(showId);
      if (isClosed) return;
      emit(ShowDetailsSuccess(details));
    } catch (error) {
      if (isClosed) return;
      emit(ShowDetailsError(
        error is ApiException ? error.message : 'Something went wrong. Try again.',
      ));
    }
  }
}
