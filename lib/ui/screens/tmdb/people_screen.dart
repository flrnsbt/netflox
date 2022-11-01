part of 'media_screen.dart';

class TMDBPeopleScreen extends TMDBMediaScreenWrapper<TMDBPerson>
    with TMDBPrimaryScreenWrapper {
  const TMDBPeopleScreen({Key? key, @PathParam('id') required this.id})
      : super(key: key);

  @override
  final String id;

  @override
  Widget buildLayout(BuildContext context, TMDBPerson media) {
    return TMDBScreenBuilder(
      element: media,
      content: [
        const SizedBox(
          height: 20,
        ),
        OverviewComponent(
          overview: media.overview,
        ),
        const PersonCastingGridLayout()
      ],
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: AutoSizeText(
              media.name,
              maxLines: 3,
              wrapWords: false,
              minFontSize: 25,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 55,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          if (media.placeOfBirth != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                media.placeOfBirth!,
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          if (media.birthday != null)
            Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  media.birthday!,
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, fontSize: 11),
                )),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (media.popularityLevel != null)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FramedText(
                    text: media.popularityLevel!.tr(context).toUpperCase(),
                    style: const TextStyle(fontSize: 12),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              if (media.profession != null)
                FramedText(
                  text: media.profession!.tr(context).toUpperCase(),
                  style: const TextStyle(fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
