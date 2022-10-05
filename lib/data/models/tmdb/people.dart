import 'package:netflox/data/models/tmdb/media.dart';
import 'package:netflox/data/models/tmdb/img.dart';
import 'package:netflox/data/models/tmdb/type.dart';

enum Gender {
  undefined(-1),
  male(2),
  female(1);

  final int id;
  const Gender(this.id);
  static Gender? fromId(int id) {
    final gender = Gender.values
        .firstWhere((e) => e.id == id, orElse: () => Gender.undefined);
    if (gender != Gender.undefined) {
      return gender;
    }
    return null;
  }
}

enum Profession {
  actor("Acting"),
  director("Directing"),
  producer("Production"),
  undefined("");

  final String id;
  const Profession(this.id);
  static Profession? fromId(String id) {
    final profession = Profession.values
        .firstWhere((e) => e.id == id, orElse: () => Profession.undefined);
    if (profession != Profession.undefined) {
      return profession;
    }
    return null;
  }
}

class TMDBPerson extends TMDBPrimaryMedia {
  @override
  final String name;
  @override
  final String? overview;
  final String? birthday;
  final String? placeOfBirth;
  final Gender? gender;
  final Profession? profession;
  @override
  final TMDBImg? img;

  TMDBPerson(super.id,
      {this.img,
      required this.name,
      this.overview,
      this.gender,
      this.placeOfBirth,
      this.birthday,
      this.profession,
      this.popularity});

  static TMDBPerson fromJson(Map<String, dynamic> map) {
    TMDBImg? img;
    String? profilePath = map['profile_path'];
    if (profilePath != null) {
      img = TMDBImg(profilePath, TMDBImageType.profile);
    }
    return TMDBPerson(map['id'].toString(),
        img: img,
        name: map['name'],
        profession: Profession.fromId(map['known_for_department']),
        birthday: map['birthday'],
        gender: Gender.fromId(map['gender']),
        placeOfBirth: map['place_of_birth'],
        overview: map['biography'],
        popularity: map['popularity']);
  }

  @override
  TMDBType<TMDBPerson> get type => TMDBType.person;

  @override
  String? get date => birthday;

  @override
  String? get placeOfOrigin =>
      placeOfBirth?.split(",").last.replaceAll(" ", "").toLowerCase();

  @override
  String toString() {
    return 'TMDBPerson(name: $name, biography: $overview, birthday: $birthday, placeOfBirth: $placeOfBirth, gender: $gender, profession: $profession)';
  }

  @override
  String get originalName => name;

  @override
  final num? popularity;
}
