import 'package:auto_route/auto_route.dart' show AutoRouteWrapper;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/models/tmdb/filter_parameter.dart';
import 'package:netflox/data/models/tmdb/library_media_information.dart';
import 'package:netflox/data/models/tmdb/type.dart';
import 'package:netflox/ui/router/idle_timed_auto_push_route.dart';
import 'package:netflox/ui/screens/tmdb/media_screen.dart';
import 'package:netflox/ui/widgets/tmdb/library_explorer_widget.dart';
import '../../data/blocs/data_fetcher/library/library_multi_media_explore_bloc.dart';
import '../../data/blocs/data_fetcher/paged_data_filter_manager.dart';
import '../../data/models/tmdb/media.dart';
import '../router/router.gr.dart';
import '../widgets/tmdb/list_tmdb_media_card.dart';

class AdminScreen extends StatelessWidget with AutoRouteWrapper {
  const AdminScreen({Key? key}) : super(key: key);

  List<String> _itemControlButtonBuilder(
      BuildContext context, TMDBLibraryMedia media) {
    return [
      if (media.libraryMediaInfo.mediaStatus == MediaStatus.available) ...[
        'edit',
        'delete',
      ],
      if (media.libraryMediaInfo.mediaStatus == MediaStatus.pending) ...[
        'upload',
        'reject',
      ],
      if (media.libraryMediaInfo.mediaStatus == MediaStatus.rejected) ...['add']
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LibraryExplorerWidget(
        title: 'admin-panel',
        isGridLayout: false,
        itemBuilder: (context, media) {
          return TMDBListMediaCard(
              media: media,
              action: PopupMenuButton(
                itemBuilder: (context) {
                  final popupEntries =
                      _itemControlButtonBuilder(context, media);
                  return <PopupMenuEntry>[
                    for (final e in popupEntries)
                      PopupMenuItem(
                          onTap: () {
                            if (e == "delete") {
                            } else if (e == "reject") {
                            } else {
                              context.pushRoute(UploadRoute(media: media));
                            }
                          },
                          child: Text(
                            e,
                            style: const TextStyle(fontSize: 12),
                          ).tr())
                  ];
                },
                child: Icon(
                  Icons.menu,
                  color: Theme.of(context).hintColor,
                ),
              ),
              onTap: (media) {
                TMDBMediaRouteHelper.pushRoute(context, media);
              });
        },
      ),
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
            create: (context) => PagedDataFilterManager<LibraryFilterParameter>(
                const LibraryFilterParameter(
                    status: MediaStatus.pending,
                    selectedtypes: TMDBLibraryMediaType.all)))
      ],
      child: this,
    );
  }
}
