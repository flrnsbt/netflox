part of 'media_screen.dart';

class TMDBTvScreen extends StatelessWidget {
  final TMDBTv tv;
  const TMDBTvScreen({Key? key, required this.tv}) : super(key: key);

  Widget _buildSeasonLayout(BuildContext context) {
    final seasons = tv.seasons.reversed;
    final count = seasons.length;

    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) => _buildCard(
        context,
        seasons.elementAt(index),
      ),
      itemCount: count,
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
          return TMDBListCard(
            image: AspectRatio(
              aspectRatio: 1,
              child: TMDBImageWidget(
                img: season.img,
                borderRadius: BorderRadius.circular(10),
                padding: const EdgeInsets.only(right: 10),
                showError: false,
              ),
            ),
            title: AutoSizeText(
              season.name ?? "${"season".tr(context)} ${season.seasonNumber}",
              maxLines: 1,
              wrapWords: false,
              minFontSize: 12,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AutoSizeText(
                  "S${season.seasonNumber} - E${season.episodeCount}",
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.bold),
                ),
                if (season.date != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(season.date!,
                        style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 8,
                            color: Colors.white)),
                  ),
              ],
            ),
            bottom: FramedText(
              text: mediaStatus.tr(context),
              color: mediaStatusColor(mediaStatus),
            ),
            onTap: () => context.pushRoute(TVShowSeasonRoute(
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
              bottomMargin: 0,
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.only(left: 0, right: 0),
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
            flex: 6,
            child: AutoSizeText(
              tv.name,
              wrapWords: false,
              maxLines: 3,
              textAlign: TextAlign.end,
              minFontSize: 18,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 55, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Flexible(
            flex: 2,
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
                  if (tv.duration != null && tv.duration!.inMinutes != 0)
                    FramedText(
                      text: "${tv.duration!.inMinutes} mins",
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
          if (tv.voteAverage != null)
            Flexible(
              flex: 1,
              child: RatingWidget(
                score: tv.voteAverage!,
              ),
            ),
          const SizedBox(
            height: 15,
          ),
          Flexible(
            flex: 4,
            child: LibraryMediaControlLayout(
              media: tv,
            ),
          ),
        ],
      ),
    );
  }
}
