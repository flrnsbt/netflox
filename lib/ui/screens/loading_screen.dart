import 'package:flutter/material.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/ui/widgets/netflox_loading_indicator.dart';

class LoadingScreen extends StatelessWidget {
  final String? loadingMessage;
  final Color? color;
  const LoadingScreen({Key? key, this.loadingMessage, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const NetfloxLoadingIndicator(),
          if (loadingMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 25, left: 35, right: 35),
              child: Text("${loadingMessage!.tr(context)}...",
                  style: const TextStyle(fontSize: 10)),
            )
        ],
      ),
    );
  }
}
