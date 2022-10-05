import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'filter_parameter.dart';

class PagedDataFilterManager<P extends FilterParameter>
    extends Cubit<PagedRequestParameter<P>> {
  final P _initialParameter;

  PagedDataFilterManager(P initialParameter)
      : _initialParameter = initialParameter,
        super(PagedRequestParameter(initialParameter));

  void reset() {
    updateParameter(_initialParameter);
  }

  void updateParameter(P filterParameter) {
    emit(PagedRequestParameter(filterParameter));
  }

  void nextPage() {
    final currentPage = state.currentPage;
    emit(state.copyWith(page: currentPage + 1));
  }
}

class PagedRequestParameter<P extends FilterParameter> extends Equatable {
  final int currentPage;
  final P currentFilter;

  bool isNewRequest() => currentPage == 1;

  const PagedRequestParameter(this.currentFilter, [this.currentPage = 1]);

  PagedRequestParameter<P> copyWith({P? filter, int? page}) {
    return PagedRequestParameter(filter ?? currentFilter, page ?? currentPage);
  }

  @override
  List<Object?> get props => [currentPage, currentFilter];
}

extension SearchManagerExtension
    on PagedDataFilterManager<SearchFilterParameter> {
  void search(String query) {
    final newParameter = state.currentFilter.copyWith(searchTerms: query);
    updateParameter(newParameter);
  }
}
