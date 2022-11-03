import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/utils/reponsive_size_helper.dart';
import '../../../../data/blocs/theme/theme_cubit_cubit.dart';
import '../../../../data/models/tmdb/element.dart';
import '../../buttons/home_button.dart';
import 'header.dart';

class TMDBScreenBuilder extends StatefulWidget {
  final TMDBElementWithImage element;
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
  Widget? _title;
  bool _show = false;

  @override
  void initState() {
    super.initState();
    if (widget.element is TMDBMedia &&
        (widget.element as TMDBMedia).name != null) {
      _title = Text(
        (widget.element as TMDBMedia).name!,
        style: const TextStyle(fontSize: 12),
      );
    }
    _controller = widget.controller ?? ScrollController();
    _controller!.addListener(_scrollListener);
  }

  void _scrollListener() {
    final show = _controller!.offset > MediaQuery.of(context).size.height;
    if (show != _show) {
      setState(() {
        _show = show;
      });
    }
  }

  @override
  void dispose() {
    _controller!.removeListener(_scrollListener);
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildAppbar(BuildContext context) {
    final double height = 20.w(context).clamp(240, 600);
    final screenHeaderContent = TMDBScreenHeaderContent(
      element: widget.element,
      child: widget.header,
    );
    return Theme(
      data: screenHeaderContent.image != null
          ? ThemeDataCubit.darkThemeData
          : context.read<ThemeDataCubit>().state.data,
      child: SliverAppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        floating: false,
        pinned: true,
        actions: [
          if (_show)
            IconButton(
                icon: const Icon(Icons.arrow_upward),
                onPressed: () {
                  _controller?.animateTo(0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease);
                }),
          const SizedBox(
            width: 25,
          )
        ],
        centerTitle: true,
        title: _show ? _title : null,
        titleTextStyle:
            const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
          background: screenHeaderContent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
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
