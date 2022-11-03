import 'package:flutter/material.dart';
import 'package:netflox/ui/router/idle_timed_auto_push_route.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../../data/models/tmdb/element.dart';
import '../../../../data/models/tmdb/img.dart';
import '../../../../data/models/tmdb/media.dart';
import '../../background_image_widget.dart';
import '../tmdb_image.dart';

class TMDBScreenHeaderContent extends StatelessWidget {
  final TMDBElementWithImage element;
  final Widget child;
  const TMDBScreenHeaderContent({
    Key? key,
    required this.child,
    required this.element,
  }) : super(key: key);

  Widget? _buildBackgroundImage(BuildContext context) {
    final img = image;
    if (img != null) {
      return InkWell(
        onTap: () => _showImageDialog(context),
        child: TMDBImageWidget(
          img: img,
          showError: false,
          showProgressIndicator: false,
        ),
      );
    }
    return null;
  }

  TMDBImg? get image {
    if (element.type.isMultimedia()) {
      return (element as TMDBMultiMedia).backdropImg;
    }
    return null;
  }

  Future<void> _showImageDialog(BuildContext context) => showDialog(
      useRootNavigator: false,
      context: context,
      builder: (context) => Dialog(
            child: GestureDetector(
              onTap: () {
                context.router.pop();
              },
              child: TMDBImageWidget(
                fit: BoxFit.contain,
                img: element.img,
              ),
            ),
          ));

  Widget _buildImg(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: InkWell(
          onTap: () => _showImageDialog(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: TMDBImageWidget(
              img: element.img,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NetfloxBackgroundImage(
        color: Colors.black,
        opacityStrength: 0.7,
        backgroundImage: _buildBackgroundImage,
        child: SafeArea(
          minimum: const EdgeInsets.only(left: 130, right: 25, bottom: 20),
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Flexible(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: child)),
              if (ResponsiveWrapper.of(context).isLargerThan(TABLET))
                _buildImg(context)
            ]),
          ),
        ));
  }
}
