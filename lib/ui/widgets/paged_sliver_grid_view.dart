// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:netflox/data/blocs/data_fetcher/basic_server_fetch_state.dart';
import 'package:netflox/data/blocs/data_fetcher/paged_data_collection_fetch_bloc.dart';
import 'package:netflox/data/constants/basic_fetch_status.dart';
import 'package:netflox/ui/widgets/error_widget.dart';
import 'package:netflox/ui/widgets/netflox_loading_indicator.dart';
import 'package:nil/nil.dart';

class PagedSliverScrollViewWrapper extends StatefulWidget {
  final Axis scrollDirection;
  final ScrollPhysics? physics;
  final bool showFloatingReturnTopButton;
  final ScrollController? controller;
  final List<Widget> slivers;
  final void Function()? onEndReached;
  final void Function()? onCancelRequested;
  final PagedScrollViewAsyncFeedback? pagedScrollViewAsyncFeedback;

  const PagedSliverScrollViewWrapper({
    super.key,
    double? loadingIndicatorSpacing,
    this.scrollDirection = Axis.vertical,
    this.physics = const BouncingScrollPhysics(),
    this.controller,
    this.slivers = const [],
    this.onCancelRequested,
    this.pagedScrollViewAsyncFeedback,
    this.showFloatingReturnTopButton = false,
    this.onEndReached,
  });

  @override
  State<PagedSliverScrollViewWrapper> createState() =>
      _PagedSliverScrollViewWrapperState();
}

class _PagedSliverScrollViewWrapperState
    extends State<PagedSliverScrollViewWrapper> {
  late ScrollController _controller;
  PagedScrollViewAsyncFeedback? _asyncFeedbackWidget;
  PagedScrollViewAsyncFeedbackController? _asyncFeedbackController;
  ScrollPhysics? _physics;
  ReturnTopButtonScrollViewController? _returnToTopScrollViewButtonController;

  int _currentTime() => DateTime.now().millisecondsSinceEpoch;

  var _timeStamp = 0;
  bool _isLoading() => _asyncFeedbackController?.state.isLoading() ?? false;

  void _onScrollEndReached() async {
    if (!_isLoading() && _timeStamp + 2000 < _currentTime()) {
      _timeStamp = _currentTime();
      widget.onEndReached?.call();
      Future.delayed(const Duration(milliseconds: 50), () => _scrollToEnd());
    }
  }

  void changePhysics(ScrollPhysics newPhysics) {
    if (newPhysics != _physics) {
      setState(() {
        _physics = newPhysics;
      });
    }
  }

  _scrollToEnd() {
    if (_controller.position.hasContentDimensions) {
      _controller.animateTo(_controller.position.maxScrollExtent,
          curve: Curves.fastLinearToSlowEaseIn,
          duration: const Duration(milliseconds: 150));
    }
  }

  @override
  void initState() {
    super.initState();
    _physics = widget.physics ?? const BouncingScrollPhysics();
    _asyncFeedbackWidget =
        widget.pagedScrollViewAsyncFeedback ?? PagedScrollViewAsyncFeedback();
    _asyncFeedbackController = _asyncFeedbackWidget!._controller;
    _controller = widget.controller ?? ScrollController();
    _returnToTopScrollViewButtonController =
        ReturnTopButtonScrollViewController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >
                notification.metrics.maxScrollExtent) {
              _onScrollEndReached();
              return true;
            }

            if (notification is ScrollEndNotification) {
              if (notification.metrics.pixels >
                  MediaQuery.of(context).size.height) {
                _returnToTopScrollViewButtonController?.show();
              }
            }

            if (notification is ScrollStartNotification) {
              _returnToTopScrollViewButtonController?.hide();
            }
            return false;
          },
          child: CustomScrollView(
            controller: _controller,
            clipBehavior: Clip.none,
            scrollDirection: widget.scrollDirection,
            physics: _physics,
            slivers: [
              ...widget.slivers,
              SliverFillRemaining(
                fillOverscroll: true,
                hasScrollBody: false,
                child: _asyncFeedbackWidget!,
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 25),
              )
            ],
          ),
        ),
        if (widget.showFloatingReturnTopButton)
          ReturnTopButtonScrollView(
            controller: _returnToTopScrollViewButtonController,
            onPressed: () {
              _controller.animateTo(0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease);
            },
          )
      ],
    );
  }
}

class PagedScrollViewAsyncFeedback extends StatelessWidget {
  final double loadingIndicatorSpacing;
  final Size maxSize;
  final Widget? Function(BuildContext context, [Object? error])? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget? Function(BuildContext context, [Object? result])? idleBuilder;
  final PagedScrollViewAsyncFeedbackController _controller;

  PagedScrollViewAsyncFeedback(
      {super.key,
      this.maxSize = const Size(300, 60),
      PagedScrollViewAsyncFeedbackController? controller,
      this.loadingIndicatorSpacing = 25,
      this.errorBuilder,
      this.loadingBuilder,
      this.idleBuilder})
      : _controller = controller ?? PagedScrollViewAsyncFeedbackController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          constraints: BoxConstraints.loose(maxSize),
          margin: EdgeInsets.all(loadingIndicatorSpacing),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: BlocProvider(
              create: (context) => _controller,
              child: BlocBuilder<PagedScrollViewAsyncFeedbackController,
                  BasicServerFetchState>(
                builder: (context, state) {
                  switch (state.status) {
                    case BasicServerFetchStatus.loading:
                      return loadingBuilder?.call(context) ??
                          const NetfloxLoadingIndicator();
                    case BasicServerFetchStatus.failed:
                      return errorBuilder?.call(context, state.error) ??
                          CustomErrorWidget.from(
                            error: state.error,
                            showTitle: false,
                          );
                    case BasicServerFetchStatus.success:
                      return idleBuilder?.call(context, state.result) ??
                          const Nil();
                    case BasicServerFetchStatus.init:
                      return const Nil();
                  }
                },
              ),
            ),
          )),
    );
  }
}

class PagedScrollViewAsyncFeedbackController
    extends Cubit<BasicServerFetchState> {
  void updateState(BasicServerFetchState state) {
    emit(state);
  }

  static PagedScrollViewAsyncFeedbackController from(
      PagedDataCollectionFetchBloc bloc) {
    final controller = PagedScrollViewAsyncFeedbackController();
    bloc.stream.listen((event) {
      controller.updateState(event);
    });
    return controller;
  }

  PagedScrollViewAsyncFeedbackController(
      {BasicServerFetchStatus initialState = BasicServerFetchStatus.init})
      : super(BasicServerFetchState(status: initialState));
}

class ReturnTopButtonScrollView extends StatefulWidget {
  const ReturnTopButtonScrollView({super.key, this.controller, this.onPressed});
  final ReturnTopButtonScrollViewController? controller;
  final void Function()? onPressed;

  @override
  State<ReturnTopButtonScrollView> createState() =>
      _ReturnTopButtonScrollViewState();
}

class _ReturnTopButtonScrollViewState extends State<ReturnTopButtonScrollView>
    with TickerProviderStateMixin {
  late final AnimationController _visibility;

  @override
  void initState() {
    super.initState();
    _visibility = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 300));
    widget.controller?.addListener(() {
      if (widget.controller!.isShowing()) {
        _visibility.forward();
      } else {
        _visibility.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 20,
        right: 0,
        child: ValueListenableBuilder(
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          valueListenable: _visibility,
          child: FloatingActionButton(
              elevation: 20,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.arrow_upward),
              onPressed: () {
                widget.onPressed?.call();
              }),
        ));
  }
}

class ReturnTopButtonScrollViewController extends ChangeNotifier {
  bool _show;

  bool isShowing() => _show;

  set __show(bool show) {
    _show = show;
    notifyListeners();
  }

  void show() => __show = true;
  void hide() => __show = false;

  ReturnTopButtonScrollViewController({
    bool show = false,
  }) : _show = show;
}
