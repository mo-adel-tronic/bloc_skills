import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// ThemeCubit demonstrates managing non-primitive state (ThemeMode enum).
/// Any Dart type (enums, classes, collections) can be the state of a Cubit.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light);

  void toggleTheme() {
    emit(state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
  }

  void setTheme(ThemeMode mode) {
    emit(mode);
  }
}
