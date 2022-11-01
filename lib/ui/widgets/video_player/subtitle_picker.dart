import 'package:chewie/chewie.dart';
import 'package:netflox/data/blocs/app_localization/app_localization_cubit.dart';
import 'package:netflox/data/models/language.dart';
import 'package:flutter/material.dart';
import 'package:language_picker/languages.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/ui/widgets/country_flag_icon.dart';

import '../../../utils/custom_modal_bottom_sheet.dart';

class SubtitlePicker {
  final Map<Language, Subtitles> subtitles;
  Language? _currentSubtitle;
  final void Function(Subtitles? currentSubtitle)? onSubtitleChanged;
  SubtitlePicker({
    this.subtitles = const {},
    this.onSubtitleChanged,
    Language? initialSubtitle,
  })  : assert(initialSubtitle == null ||
            subtitles.keys.contains(initialSubtitle)),
        _currentSubtitle = initialSubtitle;

  show(BuildContext context) {
    CustomModalBottomSheet<Language>(
      defaultValue: _currentSubtitle,
      values: subtitles.keys,
      builder: (value, selected) {
        var countrycode;
        if (value != null) {
          countrycode = languageCodeToCountryCode(value.isoCode);
        }
        return Row(children: [
          if (countrycode != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: CountryFlagIcon(countryCode: countrycode),
            ),
          Text(
            value?.tr(context) ?? 'none',
            style: CustomModalBottomSheet.getOverflowMenuElementTextStyle(
                selected, Theme.of(context).highlightColor),
          ).tr()
        ]);
      },
      onSelected: (value) {
        Navigator.of(context, rootNavigator: true).pop();
        _currentSubtitle = value;
        final subtitle = subtitles[value];
        onSubtitleChanged?.call(subtitle);
      },
    ).show(context);
  }
}
