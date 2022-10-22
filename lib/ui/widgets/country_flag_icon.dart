import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:nil/nil.dart';

class CountryFlagIcon extends StatelessWidget {
  final String countryCode;
  final double height;
  final BoxFit fit;
  const CountryFlagIcon(
      {super.key,
      required this.countryCode,
      this.fit = BoxFit.fill,
      this.height = 20});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: "https://flagcdn.com/h20/${countryCode.toLowerCase()}.png",
      imageBuilder: (context, imageProvider) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: AspectRatio(
            aspectRatio: 5 / 4,
            child: Image(
              image: imageProvider,
              height: height,
              fit: fit,
            )),
      ),
      errorWidget: (context, url, error) => const Nil(),
    );
  }
}
