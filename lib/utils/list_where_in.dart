extension WhereInListExtension on List {
  bool whereIn(List elements) {
    return elements.every((item) => contains(item));
  }
}
