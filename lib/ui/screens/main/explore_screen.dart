import 'package:auto_route/auto_route.dart' show AutoRouteWrapper;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:language_picker/languages.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/blocs/data_fetcher/paged_data_collection_fetch_bloc.dart';
import 'package:netflox/data/models/language.dart';
import 'package:netflox/data/models/tmdb/filter_parameter.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:provider/provider.dart';
import '../../../data/blocs/connectivity/connectivity_manager.dart';
import '../../../data/blocs/data_fetcher/basic_server_fetch_state.dart';
import '../../../data/blocs/data_fetcher/paged_data_filter_manager.dart';
import '../../../data/blocs/data_fetcher/tmdb/discover_bloc.dart';
import '../../widgets/custom_awesome_dialog.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/tmdb/filters/filter_menu_dialog.dart';
import '../../widgets/paged_sliver_grid_view.dart';
import '../../widgets/tmdb/list_tmdb_media_card.dart';
import '../tmdb/media_screen.dart';

class ExploreScreen extends StatelessWidget with AutoRouteWrapper {
  final DiscoverFilterParameter _discoverFilterParameter;
  final Set<TMDBPrimaryMedia> _data;

  ExploreScreen({super.key, DiscoverFilterParameter? parameter})
      : _discoverFilterParameter = parameter ?? const DiscoverFilterParameter(),
        _data = {},
        _controller = ScrollController();
  final ScrollController _controller;

  Future<void> showFilterMenuDialog(BuildContext context) {
    return CustomAwesomeDialog(
            width: 450,
            dialogType: DialogType.noHeader,
            bodyHeaderDistance: 0,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            body: FilterMenuDialog(
              currentParameters: context
                  .read<PagedDataFilterManager<DiscoverFilterParameter>>()
                  .state,
              onParameterSubmitted: (newParameter) {
                context
                    .read<PagedDataFilterManager<DiscoverFilterParameter>>()
                    .updateParameter(newParameter);
              },
            ),
            context: context)
        .show();
  }

  Widget _bottomAppBar(BuildContext context) {
    return Container(
        height: 35,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        color: Theme.of(context).highlightColor,
        child: BlocBuilder<PagedDataFilterManager<DiscoverFilterParameter>,
            DiscoverFilterParameter>(
          builder: (context, state) {
            final singleValueFilters = state.toMap().entries.where((e) {
              return e.value != null && e.value is! List;
            }).toList();
            return Center(
              child: ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  final filter = singleValueFilters[index];
                  dynamic filterValue = filter.value;
                  if (filterValue is! Language) {
                    filterValue = filterValue.toString().tr(context);
                  } else {
                    filterValue = filterValue.tr(context);
                  }
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${filter.key.tr(context)}:",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        filterValue,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      )
                    ],
                  );
                },
                itemCount: singleValueFilters.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const VerticalDivider(
                  thickness: 2,
                  indent: 5,
                  endIndent: 5,
                ),
              ),
            );
          },
        ));
  }

  Widget _buildReturnButton() {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<ScrollController>(builder: (context, value, child) {
        if (value.offset > MediaQuery.of(context).size.height) {
          return IconButton(
              icon: const Icon(Icons.arrow_upward),
              onPressed: () {
                _controller.animateTo(0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease);
              });
        }
        return const SizedBox.shrink();
      }),
    );
  }

  Widget _buildAppBar(BuildContext context) => SliverAppBar(
        floating: true,
        elevation: 10,
        titleSpacing: 0,
        snap: true,
        centerTitle: false,
        leading: const Icon(Icons.explore),
        title: const Text(
          "explore",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ).tr(),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: _bottomAppBar(context),
        ),
        actions: [
          _buildReturnButton(),
          IconButton(
              onPressed: () => showFilterMenuDialog(context),
              icon: const Icon(Icons.filter_list)),
          const SizedBox(
            width: 10,
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    return PagedSliverScrollViewWrapper(
      loadingIndicator: LoadingIndicator(
        controller: LoadingIndicatorController.from(
            context.read<TMDBMultimediaDiscoverBloc>()),
        errorBuilder: (context, [error]) {
          if (_data.isNotEmpty) {
            return CustomErrorWidget.from(
              error: error,
              showDescription: false,
            );
          }
        },
      ),
      controller: _controller,
      onEvent: (eventType) {
        if (eventType == PagedSliverScrollViewEventType.load) {
          context
              .read<TMDBMultimediaDiscoverBloc>()
              .add(PagedDataCollectionFetchEvent.nextPage);
        } else {
          _data.clear();

          context
              .read<TMDBMultimediaDiscoverBloc>()
              .add(PagedDataCollectionFetchEvent.refresh);
        }
      },
      header: _buildAppBar(context),
      child: BlocConsumer<TMDBMultimediaDiscoverBloc, BasicServerFetchState>(
          listener: (context, state) {
        if (state.hasData()) {
          _data.addAll(state.result!);
        }
      }, builder: (context, state) {
        return SliverList(
            delegate: SliverChildBuilderDelegate(
                ((context, index) => TMDBListMediaCard(
                    media: _data.elementAt(index),
                    onTap: (media) {
                      TMDBMediaRouteHelper.pushRoute(context, media);
                    })),
                childCount: _data.length));
      }),
    );
  }

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => TMDBMultimediaDiscoverBloc(context: context),
          ),
          BlocProvider(
              create: (context) =>
                  PagedDataFilterManager(_discoverFilterParameter))
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<ConnectivityManager, ConnectivityState>(
                listener: (context, state) {
              if (state.hasNetworkAccess() && _data.isEmpty) {
                context
                    .read<TMDBMultimediaDiscoverBloc>()
                    .add(PagedDataCollectionFetchEvent.refresh);
              }
            }),
            BlocListener<PagedDataFilterManager<DiscoverFilterParameter>,
                DiscoverFilterParameter>(
              listener: (context, state) {
                _data.clear();
                context
                    .read<TMDBMultimediaDiscoverBloc>()
                    .add(PagedDataCollectionUpdateParameter(state));
              },
            )
          ],
          child: this,
        ));
  }
}
