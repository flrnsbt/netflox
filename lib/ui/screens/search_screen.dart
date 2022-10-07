import 'package:auto_route/auto_route.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/data_fetcher/filter_parameter.dart';
import 'package:netflox/data/blocs/theme/theme_cubit_cubit.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/ui/widgets/faded_edge_widget.dart';
import 'package:netflox/ui/widgets/search_bar.dart';
import '../../data/blocs/data_fetcher/basic_server_fetch_state.dart';
import '../../data/blocs/data_fetcher/data_collection_fetch_bloc.dart';
import '../../data/blocs/data_fetcher/paged_data_fetch_manager.dart';
import '../router/router.gr.dart';
import '../widgets/custom_awesome_dialog.dart';
import '../widgets/default_sliver_grid.dart';
import '../widgets/filters/filter_menu_dialog.dart';
import '../widgets/paged_media_sliver_grid_view.dart';
import '../widgets/tmdb/tmdb_media_card.dart';

class SearchScreen extends StatelessWidget with AutoRouteWrapper, RouteAware {
  SearchScreen({
    super.key,
  })  : _searchBarController = TextEditingController(),
        _data = {},
        _searchFilterParameter = const SearchFilterParameter();
  final TextEditingController _searchBarController;
  final SearchFilterParameter _searchFilterParameter;
  final Set<TMDBPrimaryMedia> _data;

  void showFilterMenuDialog(BuildContext context) {
    CustomAwesomeDialog(
        context: context,
        dialogType: DialogType.noHeader,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        bodyHeaderDistance: 0,
        body: FilterMenuDialog(
          onParameterSubmitted: (newParameter) {
            context
                .read<PagedDataFilterManager<SearchFilterParameter>>()
                .updateParameter(newParameter);

            _searchBarController.clear();
          },
          currentParameters: context
              .read<PagedDataFilterManager<SearchFilterParameter>>()
              .state
              .currentFilter,
        )).show();
  }

  Widget _buildSearchBar(BuildContext context) {
    return SliverAppBar(
        floating: true,
        snap: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        flexibleSpace: FlexibleSpaceBar(
          background: SizedBox(
              height: 40,
              child: NetfloxSearchBar(
                controller: _searchBarController,
                suffixWidget: IconButton(
                    onPressed: () => showFilterMenuDialog(context),
                    icon: const Icon(
                      Icons.filter_list,
                    )),
                onQueryChange: (query) {
                  context
                      .read<PagedDataFilterManager<SearchFilterParameter>>()
                      .search(query);
                },
              )),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return FadedEdgeWidget(
      show: context.read<ThemeDataCubit>().state.mode == ThemeMode.dark,
      ratio: const EdgeInsets.only(top: 0.05),
      child: SafeArea(
          minimum: const EdgeInsets.only(left: 25, right: 25, top: 40),
          child: PagedSliverScrollViewWrapper(
            showFloatingReturnTopButton: true,
            bloc: context.read<TMDBPrimaryMediaSearchBloc>(),
            onEndReached: () {
              context
                  .read<PagedDataFilterManager<SearchFilterParameter>>()
                  .nextPage();
            },
            slivers: [
              _buildSearchBar(context),
              SliverPadding(
                  padding: const EdgeInsets.only(top: 10),
                  sliver: BlocConsumer<TMDBPrimaryMediaSearchBloc,
                      BasicServerFetchState>(listener: (context, state) {
                    if (state.hasData()) {
                      _data.addAll(state.result!);
                    }
                  }, builder: (context, state) {
                    return DefaultSliverGrid(
                      sliverChildBuilderDelegate:
                          SliverChildBuilderDelegate(((context, index) {
                        return TMDBMediaCard(
                            media: _data.elementAt(index),
                            showMediaType: true,
                            showBottomTitle: true,
                            onTap: (media) {
                              FocusManager.instance.primaryFocus?.unfocus();

                              context.pushRoute(MediaRoute.fromMedia(media));
                            });
                      }), childCount: _data.length),
                    );
                  }))
            ],
          )),
    );
  }

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => TMDBPrimaryMediaSearchBloc(context)
                ..add(PagedRequestParameter(_searchFilterParameter))),
          BlocProvider(
              create: (context) =>
                  PagedDataFilterManager<SearchFilterParameter>(
                      _searchFilterParameter))
        ],
        child: BlocListener<PagedDataFilterManager<SearchFilterParameter>,
            PagedRequestParameter<SearchFilterParameter>>(
          child: this,
          listener: (context, state) {
            if (state.isNewRequest()) {
              _data.clear();
            }
            context.read<TMDBPrimaryMediaSearchBloc>().add(state);
          },
        ));
  }
}
