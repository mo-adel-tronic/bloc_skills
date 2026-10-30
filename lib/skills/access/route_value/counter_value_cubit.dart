import 'package:flutter_bloc/flutter_bloc.dart';

class CounterValueCubit extends Cubit<int> {
  CounterValueCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
  void reset() => emit(0);
}
