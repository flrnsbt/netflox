import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Locale localeFromString(String locale) {
  final array = Platform.localeName.split("_");
  final languageCode = array.first;
  final countryCode = array.last;
  return Locale(languageCode, countryCode);
}

class AppLocalization extends Cubit<Locale> {
  AppLocalization._(Locale locale) : super(locale);

  static AppLocalization init([Locale? locale]) {
    locale ??= localeFromString(Platform.localeName);
    return instance = AppLocalization._(locale);
  }

  static AppLocalization? instance;

  Locale get locale => state;

  set locale(Locale locale) {
    emit(locale);
  }

  static const _localizedValues = <String, Map<String, dynamic>>{
    'en': {},
    'fr': {},
    'th': {}
  };

  static List<Locale> get supportedLocales =>
      _localizedValues.keys.map((e) => Locale(e)).toList();

  tr(String key) {
    dynamic s = _localizedValues[locale.languageCode]!;
    for (var k in key.split(".")) {
      s = s[k];
      if (s == null) {
        break;
      }
    }
    return s ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalization> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalization.supportedLocales.contains(locale);

  @override
  Future<AppLocalization> load(Locale locale) {
    return SynchronousFuture<AppLocalization>(AppLocalization.init(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
