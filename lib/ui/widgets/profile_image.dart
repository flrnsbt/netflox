import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileImage extends StatelessWidget {
  final String? imgUrl;
  const ProfileImage({super.key, this.imgUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.none,
      decoration: const BoxDecoration(shape: BoxShape.circle, boxShadow: [
        BoxShadow(
          color: Color.fromARGB(32, 0, 0, 0),
          blurRadius: 4.0,
        )
      ]),
      child: imgUrl != null
          ? CachedNetworkImage(
              imageUrl: imgUrl!,
              fit: BoxFit.cover,
            )
          : Image.asset(
              "assets/images/avatar_${Random().nextInt(1) + 1}.png",
              fit: BoxFit.contain,
            ),
    );
  }
}
