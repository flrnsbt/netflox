import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/blocs/data_fetcher/basic_server_fetch_state.dart';
import '../../../../data/blocs/data_fetcher/tmdb/element_cubit.dart';

import '../../../../data/models/tmdb/media.dart';
import '../../../router/router.gr.dart';
import '../../../widgets/tmdb/tmdb_media_card.dart';
import 'components.dart';

class TMDBListPrimaryMediaLayout<
        B extends TMDBElementCubit<List<TMDBPrimaryMedia>>>
    extends StatelessWidget {
  final double height;
  final String title;
  const TMDBListPrimaryMediaLayout(
      {Key? key, required this.title, this.height = 200})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, BasicServerFetchState<List<TMDBPrimaryMedia>>>(
      builder: (context, state) {
        if (state.finished() && state.hasData()) {
          final data = state.result!;
          return MediaScreenComponent(
            title: title,
            child: SizedBox(
              height: height,
              child: ListView.separated(
                  shrinkWrap: true,
                  separatorBuilder: (context, index) => const SizedBox(
                        width: 10,
                      ),
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => AspectRatio(
                        aspectRatio: 2 / 3,
                        child: TMDBMediaCard(
                          media: data.elementAt(index),
                          showBottomTitle: true,
                          onTap: (media) =>
                              context.pushRoute(MediaRoute.fromMedia(media)),
                        ),
                      ),
                  itemCount: data.length),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
