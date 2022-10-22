import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/models/tmdb/filter_parameter.dart';
import 'package:netflox/data/models/tmdb/library_media_information.dart';
import 'package:netflox/data/models/tmdb/type.dart';
import 'package:netflox/ui/widgets/tmdb/library_explorer_widget.dart';
import '../../data/blocs/account/auth/auth_cubit.dart';
import '../../data/models/tmdb/media.dart';
import '../router/router.gr.dart';
import '../widgets/error_widget.dart';
import '../widgets/tmdb/list_tmdb_media_card.dart';

class AdminScreen extends StatelessWidget {
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
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.user?.isAdmin() ?? false) {
          return Scaffold(
            body: LibraryExplorerWidget(
              title: 'admin-panel',
              customAction: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.upload,
                      color: Theme.of(context).primaryColor)),
              isGridLayout: false,
              defaultLibraryFilterParameter: const LibraryFilterParameter(
                  status: MediaStatus.pending, types: [TMDBType.movie]),
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
                                  context.pushRoute(UploadRoute(media));
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
                  onTap: (media) =>
                      context.pushRoute(MediaRoute.fromMedia(media)),
                );
              },
            ),
          );
        }

        return CustomErrorWidget.from(
          error: 'permission-denied',
        );
      },
    );
  }
}
