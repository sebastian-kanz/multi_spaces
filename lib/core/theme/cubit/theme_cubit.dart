import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.dark);

  /// Add 1 to the current state.
  void toggle() => emit(
        state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
      );

  void setLight() => emit(ThemeMode.light);
  void setDark() => emit(ThemeMode.dark);
}
