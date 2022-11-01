import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/models/exception.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/ui/router/idle_timed_auto_push_route.dart';
import 'package:netflox/ui/screens/loading_screen.dart';
import 'package:netflox/ui/widgets/custom_awesome_dialog.dart';
import 'package:netflox/ui/widgets/default_shimmer.dart';
import 'package:netflox/ui/widgets/tmdb/tmdb_media_card.dart';
import 'package:netflox/utils/reponsive_size_helper.dart';
import '../../../data/blocs/account/auth/auth_cubit.dart';
import '../../../data/blocs/account/data/library_media_user_data_explore_bloc.dart';
import '../../../data/blocs/data_fetcher/basic_server_fetch_state.dart';
import '../../../data/blocs/data_fetcher/paged_data_collection_fetch_bloc.dart';
import '../../../data/models/tmdb/filter_parameter.dart';
import '../../router/router.gr.dart';
import '../../widgets/default_sliver_grid.dart';
import '../../widgets/paged_sliver_grid_view.dart';
import '../../widgets/profile_image.dart';
import '../../widgets/tmdb/list_tmdb_media_card.dart';
import '../tmdb/media_screen.dart';

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(listener: (context, state) {
      if (state.hasError()) {
        final exception = NetfloxException.from(state.message!);
        ErrorDialog.fromException(exception, context);
      }
    }, builder: (context, state) {
      if (state.isLoading()) {
        return const LoadingScreen();
      }
      if (state.isUnauthenticated()) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "not-logged-in",
              textAlign: TextAlign.center,
            ).tr(),
            const SizedBox(
              height: 15,
            ),
            TextButton(
                onPressed: () => context.router.push(AuthRoute()),
                child: const Text("sign-in").tr())
          ],
        );
      }
      final user = state.user!;
      final double horizontalPadding = 4.w(context).clamp(15, 100);
      return SafeArea(
          minimum: EdgeInsets.only(
              left: horizontalPadding, right: horizontalPadding, top: 40),
          child: ListView(shrinkWrap: true, children: [
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 75,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Material(
                  color: Theme.of(context).cardColor,
                  child: InkWell(
                    onTap: () => context.pushRoute(const SettingsRoute()),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 25),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ProfileImage(
                              imgUrl: user.imgURL,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  user.displayName,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                                if (user.email != null)
                                  Text(
                                    user.email!,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontSize: 12),
                                  ),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                                onPressed: () =>
                                    context.pushRoute(const SettingsRoute()),
                                icon: Icon(
                                  Icons.settings,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ))
                          ],
                        )),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            LibraryMediaUserDataLayout(
              title: 'keep-watching'.tr(context),
              iconLeading: Icons.play_circle,
              parameter: const LibraryUserDataFilterParameter(watched: true),
            ),
            LibraryMediaUserDataLayout(
              title: 'favorites'.tr(context),
              iconLeading: Icons.favorite,
              parameter: const LibraryUserDataFilterParameter(liked: true),
            ),
            const SizedBox(
              height: 30,
            ),
          ]));
    });
  }
}

class LibraryMediaUserDataLayout extends StatefulWidget {
  final String title;
  final IconData? iconLeading;
  final LibraryUserDataFilterParameter parameter;
  const LibraryMediaUserDataLayout(
      {super.key,
      required this.title,
      this.iconLeading,
      required this.parameter});

  @override
  State<LibraryMediaUserDataLayout> createState() =>
      _LibraryMediaUserDataLayoutState();
}

class _LibraryMediaUserDataLayoutState
    extends State<LibraryMediaUserDataLayout> {
  final data = <TMDBLibraryMedia>{};
  LibraryMediaUserDataExploreBloc? bloc;
  LoadingIndicator? _loadingIndicator;
  LoadingIndicatorController? loadingController;

  @override
  void initState() {
    super.initState();
    bloc = LibraryMediaUserDataExploreBloc(context);
    bloc!.add(PagedDataCollectionFetchEvent.setParameter(widget.parameter));
    final loadingController = LoadingIndicatorController.from(bloc!);

    _loadingIndicator = LoadingIndicator(
      controller: loadingController,
    );
  }

  @override
  void dispose() {
    bloc?.close();
    loadingController?.close();
    super.dispose();
  }

  Widget _seeMoreBuilder(BuildContext context) {
    return Scaffold(
      body: PagedSliverScrollViewWrapper(
        showFloatingReturnBeginButton: true,
        header: SliverAppBar(
          title: Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
        loadingIndicator: _loadingIndicator,
        onEvent: _onPagedScrollViewEvent,
        child: _buildMediaContent((context, state) => SliverList(
            delegate: SliverChildBuilderDelegate(
                (context, index) => TMDBListMediaCard(
                    media: data.elementAt(index),
                    onTap: (media) {
                      TMDBMediaRouteHelper.pushRoute(context, media);
                    }),
                childCount: data.length))),
      ),
    );
  }

  void _onPagedScrollViewEvent(eventType) {
    if (eventType == PagedSliverScrollViewEventType.load) {
      bloc?.add(PagedDataCollectionFetchEvent.nextPage);
    }
  }

  Widget _buildMediaContent(
          Widget Function(BuildContext, BasicServerFetchState<dynamic>)
              builder) =>
      BlocConsumer<LibraryMediaUserDataExploreBloc, BasicServerFetchState>(
        bloc: bloc,
        listener: (context, state) {
          if (!state.isLoading()) {
            _loaded = true;
            if (state.hasData()) {
              data.addAll(state.result!);
            }
            setState(() {});
          }
        },
        builder: (context, state) {
          return builder(context, state);
        },
      );

  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    if (_loaded) {
      return _buildContent();
    }
    return DefaultShimmer(
      child: _buildContent(),
    );
  }

  Widget _buildContent() => Container(
        height: !_loaded || data.isNotEmpty ? 250 : 0,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                if (widget.iconLeading != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(
                      widget.iconLeading!,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ),
                Text(
                  widget.title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (data.isNotEmpty)
                  ElevatedButton(
                      onPressed: () {
                        context.pushRoute(WrappedBuilderRoute(
                          builder: _seeMoreBuilder,
                        ));
                      },
                      style: ButtonStyle(
                        elevation: const MaterialStatePropertyAll(0),
                        backgroundColor: MaterialStatePropertyAll(
                            Theme.of(context).focusColor),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: const MaterialStatePropertyAll(Size.zero),
                        padding: const MaterialStatePropertyAll(
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                      ),
                      child: Text(
                        'see-all',
                        style: TextStyle(
                            fontSize: 12, color: Theme.of(context).hintColor),
                      ).tr())
              ]),
            ),
            const SizedBox(
              height: 15,
            ),
            Flexible(
              child: PagedSliverScrollViewWrapper(
                loadingIndicator: _loadingIndicator,
                scrollDirection: Axis.horizontal,
                onEvent: _onPagedScrollViewEvent,
                child: _buildMediaContent((context, state) => DefaultSliverGrid(
                      padding: const EdgeInsets.only(left: 15),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisSpacing: data.isNotEmpty ? 10 : 0,
                          crossAxisCount: 1,
                          childAspectRatio: 3 / 2),
                      sliverChildBuilderDelegate:
                          SliverChildBuilderDelegate((context, index) {
                        return TMDBMediaCard(
                            media: data.elementAt(index),
                            onTap: (media) {
                              TMDBMediaRouteHelper.pushRoute(context, media);
                            });
                      }, childCount: data.length),
                    )),
              ),
            ),
          ],
        ),
      );
}
