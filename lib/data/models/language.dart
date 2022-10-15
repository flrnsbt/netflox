import 'package:flutter/widgets.dart';
import 'package:language_picker/languages.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';

import '../blocs/app_localization/app_localization_cubit.dart';

extension LocalizedLanguageExtension on Language {
  String tr(BuildContext context) => "language-$isoCode".tr(context);

  String? countryCode() => languageCodeToCountryCode(isoCode);
}

abstract class LocalizedLanguage {
  static List<Language> sortedLocalizedLanguage(BuildContext context) =>
      Languages.defaultLanguages
        ..sort((a, b) {
          final atr = a.tr(context);
          final btr = b.tr(context);
          return atr.compareTo(btr);
        });
}
