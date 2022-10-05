import 'package:flutter/cupertino.dart';

class CountryFlagIcon extends StatelessWidget {
  final String countryCode;
  const CountryFlagIcon({super.key, required this.countryCode});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20.0,
      width: 35,
      child: Image.network(
        "https://flagcdn.com/h20/${countryCode.toLowerCase()}.png",
        fit: BoxFit.fill,
      ),
    );
  }
}
