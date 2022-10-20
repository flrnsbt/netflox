part of 'media_screen.dart';

class TMDBMovieScreen extends StatelessWidget {
  final TMDBMovie movie;
  const TMDBMovieScreen({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TMDBScreenBuilder(
      element: movie,
      content: [
        TMDBInfoComponent(
          media: movie,
        ),
        if (ResponsiveWrapper.of(context).isSmallerThan(DESKTOP))
          VideoTrailer(
            media: movie,
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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            flex: 6,
            child: AutoSizeText(
              movie.name,
              wrapWords: false,
              maxLines: 3,
              textAlign: TextAlign.end,
              minFontSize: 18,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 55,
                fontWeight: FontWeight.bold,
              ),
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
                if (movie.popularityLevel != null)
                  FramedText(
                    text: movie.popularityLevel!.tr(context).toUpperCase(),
                  ),
                if (movie.genres.isNotEmpty)
                  FramedText(
                    text: movie.genres.first.tr(context),
                  ),
                FramedText(
                  text: movie.type.name.tr(context),
                ),
                if (movie.duration != null && movie.duration!.inMinutes != 0)
                  FramedText(
                    text: "${movie.duration!.inMinutes} mins",
                  ),
              ]
                      .map((e) => Padding(
                          padding: const EdgeInsets.only(left: 7), child: e))
                      .toList()),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          if (movie.voteAverage != null)
            Flexible(
              flex: 1,
              child: RatingWidget(
                score: movie.voteAverage!,
              ),
            ),
          const SizedBox(
            height: 15,
          ),
          Flexible(
            flex: 4,
            child: LibraryMediaControlLayout(
              media: movie,
            ),
          ),
        ],
      ),
    );
  }
}
