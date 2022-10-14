library mediascreencomponents;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/ui/widgets/see_more_widget.dart';
import 'package:netflox/ui/widgets/tmdb/media_screen_components/video_trailer.dart';
import '../../../../data/blocs/data_fetcher/tmdb/element_cubit.dart';

export 'favorite_button.dart';
export 'header.dart';
export 'media_access_control.dart';
export 'person_casting_grid_layout.dart';
export 'tmdb_list_media_layout.dart';
export 'tmdb_screen_builder.dart';
export 'video_trailer.dart';

class MediaScreenComponent extends StatelessWidget {
  final String? name;
  final Widget? action;
  final Widget child;
  final double? heightConstraint;
  final EdgeInsets padding;
  final double leftMargin;
  final double rightMargin;
  final double topMargin;
  final double bottomMargin;
  final double titleSpacing;
  final double titleSize;
  final Color? backgroundColor;

  const MediaScreenComponent(
      {super.key,
      required this.name,
      this.action,
      this.titleSpacing = 10,
      this.padding = const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      this.leftMargin = 10,
      this.titleSize = 15,
      this.rightMargin = 10,
      this.topMargin = 16,
      this.backgroundColor,
      this.bottomMargin = 16,
      required this.child,
      this.heightConstraint});
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: backgroundColor ?? Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(5)),
        // alignment: Alignment.topCenter,
        margin: EdgeInsets.only(
            left: leftMargin,
            right: rightMargin,
            bottom: bottomMargin,
            top: topMargin),
        padding: padding,
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (name != null)
                    Flexible(
                      flex: 5,
                      child: AutoSizeText(
                        name!.tr(context),
                        maxLines: 1,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: titleSize),
                      ),
                    ),
                  if (action != null) Flexible(child: action!)
                ],
              ),
              SizedBox(
                height: titleSpacing,
              ),
              Flexible(
                child: heightConstraint != null
                    ? SeeMoreWidget(
                        maxHeight: heightConstraint!,
                        child: child,
                      )
                    : child,
              )
            ]));
  }
}

class TMDBHeaderButton extends StatelessWidget {
  final Color color;
  final String text;
  final bool filled;
  final void Function()? onPressed;
  const TMDBHeaderButton(
      {super.key,
      required this.text,
      this.filled = true,
      this.onPressed,
      this.color = Colors.pink});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        fixedSize: const MaterialStatePropertyAll(Size.fromHeight(30)),
        backgroundColor:
            MaterialStatePropertyAll(filled ? color : Colors.transparent),
        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
          side: BorderSide(color: color),
          borderRadius: BorderRadius.circular(5),
        )),
      ),
      onPressed: onPressed,
      child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: TextStyle(
                color: filled ? Colors.white : color,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 1,
          ).tr()),
    );
  }
}

class TrailerButton extends StatelessWidget {
  final TMDBMultiMedia media;
  const TrailerButton({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    return TMDBHeaderButton(
      text: 'trailer',
      color: Colors.indigo,
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) {
            return Center(
                child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Card(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: BlocProvider.value(
                  value: context.read<TMDBFetchVideosCubit>(),
                  child: VideoTrailer(
                    media: media,
                  ),
                ),
              ),
            ));
          },
        );
      },
    );
  }
}
