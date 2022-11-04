import 'dart:ui';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    textTheme: const TextTheme(subtitle1: TextStyle(fontSize: 20)).apply(
        bodyColor: const Color.fromARGB(255, 47, 47, 47),
        displayColor: const Color.fromARGB(255, 47, 47, 47)),
    appBarTheme: AppBarTheme(
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark
            .copyWith(statusBarColor: Colors.transparent),
        titleTextStyle: const TextStyle(color: Color.fromARGB(255, 24, 24, 24)),
        backgroundColor: const Color.fromARGB(255, 239, 239, 239),
        foregroundColor: const Color.fromARGB(255, 39, 39, 39)),
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
      bannerTheme: const MaterialBannerThemeData(
          contentTextStyle: TextStyle(
            fontSize: 16,
          ),
          backgroundColor: Color.fromARGB(255, 22, 22, 22)),
      appBarTheme: AppBarTheme(
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light
              .copyWith(statusBarColor: Colors.transparent),
          backgroundColor: const Color.fromARGB(255, 5, 5, 5),
          foregroundColor: Colors.white),
      cardColor: const Color.fromARGB(255, 22, 22, 22),
      canvasColor: const Color.fromARGB(255, 8, 8, 8),
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
          backgroundColor: Color.fromARGB(255, 12, 12, 12)),
      scaffoldBackgroundColor: const Color.fromARGB(255, 2, 2, 2),
      backgroundColor: Colors.black);

  void _init() async {
    final String? modeName =
        SharedPreferenceService.instance.get("netflox_theme_mode");

    final mode = Brightness.values.firstWhere(
      (element) => element.name == modeName,
      orElse: () => window.platformBrightness,
    );
    emit(_get(mode));
  }

  ThemeDataState _get(Brightness mode) {
    var data = mode == Brightness.dark ? darkThemeData : lightThemeData;
    return ThemeDataState(mode, data);
  }

  Future<void> change(Brightness brightness) async {
    await SharedPreferenceService.instance
        .set("netflox_theme_mode", brightness.name);
    emit(_get(brightness));
  }
}

class ThemeDataState extends Equatable {
  final Brightness brightness;
  final ThemeData data;

  static dark(ThemeData data) => ThemeDataState(Brightness.dark, data);
  static light(ThemeData data) => ThemeDataState(Brightness.light, data);

  const ThemeDataState(this.brightness, this.data);

  @override
  List<Object?> get props => [brightness];
}
