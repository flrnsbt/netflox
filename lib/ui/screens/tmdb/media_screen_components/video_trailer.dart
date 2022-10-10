import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/ui/widgets/netflox_loading_indicator.dart';
import 'package:netflox/ui/widgets/youtube_player.dart';
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
    return MediaScreenComponent(
      title: "videos".tr(context),
      child: BlocBuilder<TMDBFetchVideosCubit,
          BasicServerFetchState<List<TMDBVideo>>>(builder: (context, state) {
        Widget? widget;
        if (state.success()) {
          if (state.result?.isNotEmpty ?? false) {
            try {
              final video = state.result!.firstWhere((element) =>
                  element.isTrailer && element.site == VideoSite.youtube);
              widget = ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 350),
                  child: CustomYoutubePlayer(videoId: video.key));
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
}
