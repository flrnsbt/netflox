import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/ui/widgets/tmdb/library_explorer_widget.dart';
import 'package:nil/nil.dart';

import '../../../data/blocs/account/auth/user_account_data_cubit.dart';
import '../../../data/models/tmdb/media.dart';
import '../../widgets/tmdb/tmdb_media_card.dart';
import '../tmdb/media_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LibraryExplorerWidget(itemBuilder: (context, media) {
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
    });
  }
}
