import 'package:flutter/material.dart';
import 'package:netflox/ui/widgets/faded_edge_widget.dart';
import 'package:netflox/utils/reponsive_size_helper.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../../data/blocs/theme/theme_cubit_cubit.dart';
import '../../../../data/models/tmdb/element.dart';
import '../../../../data/models/tmdb/media.dart';
import '../../../widgets/background_image_widget.dart';
import '../../../widgets/buttons/home_button.dart';
import '../../../widgets/tmdb/tmdb_image.dart';
import 'header.dart';

class TMDBScreenBuilder extends StatefulWidget {
  final TMDBImageProvider element;
  final List<Widget> content;
  final Widget header;
  final ScrollController? controller;
  const TMDBScreenBuilder(
      {super.key,
      required this.element,
      required this.content,
      required this.header,
      this.controller});

  @override
  State<TMDBScreenBuilder> createState() => _TMDBScreenBuilderState();
}

class _TMDBScreenBuilderState extends State<TMDBScreenBuilder> {
  ScrollController? _controller;
  Widget? _returnTopButton;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScrollController();
    _returnTopButton = ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<ScrollController>(
        builder: (context, value, child) {
          if (value.offset > MediaQuery.of(context).size.height) {
            return child!;
          }
          return const SizedBox.shrink();
        },
        child: IconButton(
            icon: const Icon(Icons.arrow_upward),
            onPressed: () {
              _controller?.animateTo(0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease);
            }),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildAppbar(BuildContext context) => Theme(
        data: ThemeDataCubit.darkThemeData,
        child: SliverAppBar(
          floating: false,
          pinned: true,
          actions: [
            _returnTopButton!,
            SizedBox(
              width: 4.w(context),
            )
          ],
          leading: Row(children: [
            SizedBox(
              width: 4.w(context),
            ),
            const Flexible(child: BackButton()),
            const Flexible(child: HomeButton())
          ]),
          leadingWidth: 100,
          expandedHeight: 250,
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [
              StretchMode.blurBackground,
              StretchMode.zoomBackground
            ],
            background:
                TMDBScreenHeader(element: widget.element, child: widget.header),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Material(
        child: NetfloxBackgroundImage(
      opacityStrength: 1,
      overlay: ResponsiveWrapper.of(context).isLargerThan(MOBILE),
      backgroundImage: (context) {
        if (widget.element.type.isMultimedia() &&
            ResponsiveWrapper.of(context).isLargerThan(MOBILE)) {
          var img = (widget.element as TMDBMultiMedia).backdropImg;
          img ??= widget.element.img;
          return TMDBImageWidget(
            img: img,
            showError: false,
            showProgressIndicator: false,
          );
        }
      },
      child: CustomScrollView(
          // clipBehavior: Clip.none,
          controller: _controller,
          slivers: [
            _buildAppbar(context),
            SliverToBoxAdapter(
              child: FadedEdgeWidget(
                  color: Colors.black,
                  axis: Axis.horizontal,
                  ratio: const EdgeInsets.only(left: 0.05, right: 0.1),
                  child: Padding(
                      padding: EdgeInsets.only(
                          left: 6.w(context),
                          right: 6.w(context),
                          top: 15,
                          bottom: 35),
                      child: ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: widget.content,
                      ))),
            )
          ]),
    ));
  }
}
