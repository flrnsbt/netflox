import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../../services/shared_preferences.dart';

class ThemeDataCubit extends Cubit<ThemeDataState> {
  ThemeDataCubit() : super(ThemeDataState.dark(darkThemeData)) {
    _init();
  }

  static final lightThemeData = ThemeData(
    backgroundColor: Colors.white,
    cardColor: Colors.grey[200],
    primaryColor: Colors.pink,
    primaryColorDark: const Color.fromARGB(255, 38, 38, 38),
    colorScheme: ColorScheme.fromSwatch(
      accentColor: Colors.pinkAccent,
      primarySwatch: Colors.pink,
      brightness: Brightness.light,
    ),
    switchTheme: const SwitchThemeData(),
    textTheme: const TextTheme(
        subtitle1:
            TextStyle(fontSize: 20, color: Color.fromARGB(255, 33, 33, 33))),
    appBarTheme: const AppBarTheme(
        elevation: 0,
        titleTextStyle: TextStyle(color: Color.fromARGB(255, 24, 24, 24)),
        backgroundColor: Color.fromARGB(255, 239, 239, 239),
        foregroundColor: Color.fromARGB(255, 39, 39, 39)),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Colors.pink,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        elevation: 10,
        showUnselectedLabels: true,
        landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
        backgroundColor: Color.fromARGB(255, 239, 239, 239)),
    scaffoldBackgroundColor: const Color.fromARGB(255, 249, 249, 249),
  );

  static final darkThemeData = ThemeData(
      primaryColorDark: Colors.grey[900],
      appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color.fromARGB(255, 5, 5, 5),
          foregroundColor: Colors.white),
      cardColor: const Color.fromARGB(255, 20, 20, 20),
      canvasColor: const Color.fromARGB(255, 10, 10, 10),
      primaryColor: Colors.pinkAccent,
      colorScheme: ColorScheme.fromSwatch(
        accentColor: Colors.pinkAccent,
        primarySwatch: Colors.pink,
        brightness: Brightness.dark,
      ),
      textTheme: const TextTheme(
          subtitle1: TextStyle(
              fontSize: 20, color: Color.fromARGB(255, 234, 234, 234))),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.pinkAccent,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
          backgroundColor: Color.fromARGB(255, 15, 15, 15)),
      scaffoldBackgroundColor: const Color.fromARGB(255, 5, 5, 5),
      backgroundColor: Colors.black);

  Future<void> _init() async {
    final modeName =
        await SharedPreferenceService.instance.get("netflox_theme_mode");
    final mode = ThemeMode.values.firstWhere(
      (element) => element.name == modeName,
      orElse: () => ThemeMode.dark,
    );
    emit(_get(mode));
  }

  ThemeDataState _get(ThemeMode mode) {
    var data = mode == ThemeMode.dark ? darkThemeData : lightThemeData;
    return ThemeDataState(mode, data);
  }

  Future<void> changeMode(ThemeMode mode) async {
    await SharedPreferenceService.instance.set("netflox_theme_mode", mode.name);
    emit(_get(mode));
  }
}

class ThemeDataState extends Equatable {
  final ThemeMode mode;
  final ThemeData data;

  static dark(ThemeData data) => ThemeDataState(ThemeMode.dark, data);
  static light(ThemeData data) => ThemeDataState(ThemeMode.light, data);

  const ThemeDataState(this.mode, this.data);

  @override
  List<Object?> get props => [data];
}
