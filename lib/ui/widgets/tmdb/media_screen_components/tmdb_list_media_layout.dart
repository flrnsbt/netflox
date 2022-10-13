import 'package:auto_route/auto_route.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/ui/widgets/faded_edge_widget.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../../data/blocs/data_fetcher/basic_server_fetch_state.dart';
import '../../../../data/blocs/data_fetcher/tmdb/element_cubit.dart';

import '../../../../data/models/tmdb/media.dart';
import '../../../router/router.gr.dart';
import '../tmdb_media_card.dart';
import 'components.dart';

const double kPadding = 25;

class TMDBListPrimaryMediaLayout<
        B extends TMDBElementCubit<List<TMDBPrimaryMedia>>>
    extends StatelessWidget {
  final double? height;
  final String title;
  final bool play;

  factory TMDBListPrimaryMediaLayout.responsive(
      {required String title,
      bool play = false,
      required BuildContext context}) {
    final double? height =
        ResponsiveWrapper.of(context).isSmallerThan(TABLET) ? 200 : null;
    return TMDBListPrimaryMediaLayout(
      title: title,
      height: height,
      play: play,
    );
  }

  const TMDBListPrimaryMediaLayout(
      {super.key, required this.title, this.play = false, this.height});

  const TMDBListPrimaryMediaLayout.carousel(
      {Key? key,
      required this.title,
      this.play = false,
      required double this.height})
      : super(key: key);

  const TMDBListPrimaryMediaLayout.grid({super.key, required this.title})
      : play = false,
        height = null;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, BasicServerFetchState<List<TMDBPrimaryMedia>>>(
      builder: (context, state) {
        if (state.success() && state.hasData()) {
          final data = state.result!;
          return MediaScreenComponent(
              name: title,
              padding:
                  const EdgeInsets.only(left: kPadding, top: 15, bottom: 15),
              child: height != null
                  ? _CarouselLayout(
                      data: data,
                      play: play,
                      height: height!,
                    )
                  : _GridLayout(
                      data: data,
                    ));
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _GridLayout extends StatelessWidget {
  final List<TMDBPrimaryMedia> data;
  const _GridLayout({required this.data});

  @override
  Widget build(BuildContext context) {
    return GridView.custom(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.only(right: kPadding),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const ResponsiveGridDelegate(
            childAspectRatio: 2 / 3,
            minCrossAxisExtent: 100,
            maxCrossAxisExtent: 150,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20),
        childrenDelegate: SliverChildBuilderDelegate(((context, index) {
          final media = data.elementAt(index);
          return TMDBMediaCard(
            media: media,
            showBottomTitle: true,
            onTap: (media) => context.pushRoute(MediaRoute.fromMedia(media)),
          );
        }), childCount: data.length));
  }
}

class _CarouselLayout extends StatefulWidget {
  final List<TMDBPrimaryMedia> data;
  final double height;
  final bool play;
  const _CarouselLayout(
      {required this.data, required this.height, this.play = false});

  @override
  State<_CarouselLayout> createState() => _CarouselLayoutState();
}

class _CarouselLayoutState extends State<_CarouselLayout> {
  CarouselController? _controller;
  bool _highlightControllers = false;

  @override
  void initState() {
    super.initState();
    _controller = CarouselController();
  }

  Widget _buildCarousel(bool enableInfiniteScroll, double ratio) {
    return MouseRegion(
        onEnter: (event) {
          setState(() {
            _highlightControllers = true;
          });
        },
        onExit: (event) {
          setState(() {
            _highlightControllers = false;
          });
        },
        child: CarouselSlider(
          carouselController: _controller,
          options: CarouselOptions(
              enableInfiniteScroll: enableInfiniteScroll,
              autoPlay: widget.play,
              clipBehavior: Clip.none,
              padEnds: false,
              height: widget.height,
              disableCenter: true,
              autoPlayInterval: const Duration(seconds: 6),
              autoPlayAnimationDuration: const Duration(seconds: 2),
              pauseAutoPlayOnTouch: true,
              viewportFraction: ratio),
          items: [
            for (final media in widget.data)
              Center(
                child: Padding(
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
                ),
              ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final ratio = (widget.height - 50) / constraints.maxWidth;
      final itemNumber = 1 ~/ ratio;
      final overflowed = itemNumber < widget.data.length;
      return ClipRect(
        clipper: _CustomCarouselClipper(),
        child: FadedEdgeWidget(
          endStop: 0.05,
          startStop: 0,
          axis: Axis.horizontal,
          child: Stack(
            children: [
              _buildCarousel(overflowed, ratio),
              if (overflowed) _buildController()
            ],
          ),
        ),
      );
    });
  }

  Widget _buildController() {
    final color = _highlightControllers ? Colors.white60 : Colors.white10;
    return Positioned.fill(
      right: kPadding,
      child: Row(
        children: [
          ElevatedButton(
              style: ButtonStyle(
                  elevation: const MaterialStatePropertyAll(2),
                  padding: const MaterialStatePropertyAll(EdgeInsets.all(10)),
                  shape: const MaterialStatePropertyAll(CircleBorder()),
                  backgroundColor: MaterialStatePropertyAll(color)),
              onPressed: () {
                _controller?.previousPage();
              },
              child: Icon(
                Icons.arrow_back,
                color: Theme.of(context).backgroundColor.withOpacity(0.7),
              )),
          const Spacer(),
          ElevatedButton(
              style: ButtonStyle(
                  elevation: const MaterialStatePropertyAll(2),
                  padding: const MaterialStatePropertyAll(EdgeInsets.all(10)),
                  shape: const MaterialStatePropertyAll(CircleBorder()),
                  backgroundColor: MaterialStatePropertyAll(color)),
              onPressed: () {
                _controller?.nextPage();
              },
              child: Icon(
                Icons.arrow_forward,
                color: Theme.of(context).backgroundColor.withOpacity(0.7),
              )),
        ],
      ),
    );
  }
}

class _CustomCarouselClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(-kPadding, 0, size.width + kPadding, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return true;
  }
}
