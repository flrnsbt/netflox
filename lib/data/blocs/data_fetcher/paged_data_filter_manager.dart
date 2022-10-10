import 'package:flutter_bloc/flutter_bloc.dart';
import 'filter_parameter.dart';

class PagedDataFilterManager<P extends FilterParameter> extends Cubit<P> {
  final P _initialParameter;

  PagedDataFilterManager(P initialParameter)
      : _initialParameter = initialParameter,
        super(initialParameter) {
    Future.delayed(const Duration(seconds: 1), () => emit(initialParameter));
  }

  void reset() {
    updateParameter(_initialParameter);
  }

  void updateParameter(P filterParameter) {
    emit(filterParameter);
  }
}

extension SearchManagerExtension
    on PagedDataFilterManager<SearchFilterParameter> {
  void search(String query) {
    final newParameter = state.copyWith(searchTerms: query);
    updateParameter(newParameter);
  }
}
