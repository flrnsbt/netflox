import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netflox/data/models/tmdb/img.dart';
import 'package:netflox/ui/widgets/default_shimmer.dart';
import '../../../data/blocs/app_config.dart';

class TMDBImageWidget extends StatelessWidget {
  final TMDBImg? img;
  final BoxFit fit;
  final bool showError;
  final bool showProgressIndicator;
  final bool fadeAnimations;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;
  final BlendMode? colorBlendMode;
  final Color? color;
  final Widget Function(BuildContext, ImageProvider<Object>)? imageBuilder;
  TMDBImageWidget(
      {GlobalKey? key,
      this.img,
      this.fit = BoxFit.cover,
      this.showError = true,
      this.padding = EdgeInsets.zero,
      this.color,
      this.borderRadius,
      this.colorBlendMode,
      this.fadeAnimations = false,
      this.imageBuilder,
      this.showProgressIndicator = true})
      : super(key: key ?? GlobalKey());

  String _getUrl(BuildContext context, double size, TMDBImg img) {
    final baseUrl =
        context.read<AppConfigCubit>().state.tmdbApiConfig!.imgDatabaseUrl;
    final imgUrl = img.getImgUrl(size);
    return "$baseUrl$imgUrl";
  }

  @override
  Widget build(BuildContext context) {
    if (img != null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.smallest.longestSide;
          final url = _getUrl(context, size, img!);
          return CachedNetworkImage(
            imageBuilder: (context, imageProvider) {
              return Padding(
                padding: padding,
                child: imageBuilder?.call(context, imageProvider) ??
                    ClipRRect(
                        borderRadius: borderRadius ?? BorderRadius.zero,
                        child: Image(
                          image: imageProvider,
                          fit: fit,
                        )),
              );
            },
            colorBlendMode: colorBlendMode,
            fit: fit,
            color: color,
            progressIndicatorBuilder: (context, url, progress) =>
                const DefaultShimmer(),
            fadeOutDuration: Duration(milliseconds: fadeAnimations ? 200 : 0),
            fadeInDuration: Duration(milliseconds: fadeAnimations ? 200 : 0),
            imageUrl: url,
            errorWidget: (context, url, error) => _buildError(context),
          );
        },
      );
    }
    return _buildError(context);
  }

  Widget _buildError(BuildContext context) {
    return showError
        ? const FractionallySizedBox(
            heightFactor: 0.3,
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: Text(
                "?",
                style: TextStyle(color: Colors.white54),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
