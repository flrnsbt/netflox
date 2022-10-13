import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:netflox/data/blocs/app_localization/extensions.dart';
import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/utils/platform_mobile_extension.dart';
import 'package:responsive_framework/responsive_row_column.dart';
import 'package:responsive_framework/responsive_wrapper.dart';

import '../../../../data/blocs/data_fetcher/tmdb/element_cubit.dart';
import '../../country_flag_icon.dart';
import 'components.dart';

class TMDBInfoComponent extends StatelessWidget {
  final TMDBMultiMedia media;
  const TMDBInfoComponent({super.key, required this.media});

  Widget _buildInfo(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: OverviewComponent(
            overview: media.overview,
          ),
        ),
        SizedBox(
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (media.date != null)
                Flexible(
                  child: MediaScreenComponent(
                    topMargin: 0,
                    titleSpacing: 5,
                    bottomMargin: 0,
                    name: 'release-date',
                    child: Text(
                      media.date!,
                      style: const TextStyle(
                          fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              if (media.productionCountries != null)
                Flexible(
                  child: MediaScreenComponent(
                    topMargin: 0,
                    bottomMargin: 0,
                    titleSpacing: 5,
                    name: 'production-countries',
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: media.productionCountries!.length,
                      itemBuilder: (context, index) {
                        return CountryFlagIcon(
                            countryCode: media.productionCountries![index]);
                      },
                    ),
                  ),
                ),
              if (ResponsiveWrapper.of(context).isLargerThan(TABLET) &&
                  platformIsMobile())
                Flexible(
                  child: Center(
                    child: TrailerButton(
                      media: media,
                    ),
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double? height =
        ResponsiveWrapper.of(context).isLargerThan(TABLET) ? 250 : null;
    return SizedBox(
      height: height,
      child: ResponsiveRowColumn(
          rowMainAxisSize: MainAxisSize.max,
          columnMainAxisSize: MainAxisSize.min,
          rowCrossAxisAlignment: CrossAxisAlignment.stretch,
          layout: ResponsiveWrapper.of(context).isLargerThan(TABLET)
              ? ResponsiveRowColumnType.ROW
              : ResponsiveRowColumnType.COLUMN,
          children: [
            ResponsiveRowColumnItem(
              rowFit: FlexFit.loose,
              child: _buildInfo(context),
            ),
            ResponsiveRowColumnItem(
                columnFit: FlexFit.loose,
                rowFit: FlexFit.tight,
                child: _buildCredits(context))
          ]),
    );
  }

  Widget _buildCredits(BuildContext context) {
    return const TMDBListPrimaryMediaLayout<TMDBFetchMediaCredits>.carousel(
      title: 'credits',
      play: true,
      height: 180,
    );
  }
}

class OverviewComponent extends StatelessWidget {
  final String? overview;
  final double leftMargin;
  final double rightMargin;
  const OverviewComponent(
      {super.key, this.overview, this.leftMargin = 10, this.rightMargin = 10});

  @override
  Widget build(BuildContext context) {
    var overview = this.overview;
    if (overview?.isEmpty ?? true) {
      overview = 'no-description'.tr(context);
    }
    return MediaScreenComponent(
      rightMargin: rightMargin,
      leftMargin: leftMargin,
      name: "overview",
      child: AutoSizeText(
        overview!,
        minFontSize: 8,
        textAlign: TextAlign.justify,
        wrapWords: false,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
