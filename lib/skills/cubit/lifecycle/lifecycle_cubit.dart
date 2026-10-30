import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

enum TimerStatus { initial, running, paused }

class TimerState {
  final int seconds;
  final TimerStatus status;
  final List<String> logs;

  const TimerState({
    required this.seconds,
    required this.status,
    required this.logs,
  });

  TimerState copyWith({
    int? seconds,
    TimerStatus? status,
    List<String>? logs,
  }) {
    return TimerState(
      seconds: seconds ?? this.seconds,
      status: status ?? this.status,
      logs: logs ?? this.logs,
    );
  }
}

/// LifecycleCubit demonstrates:
/// 1. `onChange`: intercepts state changes before they reach UI.
/// 2. `close()`: cancels active Timer subscriptions to prevent memory leaks.
class LifecycleCubit extends Cubit<TimerState> {
  Timer? _timer;

  LifecycleCubit()
      : super(const TimerState(
          seconds: 0,
          status: TimerStatus.initial,
          logs: ['Cubit initialized with state: 0s (initial)'],
        ));

  void start() {
    if (state.status == TimerStatus.running) return;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick();
    });

    _recordChangeAndEmit(state.copyWith(status: TimerStatus.running));
  }

  void _tick() {
    _recordChangeAndEmit(state.copyWith(
      seconds: state.seconds + 1,
      status: TimerStatus.running,
    ));
  }

  void pause() {
    _timer?.cancel();
    _recordChangeAndEmit(state.copyWith(status: TimerStatus.paused));
  }

  void reset() {
    _timer?.cancel();
    _recordChangeAndEmit(state.copyWith(
      seconds: 0,
      status: TimerStatus.initial,
    ));
  }

  void clearLogs() {
    emit(state.copyWith(logs: []));
  }

  void _recordChangeAndEmit(TimerState next) {
    final entry =
        'State: ${state.seconds}s (${state.status.name}) -> ${next.seconds}s (${next.status.name})';
    final updated = List<String>.from(state.logs)..add(entry);
    if (updated.length > 25) {
      updated.removeAt(0);
    }
    emit(next.copyWith(logs: updated));
  }

  @override
  void onChange(Change<TimerState> change) {
    super.onChange(change);
    // Useful for global debugging, logging to Sentry, Crashlytics, etc.
    // print('LifecycleCubit onChange: ${change.currentState} -> ${change.nextState}');
  }

  @override
  Future<void> close() {
    // ALWAYS cancel timers, stream subscriptions, and controllers here!
    _timer?.cancel();
    return super.close();
  }
}
