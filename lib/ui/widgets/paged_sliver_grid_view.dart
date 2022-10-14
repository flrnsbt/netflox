import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/data_fetcher/basic_server_fetch_state.dart';
import 'package:netflox/data/blocs/data_fetcher/paged_data_collection_fetch_bloc.dart';
import 'package:netflox/data/constants/basic_fetch_status.dart';
import 'package:netflox/ui/widgets/error_widget.dart';
import 'package:netflox/ui/widgets/netflox_loading_indicator.dart';
import 'package:netflox/ui/widgets/visibility_animation_widget.dart';
import 'package:nil/nil.dart';

enum PagedSliverScrollViewEventType {
  refresh,
  load;
}

const _kOverscrollOffset = 100;
const _kDelay = Duration(milliseconds: 2000);

class PagedSliverScrollViewWrapper extends StatefulWidget {
  final Axis scrollDirection;
  final ScrollPhysics? physics;
  final bool showFloatingReturnTopButton;
  final ScrollController? controller;
  final Widget child;
  final Widget? header;
  final void Function(PagedSliverScrollViewEventType eventType)? onEvent;
  final LoadingIndicator? loadingIndicator;

  const PagedSliverScrollViewWrapper({
    super.key,
    double? loadingIndicatorSpacing,
    this.scrollDirection = Axis.vertical,
    this.physics = const BouncingScrollPhysics(),
    this.controller,
    required this.child,
    this.loadingIndicator,
    this.showFloatingReturnTopButton = false,
    this.onEvent,
    this.header,
  });

  @override
  State<PagedSliverScrollViewWrapper> createState() =>
      _PagedSliverScrollViewWrapperState();
}

class _PagedSliverScrollViewWrapperState
    extends State<PagedSliverScrollViewWrapper> {
  late ScrollController _controller;
  late LoadingIndicator _loadIndicator;
  ScrollPhysics? _physics;
  EasyVisibilityController? _returnToTopScrollViewButtonController;
  Widget? _header;
  final _currentEventType =
      ValueNotifier<PagedSliverScrollViewEventType?>(null);

  var _loadTimeStamp = DateTime.fromMillisecondsSinceEpoch(0);

  void _load() async {
    final now = DateTime.now();
    if (!_isLoading() && now.difference(_loadTimeStamp) > _kDelay) {
      _loadTimeStamp = now;
      Future.delayed(const Duration(milliseconds: 50), () => _scrollToEnd());
      _currentEventType.value = PagedSliverScrollViewEventType.load;
    }
  }

  void _refresh() async {
    final now = DateTime.now();
    if (!_isLoading() && now.difference(_loadTimeStamp) > _kDelay) {
      _loadTimeStamp = now;
      _currentEventType.value = PagedSliverScrollViewEventType.refresh;
    }
  }

  bool _isLoading() => _loadIndicator._controller.state.isLoading();

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
    _header = widget.header;
    _physics = widget.physics ?? const BouncingScrollPhysics();
    _controller = widget.controller ?? ScrollController();
    _returnToTopScrollViewButtonController = EasyVisibilityController();
    _loadIndicator = widget.loadingIndicator ?? LoadingIndicator();
    _loadIndicator._controller.stream.listen((event) {
      if (!event.isLoading()) {
        _currentEventType.value = null;
      }
    });

    _currentEventType.addListener(_eventChanged);
  }

  void _eventChanged() {
    final value = _currentEventType.value;
    if (value != null) {
      widget.onEvent?.call(value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _currentEventType.removeListener(_eventChanged);
    super.dispose();
  }

  void _requestRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer(const Duration(milliseconds: 100), () {
      _refresh();
    });
  }

  Timer? _refreshTimer;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent) {
              _load();
              return true;
            }

            if (notification.metrics.pixels < -_kOverscrollOffset) {
              _requestRefresh();
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
            scrollDirection: widget.scrollDirection,
            physics: _physics,
            slivers: [
              if (_header != null) _header!,
              widget.child,
              SliverFillRemaining(
                  fillOverscroll: true,
                  hasScrollBody: false,
                  child: _loadIndicator),
            ],
          ),
        ),
        if (widget.showFloatingReturnTopButton)
          _ReturnToTopButton(
            controller: _returnToTopScrollViewButtonController!,
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

class LoadingIndicator extends StatelessWidget {
  final double loadingIndicatorSpacing;
  final double maxHeight;
  final Widget? Function(BuildContext context, [Object? error])? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget? Function(BuildContext context, [Object? result])? idleBuilder;
  final LoadingIndicatorController _controller;

  LoadingIndicator(
      {super.key,
      this.maxHeight = 150,
      LoadingIndicatorController? controller,
      this.loadingIndicatorSpacing = 25,
      this.errorBuilder,
      this.loadingBuilder,
      this.idleBuilder})
      : _controller = controller ?? LoadingIndicatorController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: BlocProvider(
          create: (context) => _controller,
          child: BlocBuilder<LoadingIndicatorController, BasicServerFetchState>(
            builder: (context, state) {
              Widget? child;
              switch (state.status) {
                case BasicServerFetchStatus.loading:
                  child = loadingBuilder?.call(context) ??
                      const NetfloxLoadingIndicator();
                  break;
                case BasicServerFetchStatus.failed:
                  child = SizedBox(
                    height: 60,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: errorBuilder?.call(context, state.error) ??
                          CustomErrorWidget.from(
                            error: state.error,
                            showTitle: false,
                          ),
                    ),
                  );
                  break;
                case BasicServerFetchStatus.success:
                  child = idleBuilder?.call(context, state.result);
                  break;
                case BasicServerFetchStatus.init:
                  break;
              }
              if (child != null) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: loadingIndicatorSpacing),
                  child: child,
                );
              }
              return const Nil();
            },
          ),
        ),
      ),
    );
  }
}

class LoadingIndicatorController extends Cubit<BasicServerFetchState> {
  bool _active;
  void updateState(BasicServerFetchState state) {
    if (_active) {
      emit(state);
    }
  }

  activate() => _active = true;
  deactivate() => _active = false;

  static LoadingIndicatorController from(PagedDataCollectionFetchBloc bloc) {
    final controller = LoadingIndicatorController();
    bloc.stream.listen((event) {
      controller.updateState(event);
    });
    return controller;
  }

  LoadingIndicatorController(
      {BasicServerFetchStatus initialState = BasicServerFetchStatus.init})
      : _active = true,
        super(BasicServerFetchState(status: initialState));
}

class _ReturnToTopButton extends StatelessWidget {
  final EasyVisibilityController controller;
  final void Function()? onPressed;

  const _ReturnToTopButton({required this.controller, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 20,
      child: VisibilityAnimationWidget(
        controller: controller,
        child: FloatingActionButton(
            elevation: 20,
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: onPressed,
            child: const Icon(Icons.arrow_upward)),
      ),
    );
  }
}
