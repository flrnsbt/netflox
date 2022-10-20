import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/services/json_file_reader.dart';
import 'package:netflox/services/shared_preferences.dart';

Locale localeFromString(String locale) {
  final array = locale.split("_");
  if (array.length > 1) {
    final languageCode = array.first;
    final countryCode = array.last;
    return Locale(languageCode, countryCode);
  }
  return Locale(array.first);
}

class AppLocalizationState extends Equatable {
  final Locale currentLocale;
  final Map<String, dynamic> values;

  const AppLocalizationState(this.currentLocale, this.values);

  static const AppLocalizationState empty =
      AppLocalizationState(Locale("en"), {});

  @override
  List<Object?> get props => [currentLocale];
}

class AppLocalization extends Cubit<AppLocalizationState> {
  AppLocalization([Locale? locale]) : super(AppLocalizationState.empty) {
    locale ??= localeFromString(
        SharedPreferenceService.instance.get<String>("netflox_language") ??
            Platform.localeName);
    updateLocale(locale);
  }

  Future<void> updateLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) {
      locale = const Locale("en");
    }
    SharedPreferenceService.instance
        .set("netflox_language", locale.languageCode);
    final values = await JsonFileReader.read("${locale.languageCode}.json");
    final state = AppLocalizationState(locale, values);
    emit(state);
  }

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('th')
  ];

  String tr(String key) {
    dynamic s = state.values;
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
    return SynchronousFuture<AppLocalization>(AppLocalization(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

String? languageCodeToCountryCode(String languageCode) {
  return _languageCountryCodeMatch[languageCode];
}

String? countryCodetoLanguageCode(String countryCode) {
  try {
    return _languageCountryCodeMatch.entries
        .firstWhere((e) => e.value == countryCode)
        .value;
  } catch (e) {
    return null;
  }
}

const _languageCountryCodeMatch = {
  "aa": "dj",
  "af": "za",
  "ak": "gh",
  "sq": "al",
  "am": "et",
  "ar": "aa",
  "hy": "am",
  "ay": "wh",
  "az": "az",
  "bm": "ml",
  "be": "by",
  "bn": "bd",
  "bi": "vu",
  "bs": "ba",
  "bg": "bg",
  "my": "mm",
  "ca": "ad",
  "zh": "cn",
  "hr": "hr",
  "cs": "cz",
  "da": "dk",
  "dv": "mv",
  "nl": "nl",
  "dz": "bt",
  "en": "gb",
  "et": "ee",
  "ee": "ew",
  "fj": "fj",
  "fil": "ph",
  "fi": "fi",
  "fr": "fr",
  "ff": "ff",
  "gaa": "gh",
  "ka": "ge",
  "de": "de",
  "el": "gr",
  "gn": "gx",
  "gu": "in",
  "ht": "ht",
  "ha": "ha",
  "he": "il",
  "hi": "in",
  "ho": "pg",
  "hu": "hu",
  "is": "is",
  "ig": "ng",
  "id": "id",
  "ga": "ie",
  "it": "it",
  "ja": "jp",
  "kr": "ne",
  "kk": "kz",
  "km": "kh",
  "kmb": "ao",
  "rw": "rw",
  "kg": "cg",
  "ko": "kr",
  "kj": "ao",
  "ku": "iq",
  "ky": "kg",
  "lo": "la",
  "la": "va",
  "lv": "lv",
  "ln": "cg",
  "lt": "lt",
  "lu": "cd",
  "lb": "lu",
  "mk": "mk",
  "mg": "mg",
  "ms": "my",
  "mt": "mt",
  "mi": "nz",
  "mh": "mh",
  "mn": "mn",
  "mos": "bf",
  "ne": "np",
  "nd": "zw",
  "nso": "za",
  "no": "no",
  "nb": "no",
  "nn": "no",
  "ny": "mw",
  "pap": "aw",
  "ps": "af",
  "fa": "ir",
  "pl": "pl",
  "pt": "pt",
  "pa": "in",
  "qu": "wh",
  "ro": "ro",
  "rm": "ch",
  "rn": "bi",
  "ru": "ru",
  "sg": "cf",
  "sr": "rs",
  "srr": "sn",
  "sn": "zw",
  "si": "lk",
  "sk": "sk",
  "sl": "si",
  "so": "so",
  "snk": "sn",
  "nr": "za",
  "st": "ls",
  "es": "es",
  "sw": "sw",
  "ss": "sz",
  "sv": "se",
  "tl": "ph",
  "tg": "tj",
  "ta": "lk",
  "te": "in",
  "tet": "tl",
  "th": "th",
  "ti": "er",
  "tpi": "pg",
  "ts": "za",
  "tn": "bw",
  "tr": "tr",
  "tk": "tm",
  "uk": "ua",
  "umb": "ao",
  "ur": "pk",
  "uz": "uz",
  "ve": "za",
  "vi": "vn",
  "cy": "gb",
  "wo": "sn",
  "xh": "za",
  "yo": "yo",
  "zu": "za"
};
