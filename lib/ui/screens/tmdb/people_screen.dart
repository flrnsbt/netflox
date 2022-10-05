part of 'media_screen.dart';

class TMDBPeopleScreen extends StatelessWidget {
  final TMDBPerson people;
  const TMDBPeopleScreen({Key? key, required this.people}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TMDBScreenBuilder(
      element: people,
      content: [
        const SizedBox(
          height: 20,
        ),
        if (people.overview?.isNotEmpty ?? false)
          MediaScreenComponent(
              title: "overview".tr(context),
              child: Text(
                people.overview!,
                style: const TextStyle(
                  fontSize: 12,
                ),
              )),
        const SizedBox(
          height: 35,
        ),
        const PersonCastingGridLayout()
      ],
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: AutoSizeText(
              people.name,
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
          if (people.placeOfBirth != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                people.placeOfBirth!,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          if (people.birthday != null)
            Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  people.birthday!,
                  style: const TextStyle(
                      fontStyle: FontStyle.italic, fontSize: 12),
                )),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (people.popularityLevel != null)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FramedText(
                    text: people.popularityLevel!.tr(context).toUpperCase(),
                    style: const TextStyle(fontSize: 12),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              if (people.profession != null)
                FramedText(
                  text: people.profession!.tr(context).toUpperCase(),
                  style: const TextStyle(fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
