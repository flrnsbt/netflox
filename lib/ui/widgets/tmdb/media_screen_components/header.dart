import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../../data/models/tmdb/element.dart';
import '../../../../data/models/tmdb/media.dart';
import '../../background_image_widget.dart';
import '../tmdb_image.dart';

class TMDBScreenHeader extends StatelessWidget {
  final TMDBImageProvider element;
  final Widget child;
  const TMDBScreenHeader({
    Key? key,
    required this.child,
    required this.element,
  }) : super(key: key);

  Widget? _buildBackgroundImage(BuildContext context) {
    if (element.type.isMultimedia()) {
      final img = (element as TMDBMultiMedia).backdropImg;
      if (img != null) {
        return TMDBImageWidget(
          img: img,
          showError: false,
          showProgressIndicator: false,
        );
      }
    }
    return null;
  }

  Widget _buildImg(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: InkWell(
          onTap: () => showDialog(
              useRootNavigator: false,
              context: context,
              builder: (context) => ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: 400, maxHeight: 500),
                    child: Material(
                      child: InkWell(
                        onTap: () {
                          context.router.pop();
                        },
                        child: TMDBImageWidget(
                          fit: BoxFit.contain,
                          img: element.img,
                        ),
                      ),
                    ),
                  )),
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
        opacityStrength: 0.9,
        backgroundImage: _buildBackgroundImage,
        child: SafeArea(
          minimum:
              const EdgeInsets.only(left: 120, right: 25, top: 10, bottom: 20),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Flexible(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: child)),
            if (ResponsiveWrapper.of(context).isLargerThan(TABLET))
              _buildImg(context)
          ]),
        ));
  }
}
