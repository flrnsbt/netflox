import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/app_localization_cubit.dart'
    as a;
import '../../../ui/widgets/custom_awesome_dialog.dart';
import '../../../ui/widgets/custom_banner.dart';
import 'app_localization_cubit.dart';
import 'app_localization_widget.dart';

extension StringTranslator on String {
  String tr(BuildContext context) => context.tr(this);
}

extension TextTranslator on Text {
  Text tr() => LocalizedText.fromText(this);
}

extension CustomBannerOptionTranslator on CustomBannerOptions {
  CustomBannerOptions tr(BuildContext context) {
    return copyWith(message: message.tr(context));
  }
}

extension CustomDialogTranslator on CustomAwesomeDialog {
  CustomAwesomeDialog tr() => copyWith(
      btnOkText: btnOkText?.tr(context),
      btnCancelText: btnCancelText?.tr(context),
      title: title?.tr(context),
      desc: desc?.tr(context));
}

extension EnumTranslator on Enum {
  String tr(BuildContext context) => context.tr(name);
}

extension BuildContextLocalizationExtension on BuildContext {
  Locale get locale =>
      BlocProvider.of<AppLocalization>(this).state.currentLocale;

  Future<void> setLocale(Locale val) async =>
      BlocProvider.of<AppLocalization>(this).updateLocale(val);

  get supportedLocales => AppLocalization.supportedLocales;
}

extension LocaleToCountryInterface on Locale {
  String? get languageCodeToCountry =>
      a.languageCodeToCountryCode(languageCode);
}

extension AppLocalizationTranslatorExtension on BuildContext {
  String tr(String key) => read<AppLocalization>().tr(key);
}
