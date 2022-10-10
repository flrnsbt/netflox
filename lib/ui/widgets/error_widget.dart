import 'package:flutter/material.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/models/exception.dart';

class CustomErrorWidget extends StatelessWidget {
  final String? errorTitle;
  final String? errorDescription;
  final Widget? bottom;
  final Widget image;
  const CustomErrorWidget(
      {Key? key,
      this.errorTitle,
      this.errorDescription,
      this.bottom,
      Widget? image})
      : image =
            image ?? const Icon(Icons.warning, size: 48, color: Colors.white70),
        super(key: key);

  factory CustomErrorWidget.from(
      {bool showTitle = true,
      bool showDescription = true,
      Object? error,
      Widget? bottom,
      Widget? image}) {
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
      image: image,
      errorTitle: title,
      errorDescription: desc,
      bottom: bottom,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.symmetric(horizontal: 35),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              constraints: BoxConstraints.loose(const Size.fromHeight(200)),
              child: image,
            ),
            if (errorTitle != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  errorTitle!,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ).tr(),
              ),
            if (errorDescription != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  errorDescription!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ).tr(),
              ),
            if (bottom != null) bottom!,
          ],
        ),
      ),
    );
  }
}
