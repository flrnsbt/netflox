import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/blocs/data_fetcher/basic_server_fetch_state.dart';
import 'package:netflox/data/blocs/data_fetcher/data_collection_fetch_bloc.dart';
import 'package:netflox/ui/widgets/scroll_end_detector.dart';
import '../../data/constants/basic_fetch_status.dart';

import 'netflox_loading_indicator.dart';

class PagedSliverScrollViewWrapper extends StatefulWidget {
  final Axis scrollDirection;
  final ScrollPhysics? physics;
  final double loadingIndicatorSpacing;
  final bool showErrorMessage;
  final bool showFloatingReturnTopButton;
  final ScrollController? controller;
  final List<Widget> slivers;
  final Duration loadingMinimumDuration;
  final void Function()? onEndReached;
  final DataCollectionFetchBloc bloc;

  const PagedSliverScrollViewWrapper({
    super.key,
    double? loadingIndicatorSpacing,
    this.scrollDirection = Axis.vertical,
    this.physics = const BouncingScrollPhysics(),
    this.controller,
    required this.bloc,
    this.slivers = const [],
    this.loadingMinimumDuration = const Duration(seconds: 2),
    this.showFloatingReturnTopButton = false,
    this.showErrorMessage = true,
    this.onEndReached,
  }) : loadingIndicatorSpacing = scrollDirection == Axis.vertical ? 50 : 25;

  @override
  State<PagedSliverScrollViewWrapper> createState() =>
      _PagedSliverScrollViewWrapperState();
}

class _PagedSliverScrollViewWrapperState
    extends State<PagedSliverScrollViewWrapper> {
  ScrollController? _controller;
  Widget? _loadingIndicator;

  int _currentTime() => DateTime.now().millisecondsSinceEpoch;

  var _timeStamp = 0;

  void _onScrollEndReached() async {
    if (_timeStamp + 2000 > _currentTime()) {
      return;
    }
    _timeStamp = _currentTime();
    widget.onEndReached?.call();

    Future.delayed(const Duration(milliseconds: 50), () => _scrollToEnd());
  }

  _scrollToEnd() {
    if (_controller?.hasClients ?? false) {
      _controller!.animateTo(_controller!.position.maxScrollExtent,
          curve: Curves.fastLinearToSlowEaseIn,
          duration: const Duration(milliseconds: 150));
    }
  }

  @override
  void initState() {
    super.initState();
    _loadingIndicator = PagedScrollViewLoadingIndicator(
        showErrorMessage: widget.showErrorMessage,
        bloc: widget.bloc,
        loadingIndicatorSpacing: widget.loadingIndicatorSpacing);
    _controller = widget.controller ?? ScrollController();
    _controller!.addListener(() {
      // if(_controller!.position.maxScrollExtent > MediaQuery.of(context).size)
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ScrollEndDetector(
          onScrollEndReached: _onScrollEndReached,
          child: CustomScrollView(
            controller: _controller,
            clipBehavior: Clip.none,
            scrollDirection: widget.scrollDirection,
            physics: widget.physics,
            slivers: [
              ...widget.slivers,
              SliverFillRemaining(
                fillOverscroll: true,
                hasScrollBody: false,
                child: _loadingIndicator!,
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: widget.loadingIndicatorSpacing),
              )
            ],
          ),
        ),
        if (widget.showFloatingReturnTopButton)
          ReturnTopButtonScrollView(controller: _controller!)
      ],
    );
  }
}

class PagedScrollViewLoadingIndicator extends StatelessWidget {
  final double loadingIndicatorSpacing;
  final bool showErrorMessage;
  final DataCollectionFetchBloc bloc;
  const PagedScrollViewLoadingIndicator(
      {super.key,
      required this.bloc,
      this.showErrorMessage = true,
      required this.loadingIndicatorSpacing});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(loadingIndicatorSpacing),
        child: BlocBuilder<DataCollectionFetchBloc, BasicServerFetchState>(
          bloc: bloc,
          builder: (context, state) {
            switch (state.status) {
              case BasicServerFetchStatus.loading:
                return const NetfloxLoadingIndicator();
              case BasicServerFetchStatus.failed:
                if (showErrorMessage) {
                  return Text(
                    state.error?.toString() ?? "error",
                    style: const TextStyle(fontSize: 15),
                  ).tr();
                }
                break;
              case BasicServerFetchStatus.finished:
            }
            return const SizedBox.shrink();
          },
        ));
  }
}

class ReturnTopButtonScrollView extends StatefulWidget {
  final ScrollController controller;
  const ReturnTopButtonScrollView({super.key, required this.controller});

  @override
  State<ReturnTopButtonScrollView> createState() =>
      _ReturnTopButtonScrollViewState();
}

class _ReturnTopButtonScrollViewState extends State<ReturnTopButtonScrollView> {
  bool _showed = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {
        _showed = widget.controller.offset > MediaQuery.of(context).size.height;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showed) {
      return Positioned(
          bottom: 25,
          right: 25,
          child: FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.arrow_upward),
              onPressed: () {
                widget.controller.animateTo(0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease);
              }));
    }
    return const SizedBox.shrink();
  }
}
