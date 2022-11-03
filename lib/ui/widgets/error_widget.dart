import 'package:flutter/material.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/models/exception.dart';

class CustomErrorWidget extends StatelessWidget {
  final String? errorTitle;
  final String? errorDescription;
  final Widget? bottom;
  final Widget leading;
  final double maxWidth;
  const CustomErrorWidget(
      {Key? key,
      this.errorTitle,
      String? errorDescription,
      this.bottom,
      this.maxWidth = 400,
      Widget? leading})
      : leading = leading ??
            const Icon(
              Icons.warning,
              size: 36,
            ),
        errorDescription = errorDescription ?? 'error',
        super(key: key);

  factory CustomErrorWidget.from(
      {bool showTitle = true,
      bool showDescription = true,
      Object? error,
      Widget? bottom,
      Widget? leading}) {
    final exception = NetfloxException.from(error);
    String? desc;
    String? title;
    if (showDescription) {
      desc = '${exception.errorCode}-desc';
    }
    if (showTitle) {
      title = exception.errorCode;
    }
    return CustomErrorWidget(
      leading: leading,
      errorTitle: title,
      errorDescription: desc,
      bottom: bottom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            constraints: BoxConstraints.loose(const Size.fromHeight(200)),
            child: leading,
          ),
          if (errorTitle != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                errorTitle!,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ).tr(),
            ),
          if (errorDescription != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                errorDescription!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ).tr(),
            ),
          if (bottom != null) bottom!,
        ],
      ),
    );
  }
}
