import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/models/tmdb/type.dart';
import 'package:netflox/ui/widgets/tmdb/library_explorer_widget.dart';
import '../../../data/blocs/account/data/library_media_user_data_cubit.dart';
import '../../../data/blocs/connectivity/connectivity_manager.dart';
import '../../../data/blocs/data_fetcher/library/library_multi_media_explore_bloc.dart';
import '../../../data/blocs/data_fetcher/paged_data_collection_fetch_bloc.dart';
import '../../../data/blocs/data_fetcher/paged_data_filter_manager.dart';
import '../../../data/models/tmdb/filter_parameter.dart';
import '../../../data/models/tmdb/media.dart';
import '../../widgets/tmdb/tmdb_media_card.dart';
import '../tmdb/media_screen.dart';

class LibraryScreen extends StatelessWidget with AutoRouteWrapper {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LibraryExplorerWidget(itemBuilder: (context, media) {
      LibraryMediaUserDataCubit? bloc;
      if (media is TMDBPlayableMedia) {
        bloc = LibraryMediaUserDataCubit(context, media);
      }
      return TMDBMediaCard(
        media: media,
        contentBarrier: false,
        contentBuilder: (context, media) {
          if (bloc != null) {
            return BlocBuilder<LibraryMediaUserDataCubit,
                LibraryMediaUserDataState>(
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
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(5)),
                      child: const Icon(
                        Icons.play_arrow,
                        size: 18,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            );
          }
          return const SizedBox.shrink();
        },
        showMediaType: true,
        showBottomTitle: true,
        onTap: (media) {
          TMDBMediaRouteHelper.pushRoute(context, media);
        },
      );
    });
  }

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LibraryMediaExploreBloc(context),
        ),
        BlocProvider(
            create: (context) => PagedDataFilterManager<LibraryFilterParameter>(
                    const LibraryFilterParameter(
                  selectedtypes: TMDBMultiMediaType.all,
                )))
      ],
      child: BlocListener<ConnectivityManager, ConnectivityState>(
        listener: (context, state) {
          if (state.hasNetworkAccess()) {
            context
                .read<LibraryMediaExploreBloc>()
                .add(PagedDataCollectionFetchEvent.refresh);
          }
        },
        child: this,
      ),
    );
  }
}
