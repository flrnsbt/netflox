import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/blocs/connectivity/connectivity_manager.dart';
import 'package:netflox/data/blocs/data_fetcher/basic_server_fetch_state.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:provider/provider.dart';
import '../../../data/blocs/data_fetcher/paged_data_collection_fetch_bloc.dart';
import '../../../data/models/tmdb/filter_parameter.dart';
import '../../../data/blocs/data_fetcher/paged_data_filter_manager.dart';
import '../../widgets/custom_awesome_dialog.dart';
import '../../widgets/default_sliver_grid.dart';
import '../../widgets/tmdb/filters/filter_menu_dialog.dart';
import '../../widgets/paged_sliver_grid_view.dart';
import '../../widgets/error_widget.dart';

class LibraryExplorerWidget extends StatefulWidget {
  final LibraryFilterParameter _defaultLibraryFilterParameter;
  final Set<TMDBMultiMedia> _data;
  final bool isGridLayout;
  final Widget Function(BuildContext context, TMDBMultiMedia media) itemBuilder;
  final Widget? customAction;
  final String title;

  LibraryExplorerWidget(
      {super.key,
      LibraryFilterParameter? defaultLibraryFilterParameter,
      this.isGridLayout = true,
      this.customAction,
      this.title = 'library',
      required this.itemBuilder})
      : _defaultLibraryFilterParameter =
            defaultLibraryFilterParameter ?? const LibraryFilterParameter(),
        _data = {};

  @override
  State<LibraryExplorerWidget> createState() => _LibraryExplorerWidgetState();
}

class _LibraryExplorerWidgetState extends State<LibraryExplorerWidget> {
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
        widget.title,
        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ).tr(),
      floating: true,
      actions: [
        if (widget.customAction != null) widget.customAction!,
        const SizedBox(
          width: 5,
        )
      ],
      snap: true,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      centerTitle: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 5),
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
    return MultiProvider(
        providers: [
          BlocProvider(
            create: (context) => LibraryMediaExploreBloc(context),
          ),
          BlocProvider(
              create: (context) =>
                  PagedDataFilterManager(widget._defaultLibraryFilterParameter))
        ],
        builder: (context, child) => MultiBlocListener(
                listeners: [
                  BlocListener<ConnectivityManager, ConnectivityState>(
                      listenWhen: (previous, current) =>
                          !previous.hasNetworkAccess(),
                      listener: (context, state) {
                        if (state.hasNetworkAccess() && widget._data.isEmpty) {
                          context
                              .read<LibraryMediaExploreBloc>()
                              .add(const PagedDataCollectionRefreshEvent());
                        }
                      }),
                  BlocListener<PagedDataFilterManager<LibraryFilterParameter>,
                      LibraryFilterParameter>(
                    listener: (context, state) {
                      widget._data.clear();
                      context.read<LibraryMediaExploreBloc>().add(
                          PagedDataCollectionFetchEvent.updateParameter(state));
                    },
                  )
                ],
                child: PagedSliverScrollViewWrapper(
                  loadingIndicator: LoadingIndicator(
                    controller: LoadingIndicatorController.from(
                        context.read<LibraryMediaExploreBloc>()),
                    errorBuilder: (context, [error]) {
                      if (widget._data.isNotEmpty) {
                        return CustomErrorWidget.from(
                          error: error,
                          showDescription: false,
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
                      widget._data.clear();
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
                          BasicServerFetchState>(listener: (context, state) {
                        if (state.hasData()) {
                          widget._data.addAll(state.result);
                        }
                      }, builder: (context, state) {
                        final childrenDelegate = SliverChildBuilderDelegate(
                            _renderItems,
                            childCount: widget._data.length);
                        if (widget.isGridLayout) {
                          return DefaultSliverGrid(
                            sliverChildBuilderDelegate: childrenDelegate,
                          );
                        } else {
                          return SliverList(delegate: childrenDelegate);
                        }
                      })),
                )));
  }

  Widget _renderItems(context, index) {
    final media = widget._data.elementAt(index);
    return widget.itemBuilder(context, media);
  }
}
