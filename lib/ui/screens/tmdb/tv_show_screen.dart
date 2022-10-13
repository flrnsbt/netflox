part of 'media_screen.dart';

class TMDBTvScreen extends StatelessWidget {
  final TMDBTv tv;
  const TMDBTvScreen({Key? key, required this.tv}) : super(key: key);

  Widget _buildSeasonLayout(BuildContext context) {
    final seasons = tv.seasons.reversed;
    final count = seasons.length;
    var maxCrossAxisExtent = 200.0;
    if (count > 6) {
      maxCrossAxisExtent = 120;
    }
    return GridView.custom(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: 15),
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
                  AutoSizeText(
                    ("${"season".tr(context)} ${season.seasonNumber}"),
                    maxLines: 1,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "${season.episodeCount} ${"episodes".tr(context)}",
                    maxLines: 1,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  const Spacer(),
                  if (season.date != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(season.date!,
                            style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 8,
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
        TMDBInfoComponent(
          media: tv,
        ),
        if (tv.seasons.isNotEmpty)
          MediaScreenComponent(
              padding: const EdgeInsets.only(left: 25, top: 15, right: 25),
              name: 'season'.tr(context),
              child: _buildSeasonLayout(context)),
        if (ResponsiveWrapper.of(context).isSmallerThan(DESKTOP))
          VideoTrailer(
            media: tv,
          ),
        TMDBListPrimaryMediaLayout<
            TMDBFetchMultimediaCollection<
                RecommendationRequestType>>.responsive(
          title: 'recommendations'.tr(context),
          context: context,
        ),
        TMDBListPrimaryMediaLayout<
            TMDBFetchMultimediaCollection<SimilarRequestType>>.responsive(
          title: 'similars'.tr(context),
          context: context,
        ),
      ],
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            flex: 4,
            child: AutoSizeText(
              tv.name,
              wrapWords: false,
              maxLines: 3,
              textAlign: TextAlign.end,
              minFontSize: 20,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 55, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          Flexible(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Row(
                children: [
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
            height: 15,
          ),
          Flexible(
            flex: 1,
            child: RatingWidget(
              score: tv.voteAverage!,
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
