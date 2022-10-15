import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/ui/widgets/filters/filter_widget.dart';
import '../../../data/models/tmdb/filter_parameter.dart';
import '../../../data/models/tmdb/library_media_information.dart';
import '../../../data/models/tmdb/type.dart';

abstract class FilterMenuBuilder<P extends FilterParameter>
    extends Cubit<List<FilterWidget>> {
  final P _filterParameter;

  FilterMenuBuilder(P filterParameter)
      : _filterParameter = filterParameter,
        super([]) {
    _init();
  }

  void _init() {
    _buildFilterItems();
    emit(_buildFilterItems());
  }

  void reset() {
    for (var element in state) {
      element.controller.reset();
    }
  }

  static FilterMenuBuilder<P> from<P extends FilterParameter>(P parameter) {
    if (P == SearchFilterParameter) {
      return SearchFilterMenuBuilder(parameter as SearchFilterParameter)
          as FilterMenuBuilder<P>;
    } else if (P == DiscoverFilterParameter) {
      return DiscoverFilterMenuBuilder(parameter as DiscoverFilterParameter)
          as FilterMenuBuilder<P>;
    } else if (P == LibraryFilterParameter) {
      return LibraryFilterMenuBuilder(parameter as LibraryFilterParameter)
          as FilterMenuBuilder<P>;
    } else if (P == SimpleMultimediaFilterParameter) {
      return SimpleMultimediaFilterMenuBuilder(
          parameter as SimpleMultimediaFilterParameter) as FilterMenuBuilder<P>;
    }
    throw UnimplementedError();
  }

  List<FilterWidget> _buildFilterItems();

  @override
  Future<void> close() {
    for (var element in state) {
      element.controller.dispose();
    }
    return super.close();
  }

  P save() {
    final data = <String, dynamic>{};
    for (var element in state) {
      data.putIfAbsent(element.name, () => element.controller.currentValue);
    }
    return FilterParameter.fromMap(data);
  }
}

abstract class TypedFilterMenuBuilder<T extends TMDBPrimaryMedia,
    P extends SingleTypeFilterParameter<T>> extends FilterMenuBuilder<P> {
  final FilterCheckBoxWidget<TMDBType<TMDBMedia>> _mediaTypePicker;
  TypedFilterMenuBuilder(super.filterParameter)
      : _currentType = filterParameter.type,
        _mediaTypePicker =
            NetfloxFilters.mediaType<P>(type: filterParameter.type);

  @override
  void _init() {
    _mediaTypePicker.controller.addListener(_onTypeChanged);
    _build();
  }

  @override
  Future<void> close() {
    _mediaTypePicker.controller.removeListener(_onTypeChanged);
    return super.close();
  }

  void _onTypeChanged() {
    final newType = _mediaTypePicker.controller.currentValue!;
    _currentType = newType as TMDBType<T>;
    _build();
  }

  void _build() {
    final newState =
        List<FilterWidget>.from([_mediaTypePicker, ..._buildFilterItems()]);
    emit(newState);
  }

  TMDBType<T> _currentType;
}

class SearchFilterMenuBuilder
    extends TypedFilterMenuBuilder<TMDBPrimaryMedia, SearchFilterParameter> {
  SearchFilterMenuBuilder(super.filterParameter);

  @override
  List<FilterWidget> _buildFilterItems() {
    return [
      if (_currentType.isMultimedia())
        NetfloxFilters.year(value: _filterParameter.year)
    ];
  }
}

class DiscoverFilterMenuBuilder
    extends TypedFilterMenuBuilder<TMDBMultiMedia, DiscoverFilterParameter> {
  DiscoverFilterMenuBuilder(super.filterParameter);

  @override
  List<FilterWidget> _buildFilterItems() {
    assert(_currentType != TMDBMultiMediaType.any);
    return [
      NetfloxFilters.language(
          selectedLanguage: _filterParameter.originalLanguage),
      NetfloxFilters.year(value: _filterParameter.year),
      NetfloxFilters.genres(
        _currentType,
        selectedValues: _filterParameter.genres,
      ),
      NetfloxFilters.sortBy(
        _currentType,
        sortCriterion: _filterParameter.sortCriterion,
      ),
      NetfloxFilters.orderBy(
        sortOrder: _filterParameter.sortOrder,
      ),
    ];
  }
}

class LibraryFilterMenuBuilder
    extends FilterMenuBuilder<LibraryFilterParameter> {
  LibraryFilterMenuBuilder(super.filterParameter);

  @override
  List<FilterWidget> _buildFilterItems() {
    return [
      FilterCheckBoxWidget.multi(
          name: 'media_type',
          items: TMDBMultiMediaType.all,
          enableDeselect: false,
          selectedItems: _filterParameter.types),
      FilterCheckBoxWidget.radio(
          name: 'media_status',
          items: [
            MediaStatus.available,
            MediaStatus.pending,
            MediaStatus.rejected
          ],
          selectedItem: _filterParameter.status),
      FilterCheckBoxWidget.radio(
          name: "sort_by",
          items: [LibrarySortCriterion.addedOn],
          selectedItem: _filterParameter.sortCriterion),
      NetfloxFilters.orderBy(
        sortOrder: _filterParameter.sortOrder,
      ),
    ];
  }
}

class SimpleMultimediaFilterMenuBuilder
    extends FilterMenuBuilder<SimpleMultimediaFilterParameter> {
  SimpleMultimediaFilterMenuBuilder(super.filterParameter);

  @override
  List<FilterWidget> _buildFilterItems() {
    return [
      FilterCheckBoxWidget.multi(
          name: 'media_type',
          items: TMDBMultiMediaType.all,
          enableDeselect: false,
          selectedItems: _filterParameter.types),
      FilterCheckBoxWidget.radio(
          name: "sort_by",
          items: TMDBSortCriterion.all,
          selectedItem: _filterParameter.sortCriterion),
      NetfloxFilters.orderBy(
        sortOrder: _filterParameter.order,
      ),
    ];
  }
}
