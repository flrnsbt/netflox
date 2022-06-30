import 'dart:collection';
import 'package:netflox/data/constants/constants.dart';

abstract class TMDBElement extends MapView<String, dynamic> {
  String get id => this['id'];
  String get imgURL => kTMDBImageBaseURL + this['imgURL'];

  TMDBElement(super.map) {
    assert(containsKey('id'));
    assert(containsKey('imgURL'));
  }
}
