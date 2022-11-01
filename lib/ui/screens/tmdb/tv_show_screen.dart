part of 'media_screen.dart';

class TMDBTvScreen extends TMDBMediaScreenWrapper<TMDBTv>
    with TMDBPrimaryScreenWrapper {
  TMDBTvScreen({
    super.key,
    @PathParam('id') required this.id,
  });

  Widget _buildSeasonLayout(BuildContext context, TMDBTv media) {
    final seasons = media.seasons.reversed;
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
                            fontStyle: FontStyle.italic, fontSize: 8)),
                  ),
              ],
            ),
            bottom: FramedText(
              text: mediaStatus.tr(context),
              color: mediaStatusColor(mediaStatus),
            ),
            onTap: () {
              context.router.push(
                  TMDBTVShowSeasonRoute(id: season.seasonNumber, showId: id));
            },
          );
        },
      ),
    );
  }

  @override
  Widget buildLayout(BuildContext context, TMDBTv media) {
    return TMDBScreenBuilder(
        element: media,
        content: [
          TMDBInfoComponent(
            media: media,
          ),
          if (media.seasons.isNotEmpty)
            MediaScreenComponent(
                bottomMargin: 0,
                backgroundColor: Colors.transparent,
                padding: const EdgeInsets.only(left: 0, right: 0),
                name: 'season'.tr(context),
                child: _buildSeasonLayout(context, media)),
          if (ResponsiveWrapper.of(context).isSmallerThan(DESKTOP))
            VideoTrailer(
              media: media,
            ),
          TMDBListMediaLayout<
              TMDBFetchMultimediaCollection<
                  RecommendationRequestType>>.responsive(
            title: 'recommendations'.tr(context),
            context: context,
          ),
          TMDBListMediaLayout<
              TMDBFetchMultimediaCollection<SimilarRequestType>>.responsive(
            title: 'similars'.tr(context),
            context: context,
          ),
        ],
        header: MultimediaDefaultHeader(
          media: media,
        ));
  }

  @override
  final String id;
}
