import 'package:auto_route/auto_route.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/blocs/data_fetcher/basic_server_fetch_state.dart';
import '../../../../data/blocs/data_fetcher/tmdb/element_cubit.dart';

import '../../../../data/models/tmdb/media.dart';
import '../../../router/router.gr.dart';
import '../../../widgets/tmdb/tmdb_media_card.dart';
import 'components.dart';

class TMDBListPrimaryMediaLayout<
    B extends TMDBElementCubit<List<TMDBPrimaryMedia>>> extends StatefulWidget {
  final double height;
  final String title;
  final bool play;
  const TMDBListPrimaryMediaLayout(
      {Key? key, required this.title, this.play = false, this.height = 200})
      : super(key: key);

  @override
  State<TMDBListPrimaryMediaLayout<B>> createState() =>
      _TMDBListPrimaryMediaLayoutState<B>();
}

class _TMDBListPrimaryMediaLayoutState<
        B extends TMDBElementCubit<List<TMDBPrimaryMedia>>>
    extends State<TMDBListPrimaryMediaLayout<B>> {
  CarouselController? _controller;

  @override
  void initState() {
    super.initState();
    assert(widget.height > 70);
    _controller = CarouselController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, BasicServerFetchState<List<TMDBPrimaryMedia>>>(
      builder: (context, state) {
        if (state.success() && state.hasData()) {
          final ratio =
              (widget.height - 50) / MediaQuery.of(context).size.width;
          final data = state.result!;
          return MediaScreenComponent(
            title: widget.title,
            child: CarouselSlider(
              carouselController: _controller,
              options: CarouselOptions(
                  enableInfiniteScroll: false,
                  height: widget.height,
                  autoPlay: widget.play,
                  padEnds: false,
                  disableCenter: true,
                  autoPlayInterval: const Duration(seconds: 6),
                  autoPlayAnimationDuration: const Duration(seconds: 2),
                  pauseAutoPlayOnTouch: true,
                  clipBehavior: Clip.none,
                  viewportFraction: ratio),
              items: [
                for (final media in data)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: AspectRatio(
                      aspectRatio: 2 / 3,
                      child: TMDBMediaCard(
                        media: media,
                        showBottomTitle: true,
                        onTap: (media) =>
                            context.pushRoute(MediaRoute.fromMedia(media)),
                      ),
                    ),
                  )
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
