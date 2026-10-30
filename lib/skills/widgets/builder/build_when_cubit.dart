import 'package:flutter_bloc/flutter_bloc.dart';

class CounterFilterState {
  final int count;
  final String note;

  const CounterFilterState({required this.count, required this.note});

  CounterFilterState copyWith({int? count, String? note}) {
    return CounterFilterState(
      count: count ?? this.count,
      note: note ?? this.note,
    );
  }
}

/// BuildWhenCubit manages a state with count and an informational note.
/// Used to demonstrate how buildWhen filters rebuilds when only partial state changes.
class BuildWhenCubit extends Cubit<CounterFilterState> {
  BuildWhenCubit()
      : super(const CounterFilterState(count: 0, note: 'Initial state'));

  void increment() {
    final next = state.count + 1;
    emit(state.copyWith(
      count: next,
      note: next.isEven ? 'Even number ($next)' : 'Odd number ($next)',
    ));
  }

  void updateNoteOnly() {
    final timestamp = DateTime.now().second.toString().padLeft(2, '0');
    emit(state.copyWith(
      note: 'Note updated at :$timestamp (count unchanged)',
    ));
  }

  void reset() {
    emit(const CounterFilterState(count: 0, note: 'Reset to initial'));
  }
}
