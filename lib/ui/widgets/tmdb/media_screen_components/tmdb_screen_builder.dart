import 'package:flutter/material.dart';
import 'package:netflox/utils/reponsive_size_helper.dart';
import 'package:provider/provider.dart';
import '../../../../data/blocs/theme/theme_cubit_cubit.dart';
import '../../../../data/models/tmdb/element.dart';
import '../../buttons/home_button.dart';
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

  Widget _buildAppbar(BuildContext context) {
    final double height = 20.w(context).clamp(200, 600);
    return Theme(
      data: ThemeDataCubit.darkThemeData,
      child: SliverAppBar(
        floating: false,
        pinned: true,
        actions: [
          _returnTopButton!,
          const SizedBox(
            width: 25,
          )
        ],
        leading: Row(children: const [
          SizedBox(
            width: 25,
          ),
          Flexible(child: BackButton()),
          Flexible(child: HomeButton())
        ]),
        leadingWidth: 112,
        expandedHeight: height,
        flexibleSpace: FlexibleSpaceBar(
          stretchModes: const [
            StretchMode.blurBackground,
            StretchMode.zoomBackground
          ],
          background: TMDBScreenHeader(
            element: widget.element,
            child: widget.header,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CustomScrollView(controller: _controller, slivers: [
        _buildAppbar(context),
        SliverToBoxAdapter(
            child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(
              top: 25, left: 3.w(context), right: 3.w(context), bottom: 55),
          physics: const NeverScrollableScrollPhysics(),
          children: widget.content,
        ))
      ]),
    );
  }
}
