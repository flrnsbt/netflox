import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/data_fetcher/basic_server_fetch_state.dart';
import 'package:netflox/data/blocs/data_fetcher/paged_data_collection_fetch_bloc.dart';
import 'package:netflox/data/constants/basic_fetch_status.dart';
import 'package:netflox/ui/widgets/netflox_loading_indicator.dart';
import 'package:netflox/ui/widgets/visibility_animation_widget.dart';
import '../../utils/platform_mobile_extension.dart';

enum PagedSliverScrollViewEventType {
  refresh,
  load;
}

const _kDelay = Duration(milliseconds: 2000);

class PagedSliverScrollViewWrapper extends StatefulWidget {
  final Axis scrollDirection;
  final ScrollPhysics? physics;
  final bool showFloatingReturnBeginButton;
  final ScrollController? controller;
  final Widget child;
  final Widget? header;
  final void Function(PagedSliverScrollViewEventType eventType)? onEvent;
  final LoadingIndicator? loadingIndicator;

  const PagedSliverScrollViewWrapper({
    super.key,
    this.scrollDirection = Axis.vertical,
    this.physics = const BouncingScrollPhysics(),
    this.controller,
    required this.child,
    this.loadingIndicator,
    this.showFloatingReturnBeginButton = false,
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

  bool _onNotification(ScrollNotification notification) {
    final viewportDimension = notification.metrics.viewportDimension;
    if (notification.metrics.pixels >=
        notification.metrics.maxScrollExtent +
            (platformIsMobile() ? (viewportDimension * 0.05) : 0)) {
      _load();
      return true;
    }

    if (notification.metrics.pixels < -viewportDimension * 0.1) {
      _requestRefresh();
      return true;
    }

    if (notification is ScrollEndNotification) {
      if (notification.metrics.pixels > viewportDimension) {
        _returnToTopScrollViewButtonController?.show();
      }
    }

    if (notification is ScrollStartNotification) {
      _returnToTopScrollViewButtonController?.hide();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: _onNotification,
          child: CustomScrollView(
            controller: _controller,
            scrollDirection: widget.scrollDirection,
            physics: _physics,
            slivers: [
              if (_header != null)
                SliverPadding(
                    padding: const EdgeInsets.only(bottom: 15),
                    sliver: _header!),
              widget.child,
              SliverFillRemaining(
                  fillOverscroll: true,
                  hasScrollBody: false,
                  child: _loadIndicator),
              const SliverToBoxAdapter(
                child: SizedBox.square(
                  dimension: 25,
                ),
              )
            ],
          ),
        ),
        if (widget.showFloatingReturnBeginButton)
          _ReturnToBeginButton(
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
  final BoxConstraints constraints;
  final Widget? Function(BuildContext context, [Object? error])? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget? Function(BuildContext context, [Object? result])? idleBuilder;
  final LoadingIndicatorController _controller;

  LoadingIndicator(
      {super.key,
      this.constraints = const BoxConstraints(maxHeight: 50, maxWidth: 100),
      LoadingIndicatorController? controller,
      this.errorBuilder,
      this.loadingBuilder,
      this.idleBuilder})
      : _controller = controller ?? LoadingIndicatorController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<LoadingIndicatorController, BasicServerFetchState>(
        bloc: _controller,
        builder: (context, state) {
          Widget? child;
          switch (state.status) {
            case BasicServerFetchStatus.loading:
              child = loadingBuilder?.call(context) ??
                  const NetfloxLoadingIndicator();
              break;
            case BasicServerFetchStatus.failed:
              child = errorBuilder?.call(context, state.error) ??
                  Icon(Icons.warning,
                      size: 36, color: Theme.of(context).hintColor);
              break;
            case BasicServerFetchStatus.success:
              child = idleBuilder?.call(context, state.result);
              break;
            case BasicServerFetchStatus.init:
              break;
          }
          if (child != null) {
            return Padding(
              padding: const EdgeInsets.all(25),
              child: ConstrainedBox(constraints: constraints, child: child),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  LoadingIndicator copyWith(
      {BoxConstraints? constraints = const BoxConstraints(maxHeight: 50),
      LoadingIndicatorController? controller,
      Widget? Function(BuildContext context, [Object? error])? errorBuilder,
      Widget Function(BuildContext context)? loadingBuilder,
      Widget? Function(BuildContext context, [Object? result])? idleBuilder}) {
    return LoadingIndicator(
      constraints: constraints ?? this.constraints,
      controller: controller ?? _controller,
      errorBuilder: errorBuilder ?? this.errorBuilder,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      idleBuilder: idleBuilder ?? this.idleBuilder,
    );
  }
}

class LoadingIndicatorController extends Cubit<BasicServerFetchState> {
  void updateState(BasicServerFetchState state) {
    emit(state);
  }

  static LoadingIndicatorController from(PagedDataCollectionFetchBloc bloc) {
    final controller = LoadingIndicatorController();
    bloc.stream.listen((event) {
      controller.updateState(event);
    });
    return controller;
  }

  LoadingIndicatorController(
      {BasicServerFetchStatus initialState = BasicServerFetchStatus.init})
      : super(BasicServerFetchState(status: initialState));
}

class _ReturnToBeginButton extends StatelessWidget {
  final EasyVisibilityController controller;
  final void Function()? onPressed;

  const _ReturnToBeginButton({required this.controller, this.onPressed});

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
