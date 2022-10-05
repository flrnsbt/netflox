import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../../data/blocs/theme/theme_cubit_cubit.dart';
import '../../../../data/models/tmdb/element.dart';
import '../../../../data/models/tmdb/media.dart';
import '../../../widgets/background_image_widget.dart';
import '../../../widgets/tmdb/tmdb_image.dart';

class TMDBScreenHeader extends StatelessWidget {
  final TMDBImageProvider element;
  final Widget child;
  const TMDBScreenHeader({Key? key, required this.child, required this.element})
      : super(key: key);

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
              context: context,
              builder: (context) => Card(
                    margin: const EdgeInsets.all(25),
                    child: InkWell(
                      onTap: () {
                        context.router.pop();
                      },
                      child: TMDBImageWidget(
                        img: element.img,
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
      backgroundImage: _buildBackgroundImage,
      child: SafeArea(
          minimum:
              const EdgeInsets.only(left: 110, right: 25, top: 20, bottom: 20),
          child: Row(children: [
            Expanded(child: child),
            if (element.img != null &&
                ResponsiveWrapper.of(context).isLargerThan(MOBILE))
              _buildImg(context)
          ])),
    );
  }
}
