import 'package:flutter_bloc/flutter_bloc.dart';

/// CounterCubit manages an integer state.
/// Notice:
/// 1. Extends `Cubit<int>`
/// 2. Sets initial state via super(0)
/// 3. Emits new states via emit(state + 1)
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
  void reset() => emit(0);
}
