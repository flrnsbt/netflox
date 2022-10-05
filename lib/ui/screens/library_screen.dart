import 'package:auto_route/auto_route.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/blocs/data_fetcher/basic_server_fetch_state.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import '../../data/blocs/data_fetcher/data_collection_fetch_bloc.dart';
import '../../data/blocs/data_fetcher/filter_parameter.dart';
import '../../data/blocs/data_fetcher/paged_data_fetch_manager.dart';
import '../router/router.gr.dart';
import '../widgets/custom_awesome_dialog.dart';
import '../widgets/default_sliver_grid.dart';
import '../widgets/filters/filter_menu_dialog.dart';
import '../widgets/paged_media_sliver_grid_view.dart';
import '../widgets/tmdb/tmdb_media_card.dart';
import 'error_screen.dart';
import 'loading_screen.dart';

class LibraryScreen extends StatelessWidget with AutoRouteWrapper {
  final LibraryFilterParameter _defaultLibraryFilterParameter;
  final Set<TMDBPrimaryMedia> _data;

  LibraryScreen(
      {super.key, LibraryFilterParameter? defaultLibraryFilterParameter})
      : _defaultLibraryFilterParameter =
            defaultLibraryFilterParameter ?? const LibraryFilterParameter(),
        _data = {};

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

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      titleSpacing: 0,
      leading:
          IconButton(onPressed: () {}, icon: const Icon(Icons.video_library)),
      title: const Text(
        "library",
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ).tr(),
      floating: true,
      snap: true,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      centerTitle: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: BlocBuilder<PagedDataFilterManager<LibraryFilterParameter>,
                    PagedRequestParameter<LibraryFilterParameter>>(
                builder: (context, state) {
              return Row(
                children: [
                  Text(
                    "${state.currentFilter.status}-media",
                    style: Theme.of(context).textTheme.subtitle1,
                  ).tr(),
                  const Spacer(),
                  IconButton(
                      onPressed: () =>
                          showFilterMenuDialog(context, state.currentFilter),
                      icon: const Icon(Icons.filter_list))
                ],
              );
            }),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PagedSliverScrollViewWrapper(
      bloc: context.read<LibraryMediaExploreBloc>(),
      onEndReached: () {
        context
            .read<PagedDataFilterManager<LibraryFilterParameter>>()
            .nextPage();
      },
      slivers: [
        _buildAppBar(context),
        SliverPadding(
            padding: const EdgeInsets.only(
              top: 15,
              left: 25,
              right: 25,
            ),
            sliver:
                BlocConsumer<LibraryMediaExploreBloc, BasicServerFetchState>(
                    listener: (context, state) {
              if (state.hasData()) {
                _data.addAll(state.result);
              }
            }, builder: (context, state) {
              return DefaultSliverGrid(
                sliverChildBuilderDelegate:
                    SliverChildBuilderDelegate(((context, index) {
                  return TMDBMediaCard(
                    media: _data.elementAt(index),
                    showMediaType: true,
                    showBottomTitle: true,
                    onTap: (media) =>
                        context.pushRoute(MediaRoute.fromMedia(media)),
                  );
                }), childCount: _data.length),
              );
            }))
      ],
    );
  }

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LibraryMediaExploreBloc(context)
              ..add(PagedRequestParameter(_defaultLibraryFilterParameter)),
          ),
          BlocProvider(
              create: (context) =>
                  PagedDataFilterManager(_defaultLibraryFilterParameter))
        ],
        child: BlocListener<PagedDataFilterManager<LibraryFilterParameter>,
            PagedRequestParameter<LibraryFilterParameter>>(
          child: this,
          listener: (context, state) {
            if (state.isNewRequest()) {
              _data.clear();
            }
            context.read<LibraryMediaExploreBloc>().add(state);
          },
        ));
  }
}
