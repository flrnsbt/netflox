import 'dart:async';

import 'package:flutter/material.dart';

class ScrollEndDetector extends StatelessWidget {
  final Widget child;
  final FutureOr<void> Function() onScrollEndReached;
  const ScrollEndDetector(
      {Key? key, required this.child, required this.onScrollEndReached})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool canLoad = true;
    return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (!canLoad) {
            return false;
          }
          if (notification is ScrollUpdateNotification &&
              notification.metrics.pixels >
                  notification.metrics.maxScrollExtent + 10) {
            final result = onScrollEndReached();
            if (result is Future) {
              canLoad = false;
              result.then((value) => canLoad = true);
            }
          }
          return false;
        },
        child: child);
  }
}
