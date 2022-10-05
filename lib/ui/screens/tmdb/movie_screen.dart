part of 'media_screen.dart';

class TMDBMovieScreen extends StatelessWidget {
  final TMDBMovie movie;
  const TMDBMovieScreen({Key? key, required this.movie}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TMDBScreenBuilder(
      element: movie,
      content: [
        const SizedBox(
          height: 20,
        ),
        if (movie.overview?.isNotEmpty ?? false)
          MediaScreenComponent(
            title: "overview".tr(context),
            child: Text(
              movie.overview!,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        const SizedBox(
          height: 35,
        ),
        TMDBListPrimaryMediaLayout<TMDBFetchMediaCredits>(
          title: 'credits'.tr(context),
          height: 200,
        ),
        const SizedBox(
          height: 35,
        ),
        VideoTrailer(
          media: movie,
        ),
        const SizedBox(
          height: 25,
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
      ],
      header: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 15),
              child: AutoSizeText(
                movie.name,
                wrapWords: false,
                maxLines: 3,
                textAlign: TextAlign.end,
                minFontSize: 25,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 55,
                  fontWeight: FontWeight.bold,
                ),
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
                if (movie.voteAverage != null)
                  RatingWidget(
                    score: movie.voteAverage!,
                  ),
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
                FramedText(
                  text: "${movie.duration} mins",
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
          Flexible(
            flex: 2,
            child: LibraryMediaControlLayout(
              media: movie,
            ),
          ),
        ],
      ),
    );
  }
}
