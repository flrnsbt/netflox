import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/ui/router/router.gr.dart';
import 'package:flutter/widgets.dart' show BuildContext;

mixin IdleTimedPushAutoRoute on RootStackRouter {
  int _lastTimestamp = 0;
  @override
  Future<T?> push<T extends Object?>(PageRouteInfo route,
      {OnNavigationFailure? onFailure}) async {
    final currentTimestamp = Timestamp.now().millisecondsSinceEpoch;
    if (currentTimestamp > _lastTimestamp + 500) {
      _lastTimestamp = currentTimestamp;
      return super.push(route, onFailure: onFailure);
    }
    return null;
  }
}

extension CustomAutoRouteX on BuildContext {
  NetfloxRouter get router => read<NetfloxRouter>();

  Future<T?> pushRoute<T extends Object?>(PageRouteInfo<dynamic> route,
          {void Function(NavigationFailure)? onFailure}) =>
      router.push(route);
}
