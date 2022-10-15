import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:netflox/ui/widgets/constrained_large_screen_widget.dart';
import 'package:netflox/ui/widgets/error_widget.dart';

class ErrorScreen extends StatelessWidget {
  final Object? errorCode;
  final Widget? child;
  const ErrorScreen(
      {super.key, @PathParam('error') this.errorCode, this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: ConstrainedLargeScreenWidget(
        child: CustomErrorWidget.from(
          error: errorCode,
          bottom: child,
        ),
      ),
    );
  }
}
