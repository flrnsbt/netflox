part of 'media_screen.dart';

class TMDBTvScreen extends StatelessWidget {
  final TMDBTv tv;
  const TMDBTvScreen({Key? key, required this.tv}) : super(key: key);

  Widget _buildSeasonLayout(BuildContext context) {
    final seasons = tv.seasons.reversed;
    final count = seasons.length;
    var maxCrossAxisExtent = 200.0;
    if (count > 9) {
      maxCrossAxisExtent = 120;
    }
    return GridView.custom(
      shrinkWrap: true,
      clipBehavior: Clip.none,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: ResponsiveGridDelegate(
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          maxCrossAxisExtent: maxCrossAxisExtent,
          minCrossAxisExtent: 100,
          childAspectRatio: 1),
      childrenDelegate: SliverChildBuilderDelegate(
          (context, index) => AspectRatio(
                aspectRatio: 1,
                child: _buildCard(
                  context,
                  seasons.elementAt(index),
                ),
              ),
          childCount: seasons.length),
      scrollDirection: Axis.vertical,
    );
  }

  Widget _buildCard(BuildContext context, TMDBTVSeason season) {
    return BlocProvider(
      create: (context) => LibraryMediaInfoFetchCubit(season),
      child: BlocBuilder<LibraryMediaInfoFetchCubit,
          BasicServerFetchState<LibraryMediaInformation>>(
        builder: (context, state) {
          final mediaStatus =
              state.result?.mediaStatus ?? MediaStatus.unavailable;
          return TMDBMediaCard(
            media: season,
            showImageError: false,
            showHover: false,
            bannerOptions:
                CustomBannerOptions.mediaStatusBanner(context, mediaStatus),
            insetPadding: const EdgeInsets.all(15),
            contentBuilder: (context, media) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      ("${"season".tr(context)} ${season.seasonNumber}"),
                      maxLines: 1,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "${season.episodeCount} ${"episodes".tr(context)}",
                    maxLines: 1,
                    style: const TextStyle(fontSize: 8, color: Colors.white),
                  ),
                  const Spacer(),
                  if (season.date != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(season.date!,
                            style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 7,
                                color: Colors.white))
                      ],
                    )
                ],
              );
            },
            onTap: (season) => context.pushRoute(TVShowSeasonRoute(
                seasonNumber: season.seasonNumber, tvShowId: tv.id)),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TMDBScreenBuilder(
      element: tv,
      content: [
        // if (tv.productionCountries != null)
        //   Padding(
        //     padding: const EdgeInsets.only(bottom: 15),
        //     child: Wrap(
        //       spacing: 10,
        //       children: tv.productionCountries!
        //           .map((e) => CountryFlagIcon(countryCode: e))
        //           .toList(),
        //     ),
        //   ),
        const SizedBox(
          height: 35,
        ),
        if (tv.overview?.isNotEmpty ?? false)
          MediaScreenComponent(
              title: 'overview'.tr(context),
              child: Text(
                tv.overview!,
                style: const TextStyle(fontSize: 13),
              )),
        const SizedBox(
          height: 35,
        ),
        if (tv.seasons.isNotEmpty)
          MediaScreenComponent(
              title: 'season'.tr(context), child: _buildSeasonLayout(context)),
        const SizedBox(
          height: 35,
        ),
        TMDBListPrimaryMediaLayout<TMDBFetchMediaCredits>(
          title: 'credits'.tr(context),
          height: 150,
        ),
        const SizedBox(
          height: 35,
        ),
        VideoTrailer(
          media: tv,
        ),

        const SizedBox(
          height: 35,
        ),
        TMDBListPrimaryMediaLayout<
            TMDBFetchMultimediaCollection<RecommendationRequestType>>(
          title: 'recommendations'.tr(context),
          height: 200,
        ),
        const SizedBox(
          height: 25,
        ),
        TMDBListPrimaryMediaLayout<
            TMDBFetchMultimediaCollection<SimilarRequestType>>(
          title: 'similars'.tr(context),
          height: 200,
        ),
        const SizedBox(
          height: 55,
        ),
      ],
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: AutoSizeText(
                tv.name,
                wrapWords: false,
                maxLines: 3,
                textAlign: TextAlign.end,
                minFontSize: 25,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 55, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Flexible(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Row(
                children: [
                  if (tv.voteAverage != null)
                    RatingWidget(
                      score: tv.voteAverage!,
                    ),
                  if (tv.popularityLevel != null)
                    FramedText(
                      text: tv.popularityLevel!.tr(context).toUpperCase(),
                    ),
                  if (tv.genres.isNotEmpty)
                    FramedText(
                      text: tv.genres.first.tr(context),
                    ),
                  FramedText(
                    text: tv.type.name.tr(context),
                  ),
                  if (tv.duration != null)
                    FramedText(
                      text: "${tv.duration} mins",
                    ),
                ]
                    .map((e) => Padding(
                        padding: const EdgeInsets.only(left: 7), child: e))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Flexible(
            flex: 2,
            child: LibraryMediaControlLayout(
              media: tv,
            ),
          ),
        ],
      ),
    );
  }
}
