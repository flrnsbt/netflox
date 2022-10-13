import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/blocs/theme/theme_cubit_cubit.dart';

class NetfloxAssetIcon extends StatelessWidget {
  final double height;
  const NetfloxAssetIcon({super.key, this.height = 40});

  @override
  Widget build(BuildContext context) {
    final mode = context.read<ThemeDataCubit>().state.data.brightness.name;

    return SizedBox(
      height: height,
      child: Image.asset(
        "assets/images/netflox_${mode}_small.png",
        fit: BoxFit.contain,
      ),
    );
  }
}
