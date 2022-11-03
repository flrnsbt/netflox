import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/blocs/data_fetcher/basic_server_fetch_state.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import '../../../data/blocs/data_fetcher/library/library_multi_media_explore_bloc.dart';
import '../../../data/blocs/data_fetcher/paged_data_collection_fetch_bloc.dart';
import '../../../data/models/tmdb/filter_parameter.dart';
import '../../../data/blocs/data_fetcher/paged_data_filter_manager.dart';
import '../../widgets/custom_awesome_dialog.dart';
import '../../widgets/default_sliver_grid.dart';
import '../../widgets/tmdb/filters/filter_menu_dialog.dart';
import '../../widgets/paged_sliver_grid_view.dart';
import '../buttons/refresh_button.dart';
import '../error_widget.dart';

class LibraryExplorerWidget extends StatelessWidget {
  final Set<TMDBLibraryMedia> _data;
  final bool isGridLayout;
  final Widget Function(BuildContext context, TMDBLibraryMedia media)
      itemBuilder;
  final Widget? customAction;
  final String title;

  LibraryExplorerWidget(
      {super.key,
      this.isGridLayout = true,
      this.customAction,
      this.title = 'library',
      required this.itemBuilder})
      : _data = {};

  void showFilterMenuDialog(
      BuildContext context, LibraryFilterParameter filterParameter) {
    CustomAwesomeDialog(
            dialogType: DialogType.noHeader,
            bodyHeaderDistance: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            body: FilterMenuDialog(
                onParameterSubmitted: (newParameter) {
                  context
                      .read<PagedDataFilterManager<LibraryFilterParameter>>()
                      .updateParameter(newParameter);
                },
                currentParameters: filterParameter),
            context: context)
        .show();
  }

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      titleSpacing: 0,
      leading: Navigator.canPop(context)
          ? const BackButton()
          : IconButton(
              icon: const Icon(Icons.video_library),
              onPressed: () {},
            ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ).tr(),
      floating: true,
      actions: [
        if (customAction != null) customAction!,
        const SizedBox(
          width: 5,
        )
      ],
      snap: true,
      centerTitle: false,
      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 5),
            child: BlocBuilder<PagedDataFilterManager<LibraryFilterParameter>,
                LibraryFilterParameter>(builder: (context, state) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: AutoSizeText(
                      "${state.status}-media".tr(context),
                      minFontSize: 10,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                  ),
                  IconButton(
                      style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          fixedSize: MaterialStatePropertyAll(Size.zero),
                          padding: MaterialStatePropertyAll(EdgeInsets.zero)),
                      onPressed: () => showFilterMenuDialog(context, state),
                      icon: const Icon(Icons.filter_list))
                ],
              );
            }),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PagedDataFilterManager<LibraryFilterParameter>,
            LibraryFilterParameter>(
        listener: (context, state) {
          _data.clear();
          context
              .read<LibraryMediaExploreBloc>()
              .add(PagedDataCollectionFetchEvent.setParameter(state));
        },
        child: PagedSliverScrollViewWrapper(
          loadingIndicator: LoadingIndicator(
            controller: LoadingIndicatorController.from(
                context.read<LibraryMediaExploreBloc>()),
            errorBuilder: (context, [error]) {
              if (_data.isNotEmpty) {
                return CustomErrorWidget(
                  errorDescription: error?.toString(),
                );
              } else {
                return RefreshButton(
                  onPressed: () {
                    context
                        .read<LibraryMediaExploreBloc>()
                        .add(PagedDataCollectionFetchEvent.refresh);
                  },
                );
              }
            },
          ),
          onEvent: (eventType) {
            if (eventType == PagedSliverScrollViewEventType.load) {
              context
                  .read<LibraryMediaExploreBloc>()
                  .add(PagedDataCollectionFetchEvent.nextPage);
            } else {
              _data.clear();
              context
                  .read<LibraryMediaExploreBloc>()
                  .add(PagedDataCollectionFetchEvent.refresh);
            }
          },
          header: _buildHeader(context),
          child: SliverPadding(
              padding: const EdgeInsets.only(
                left: 25,
                right: 25,
              ),
              sliver: BlocConsumer<LibraryMediaExploreBloc,
                      BasicServerFetchState<List<TMDBLibraryMedia>>>(
                  listener: (context, state) {
                if (state.hasData()) {
                  _data.addAll(state.result!);
                }
              }, builder: (context, state) {
                final childrenDelegate = SliverChildBuilderDelegate(
                    _renderItems,
                    childCount: _data.length);
                if (isGridLayout) {
                  return DefaultSliverGrid(
                    sliverChildBuilderDelegate: childrenDelegate,
                  );
                } else {
                  return SliverList(delegate: childrenDelegate);
                }
              })),
        ));
  }

  Widget _renderItems(context, index) {
    final media = _data.elementAt(index);
    return itemBuilder(context, media);
  }
}
