import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 1. Without Equatable: Compares by reference (memory address)
// Two new instances with the same count will evaluate as (a != b).
class RawState {
  final int count;
  RawState(this.count);
}

class RawCubit extends Cubit<RawState> {
  RawCubit() : super(RawState(5));

  // Emits a new instance: (state == nextState) is false, so BLoC emits and triggers rebuild!
  void emitSameValue() => emit(RawState(state.count));
  void increment() => emit(RawState(state.count + 1));
  void reset() => emit(RawState(5));
}

// 2. With Equatable: Compares by value props
// Even with new instances, props [count] == [count] evaluates as (a == b).
class EquatableState extends Equatable {
  final int count;
  const EquatableState(this.count);

  @override
  List<Object?> get props => [count];
}

class EquatableDemoCubit extends Cubit<EquatableState> {
  EquatableDemoCubit() : super(const EquatableState(5));

  // Emits a new instance: BLoC checks (state == nextState), finds true (via Equatable props), and skips!
  void emitSameValue() => emit(EquatableState(state.count));
  void increment() => emit(EquatableState(state.count + 1));
  void reset() => emit(const EquatableState(5));
}
