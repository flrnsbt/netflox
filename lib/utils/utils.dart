double normalized(num val, num max, num min) {
  return (val - min) / (max - min);
}

extension NormalizedDouble on double {
  double normalize(num max, num min) {
    return normalized(this, max, min);
  }
}
