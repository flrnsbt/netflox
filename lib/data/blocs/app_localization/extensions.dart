import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/public.dart' as p;

import 'app_localization_cubit.dart';

extension StringTranslator on String {
  get tr => p.tr(this);
}

extension TextTranslator on Text {
  get tr => p.tr(data ?? "");
}

extension BuildContextLocalizationExtension on BuildContext {
  Locale get locale => BlocProvider.of<AppLocalization>(this).locale;

  Future<void> setLocale(Locale val) async =>
      BlocProvider.of<AppLocalization>(this).locale = val;

  get supportedLocales => AppLocalization.supportedLocales;
}
