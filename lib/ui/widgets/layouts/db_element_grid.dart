import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:netflox/data/models/tmdb/element.dart';
import 'package:netflox/data/repositories/tmdb_repository.dart';

import '../db_element_card.dart';

class DbLazyGridLayout<T extends TMDBElement> extends StatefulWidget {
  final TMDBQueryResult<List<T>> result;

  const DbLazyGridLayout({super.key, required this.result});
  @override
  State<DbLazyGridLayout> createState() => _DbLazyGridLayoutState<T>();
}

class _DbLazyGridLayoutState<T extends TMDBElement>
    extends State<DbLazyGridLayout<T>> {
  final PagingController<int, T> pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    pagingController.addPageRequestListener((page) {
      final query = widget.result.query as TMDBCollection;
      query.currentPage = page;
      query.fetch();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PagedGridView(
        pagingController: pagingController,
        builderDelegate: PagedChildBuilderDelegate(
            itemBuilder: (context, item, index) {
              return DbElementCard<T>(element: widget.result.data[index]);
            },
            animateTransitions: true),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 5));
  }
}
