import 'package:netflox/data/models/tmdb/element.dart';

class TMDBPeople extends TMDBElement {
  String get name => this['name'];
  String? get biography => this['biography'];

  TMDBPeople(super.map) {
    assert(containsKey('name'));
    // assert(containsKey('biography'));
  }
}
