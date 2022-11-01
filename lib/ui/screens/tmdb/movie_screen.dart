part of 'media_screen.dart';

class TMDBMovieScreen extends TMDBMediaScreenWrapper<TMDBMovie>
    with TMDBPrimaryScreenWrapper<TMDBMovie> {
  const TMDBMovieScreen({Key? key, @PathParam('id') required this.id})
      : super(key: key);

  @override
  final String id;

  @override
  Widget buildLayout(BuildContext context, TMDBMovie media) {
    return TMDBScreenBuilder(
        element: media,
        content: [
          TMDBInfoComponent(
            media: media,
          ),
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
}
