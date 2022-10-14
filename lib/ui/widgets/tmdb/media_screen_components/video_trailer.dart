import 'package:netflox/utils/platform_mobile_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/ui/widgets/netflox_loading_indicator.dart';
import 'package:netflox/ui/widgets/youtube_player.dart';
import 'package:netflox/utils/reponsive_size_helper.dart';
import 'package:nil/nil.dart';
import '../../../../data/blocs/data_fetcher/basic_server_fetch_state.dart';
import '../../../../data/blocs/data_fetcher/tmdb/element_cubit.dart';
import '../../../../data/models/tmdb/media.dart';
import '../../../../data/models/tmdb/video.dart';
import 'components.dart';

class VideoTrailer extends StatelessWidget {
  final TMDBMultiMedia media;

  const VideoTrailer({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    if (platformIsMobile()) {
      return MediaScreenComponent(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        name: "trailer".tr(context),
        child: BlocBuilder<TMDBFetchVideosCubit,
            BasicServerFetchState<List<TMDBVideo>>>(builder: (context, state) {
          Widget? widget;
          if (state.success()) {
            if (state.result?.isNotEmpty ?? false) {
              try {
                final video = state.result!.firstWhere((element) =>
                    element.isTrailer && element.site == VideoSite.youtube);
                widget = CustomYoutubePlayer(
                  videoId: video.key,
                  maxHeight: 100.h(context),
                );
              } catch (e) {
                widget = const Text("nothing-found").tr();
              }
            }
          } else if (state.isLoading()) {
            widget = const NetfloxLoadingIndicator();
          }
          return widget ?? const Text('unknown-error').tr();
        }),
      );
    }
    return const Nil();
  }
}
