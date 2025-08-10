import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ThemeModeOption { light, dark, system }

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.dark);

  void setTheme(ThemeModeOption option) {
    switch (option) {
      case ThemeModeOption.light:
        emit(ThemeMode.light);
        break;
      case ThemeModeOption.dark:
        emit(ThemeMode.dark);
        break;
      case ThemeModeOption.system:
        emit(ThemeMode.system);
        break;
    }
  }
}