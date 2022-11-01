import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:group_button/group_button.dart';
import 'package:language_picker/language_picker_dialog.dart';
import 'package:language_picker/languages.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/blocs/theme/theme_cubit_cubit.dart';
import 'package:netflox/data/models/language.dart';
import 'package:netflox/data/models/tmdb/genre.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/ui/widgets/country_flag_icon.dart';
import 'package:netflox/ui/widgets/see_more_widget.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/tmdb/filter_parameter.dart';
import '../../../../data/models/tmdb/type.dart';

mixin FilterWidget<T> on Widget {
  String get name;
  FilterWidgetController<T> get controller;

  Widget _buildTitle(BuildContext context) {
    return Text(
      name.tr(context),
      style: TextStyle(
          fontSize: 15,
          color: Theme.of(context).disabledColor,
          fontWeight: FontWeight.bold),
    );
  }
}

class LanguagePickerFilterWidget extends StatelessWidget
    with FilterWidget<Language?> {
  LanguagePickerFilterWidget(
      {super.key, Language? selectedLanguage, required this.name})
      : controller = LanguageWidgetController(currentValue: selectedLanguage);

  void _showPicker(BuildContext context) => showDialog(
        context: context,
        builder: (context) => Theme(
          data: context.read<ThemeDataCubit>().state.data.copyWith(
              dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor),
          child: LanguagePickerDialog(
              contentPadding: EdgeInsets.zero,
              isDividerEnabled: true,
              languages: LocalizedLanguage.sortedLocalizedLanguage(context),
              titlePadding: const EdgeInsets.all(8.0),
              itemBuilder: (language) {
                final countryCode = language.countryCode();
                return SizedBox(
                  height: 25,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: AutoSizeText(
                            language.tr(context),
                            maxLines: 1,
                            minFontSize: 8,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        if (countryCode != null)
                          CountryFlagIcon(
                            countryCode: countryCode,
                          ),
                      ]),
                );
              },
              isSearchable: false,
              title: const Text('select-language').tr(),
              onValuePicked: (Language language) {
                (controller as LanguageWidgetController).currentValue =
                    language;
              }),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTitle(context),
        const Spacer(),
        ChangeNotifierProvider<LanguageWidgetController>(
            create: (context) => controller as LanguageWidgetController,
            builder: (context, child) => Consumer<LanguageWidgetController>(
                    builder: (context, _, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_.currentValue != null)
                        CloseButton(
                          color: Theme.of(context).highlightColor,
                          onPressed: () => _.reset(),
                        ),
                      TextButton(
                          style: ButtonStyle(
                              padding: const MaterialStatePropertyAll(
                                  EdgeInsets.symmetric(horizontal: 10)),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                          width: 1,
                                          color:
                                              Theme.of(context).hintColor)))),
                          onPressed: () => _showPicker(context),
                          child: Text(_.currentValue?.tr(context) ?? ''))
                    ],
                  );
                }))
      ],
    );
  }

  @override
  final FilterWidgetController<Language?> controller;

  @override
  final String name;
}

class NumberPickerFilterWidget extends StatelessWidget with FilterWidget<int?> {
  @override
  final String name;
  final int minValue;
  final int maxValue;

  NumberPickerFilterWidget(this.name,
      {super.key, int? value, this.minValue = 1900, int? maxValue})
      : maxValue = maxValue ?? DateTime.now().year,
        controller = NumberFilterController(value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTitle(context),
        const Spacer(),
        SizedBox(
          width: 70,
          height: kFilterCheckBoxButtonHeight,
          child: TextField(
            keyboardType: TextInputType.number,
            maxLines: 1,
            maxLength: 4,
            textAlign: TextAlign.center,
            onChanged: (value) {
              if (value.length >= 4) {
                var number = int.parse(value);
                final year = DateTime.now().year;
                if (number > year) {
                  number = year;
                } else if (number < 1900) {
                  number = 1900;
                }
                controller.text = number.toString();
              }
            },
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).primaryColor,
                fontFamily: "Verdana"),
            decoration: InputDecoration(
                isDense: true,
                alignLabelWithHint: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                counterText: "",
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Theme.of(context).highlightColor),
                  borderRadius: BorderRadius.circular(10),
                )),
            controller: controller,
          ),
        ),
      ],
    );
  }

  @override
  final NumberFilterController controller;
}

const kFilterCheckBoxButtonHeight = 30.0;

class FilterCheckBoxWidget<T> extends StatelessWidget with FilterWidget<T> {
  @override
  final String name;
  final bool inverted;
  final bool _isRadio;

  final void Function(bool selected, T value)? onSelected;

  static const kFilterCheckBoxButtonYSpacing = 10.0;
  static const kFilterCheckBoxMaxRow = 2;

  @override
  final FilterCheckBoxController<T> controller;
  final bool enableDeselect;

  FilterCheckBoxWidget._(this.name,
      {super.key,
      this.onSelected,
      this.enableDeselect = false,
      this.inverted = false,
      bool isRadio = false,
      required this.controller})
      : _isRadio = isRadio,
        assert(controller.items.isNotEmpty);

  factory FilterCheckBoxWidget(
      {required String name,
      bool enableDeselect = true,
      bool inverted = false,
      required bool isRadio,
      required List<T> items,
      dynamic selectedItems}) {
    var controller;
    if (isRadio) {
      assert(selectedItems is T?);
      controller = FilterRadioCheckBoxController(items, selectedItems);
      assert(inverted == false);
    } else {
      assert(selectedItems is List<T>?);
      controller = FilterMultiCheckBoxController(items, selectedItems);
    }
    return FilterCheckBoxWidget._(
      name,
      enableDeselect: enableDeselect,
      inverted: inverted,
      isRadio: isRadio,
      controller: controller,
    );
  }

  static FilterCheckBoxWidget<List<T>> multi<T>(
      {required String name,
      bool enableDeselect = true,
      bool inverted = false,
      required List<T> items,
      List<T> selectedItems = const []}) {
    return FilterCheckBoxWidget._(name,
        enableDeselect: enableDeselect,
        isRadio: false,
        inverted: inverted,
        controller: FilterMultiCheckBoxController<T>(items, selectedItems));
  }

  static FilterCheckBoxWidget<T> radio<T>(
      {required String name,
      bool enableDeselect = false,
      T? selectedItem,
      required List<T> items}) {
    return FilterCheckBoxWidget._(name,
        enableDeselect: enableDeselect,
        isRadio: true,
        inverted: false,
        controller: FilterRadioCheckBoxController<T>(items, selectedItem));
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildTitle(context),
        SeeMoreWidget(
            maxHeight:
                (kFilterCheckBoxButtonHeight + kFilterCheckBoxButtonYSpacing) *
                    kFilterCheckBoxMaxRow,
            child: GroupButton(
              buttonBuilder: _buttonBuilder,
              buttons: controller.items,
              controller: controller,
              onSelected: (value, index, isSelected) {
                if (!_isRadio && !enableDeselect) {
                  if (controller.selectedIndexes.isEmpty) {
                    controller.selectIndex(index);
                  }
                }
                if (onSelected != null) {
                  onSelected!(isSelected, value);
                }
              },
              isRadio: _isRadio,
              enableDeselect: enableDeselect,
              options: const GroupButtonOptions(
                direction: Axis.horizontal,
                textAlign: TextAlign.center,
                spacing: 10,
                runSpacing: kFilterCheckBoxButtonYSpacing,
                mainGroupAlignment: MainGroupAlignment.start,
                alignment: Alignment.center,
              ),
            ))
      ],
    );
  }

  Widget _buttonBuilder(bool selected, value, BuildContext context) {
    if (inverted) {
      selected = !selected;
    }
    final color =
        selected ? Theme.of(context).primaryColor : Theme.of(context).hintColor;
    return Container(
      height: kFilterCheckBoxButtonHeight,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(
          color: color,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        value.toString().tr(context),
        style: TextStyle(color: color),
      ),
    );
  }
}

class NumberFilterController extends TextEditingController
    with FilterWidgetController<int> {
  @override
  int? get currentValue => int.tryParse(text);

  NumberFilterController([this.defaultValue])
      : super(text: defaultValue?.toString() ?? "");

  @override
  final int? defaultValue;

  @override
  void reset() {
    text = defaultValue?.toString() ?? "";
  }
}

mixin FilterCheckBoxController<T> on GroupButtonController
    implements FilterWidgetController<T> {
  List get items;
}

class FilterRadioCheckBoxController<T> extends GroupButtonController
    with FilterCheckBoxController<T> {
  FilterRadioCheckBoxController(this.items, [this.defaultValue])
      : super(selectedIndex: _getIndex(items, defaultValue));

  static int? _getIndex(List items, item) {
    if (item == null) return null;
    return items.indexOf(item);
  }

  @override
  T? get currentValue => selectedIndex != null ? items[selectedIndex!] : null;

  @override
  final List<T> items;

  @override
  final T? defaultValue;

  @override
  void reset() {
    final index = _getIndex(items, defaultValue);
    if (index != null) {}
    selectIndex(index!);
  }
}

class FilterMultiCheckBoxController<T> extends GroupButtonController
    with FilterCheckBoxController<List<T>> {
  FilterMultiCheckBoxController(this.items, [this.defaultValue = const []])
      : super(selectedIndexes: _getIndexes(items, defaultValue));

  static List<int> _getIndexes(List items, List selectedItems) {
    final indexes = <int>[];
    for (var item in selectedItems) {
      final index = items.indexOf(item);
      if (index != -1) {
        indexes.add(index);
      }
    }
    return indexes;
  }

  @override
  List<T> get currentValue =>
      selectedIndexes.map((index) => items[index]).toList(growable: false);

  @override
  final List<T> items;

  @override
  final List<T> defaultValue;

  @override
  void reset() {
    final indexes = _getIndexes(items, defaultValue);
    selectIndexes(indexes);
  }
}

class LanguageWidgetController extends ChangeNotifier
    with FilterWidgetController<Language?> {
  Language? _currentValue;

  set currentValue(Language? value) {
    _currentValue = value;
    notifyListeners();
  }

  @override
  final Language? defaultValue;

  LanguageWidgetController({Language? currentValue})
      : _currentValue = currentValue,
        defaultValue = null;

  @override
  void reset() {
    currentValue = defaultValue;
  }

  @override
  Language? get currentValue => _currentValue;
}

mixin FilterWidgetController<T> on ChangeNotifier {
  T? get currentValue;
  T? get defaultValue;

  void reset();
}

class NetfloxFilters {
  static FilterCheckBoxWidget<TMDBType<TMDBMedia>>
      mediaType<P extends SingleTypeFilterParameter>(
              {TMDBType<TMDBMedia>? type}) =>
          FilterCheckBoxWidget.radio<TMDBType<TMDBMedia>>(
              name: 'media_type',
              items: (P == DiscoverFilterParameter
                      ? TMDBMultiMediaType.all
                      : TMDBPrimaryMediaType.values)
                  .cast(),
              selectedItem: type);

  static FilterCheckBoxWidget<TMDBSortCriterion>
      sortBy<T extends TMDBMultiMedia>(TMDBType<T> type,
              {TMDBSortCriterion<T>? sortCriterion}) =>
          FilterCheckBoxWidget.radio(
              name: "sort_by",
              selectedItem: sortCriterion ?? TMDBSortCriterion.popularity,
              items: [
                if (type.isMovie())
                  ...TMDBMovieSortCriterion.all
                else
                  ...TMDBTVSortCriterion.all
              ]);

  static FilterCheckBoxWidget<SortOrder> orderBy<T extends TMDBMultiMedia>(
          {SortOrder? sortOrder}) =>
      FilterCheckBoxWidget.radio(
          name: "order_by",
          selectedItem: sortOrder ?? SortOrder.desc,
          items: SortOrder.values);

  static LanguagePickerFilterWidget language(
          {Language? selectedLanguage, String name = 'language'}) =>
      LanguagePickerFilterWidget(
          selectedLanguage: selectedLanguage, name: name);

  static FilterCheckBoxWidget<List<TMDBMultiMediaGenre>>
      genres<T extends TMDBMultiMedia>(TMDBType<T> type,
              {List<TMDBMultiMediaGenre<T>> selectedValues = const []}) =>
          FilterCheckBoxWidget.multi(
              name: "genres",
              items: [
                if (type.isMovie())
                  ...TMDBMovieGenre.values
                else
                  ...TMDBTVGenre.values
              ],
              selectedItems: selectedValues);

  static NumberPickerFilterWidget year({int? value}) =>
      NumberPickerFilterWidget(
        'year',
        value: value,
      );
}
