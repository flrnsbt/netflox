import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:nil/nil.dart';

class CountryFlagIcon extends StatelessWidget {
  final String countryCode;
  final double height;
  const CountryFlagIcon(
      {super.key, required this.countryCode, this.height = 20});

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
              fit: BoxFit.fill,
            )),
      ),
      errorWidget: (context, url, error) => const Nil(),
    );
  }
}
