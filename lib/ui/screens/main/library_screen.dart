import 'package:auto_route/auto_route.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/blocs/connectivity/connectivity_manager.dart';
import 'package:netflox/data/blocs/data_fetcher/basic_server_fetch_state.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/data/models/tmdb/movie.dart';
import 'package:netflox/ui/screens/tmdb/media_screen.dart';
import 'package:nil/nil.dart';
import '../../../data/blocs/account/auth/user_account_data_cubit.dart';
import '../../../data/blocs/data_fetcher/paged_data_collection_fetch_bloc.dart';
import '../../../data/models/tmdb/filter_parameter.dart';
import '../../../data/blocs/data_fetcher/paged_data_filter_manager.dart';
import '../../router/router.gr.dart';
import '../../widgets/custom_awesome_dialog.dart';
import '../../widgets/default_sliver_grid.dart';
import '../../widgets/tmdb/filters/filter_menu_dialog.dart';
import '../../widgets/paged_sliver_grid_view.dart';
import '../../widgets/tmdb/tmdb_media_card.dart';
import '../../widgets/error_widget.dart';

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
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
    return PagedSliverScrollViewWrapper(
      loadingIndicator: LoadingIndicator(
        controller: LoadingIndicatorController.from(
            context.read<LibraryMediaExploreBloc>()),
        errorBuilder: (context, [error]) {
          if (_data.isNotEmpty) {
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
          _data.clear();
          context
              .read<LibraryMediaExploreBloc>()
              .add(PagedDataCollectionFetchEvent.refresh);
        }
      },
      header: _buildAppBar(context),
      child: SliverPadding(
          padding: const EdgeInsets.only(
            left: 25,
            right: 25,
          ),
          sliver: BlocConsumer<LibraryMediaExploreBloc, BasicServerFetchState>(
              listener: (context, state) {
            if (state.hasData()) {
              _data.addAll(state.result);
            }
          }, builder: (context, state) {
            return DefaultSliverGrid(
              sliverChildBuilderDelegate:
                  SliverChildBuilderDelegate(((context, index) {
                final media = _data.elementAt(index);
                LibraryMediaUserPlaybackStateCubit? bloc;
                if (media is TMDBPlayableMedia) {
                  bloc = LibraryMediaUserPlaybackStateCubit(
                      context, media as TMDBPlayableMedia);
                }
                return TMDBMediaCard(
                  media: media,
                  contentBarrier: false,
                  contentBuilder: (context, media) {
                    if (bloc != null) {
                      return BlocBuilder<LibraryMediaUserPlaybackStateCubit,
                          LibraryMediaUserPlaybackState>(
                        bloc: bloc,
                        builder: (context, state) {
                          if (state.watched) {
                            return Align(
                              alignment: Alignment.bottomLeft,
                              child: Container(
                                margin: const EdgeInsets.only(
                                  bottom: 8,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.play_arrow,
                                        size: 12,
                                      ),
                                      const SizedBox(
                                        width: 4,
                                      ),
                                      const Text(
                                        'watched',
                                        style: TextStyle(fontSize: 12),
                                      ).tr()
                                    ]),
                              ),
                            );
                          }
                          return const Nil();
                        },
                      );
                    }
                    return const Nil();
                  },
                  showMediaType: true,
                  showBottomTitle: true,
                  onTap: (media) {
                    Navigator.push(context, PageRouteBuilder(pageBuilder:
                        (BuildContext context, Animation<double> animation,
                            Animation<double> secondaryAnimation) {
                      final child = MediaScreen.fromMedia(media);
                      if (bloc != null) {
                        return BlocProvider.value(
                          value: bloc,
                          child: child,
                        );
                      }
                      return child;
                    }));
                  },
                );
              }), childCount: _data.length),
            );
          })),
    );
  }

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LibraryMediaExploreBloc(context),
          ),
          BlocProvider(
              create: (context) =>
                  PagedDataFilterManager(_defaultLibraryFilterParameter))
        ],
        child: MultiBlocListener(listeners: [
          BlocListener<ConnectivityManager, ConnectivityState>(
              listenWhen: (previous, current) => !previous.hasNetworkAccess(),
              listener: (context, state) {
                if (state.hasNetworkAccess() && _data.isEmpty) {
                  context
                      .read<LibraryMediaExploreBloc>()
                      .add(const PagedDataCollectionRefreshEvent());
                }
              }),
          BlocListener<PagedDataFilterManager<LibraryFilterParameter>,
              LibraryFilterParameter>(
            child: this,
            listener: (context, state) {
              _data.clear();
              context
                  .read<LibraryMediaExploreBloc>()
                  .add(PagedDataCollectionFetchEvent.updateParameter(state));
            },
          )
        ], child: this));
  }
}
