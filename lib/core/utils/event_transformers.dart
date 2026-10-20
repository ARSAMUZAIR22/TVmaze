import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:stream_transform/stream_transform.dart';

/// Waits for [duration] of inactivity before handling an event and cancels
/// any in-flight handler when a newer event arrives. Prevents stale search
/// results from overwriting fresh ones.
EventTransformer<E> debounceRestartable<E>(Duration duration) {
  return (events, mapper) =>
      restartable<E>().call(events.debounce(duration), mapper);
}
