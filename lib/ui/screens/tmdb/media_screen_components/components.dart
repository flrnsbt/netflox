library mediascreencomponents;

import 'package:flutter/material.dart';
import 'package:netflox/ui/widgets/see_more_widget.dart';

export 'favorite_button.dart';
export 'header.dart';
export 'media_access_control.dart';
export 'person_casting_grid_layout.dart';
export 'tmdb_list_media_layout.dart';
export 'tmdb_screen_builder.dart';
export 'video_trailer.dart';

class MediaScreenComponent extends StatelessWidget {
  final String title;
  final Widget? action;
  final Widget child;
  final double? heightConstraint;

  const MediaScreenComponent(
      {super.key,
      required this.title,
      this.action,
      required this.child,
      this.heightConstraint});
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              const Spacer(),
              if (action != null) action!
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          if (heightConstraint != null)
            SeeMoreWidget(
              maxHeight: heightConstraint!,
              child: child,
            )
          else
            child,
        ]);
  }
}
