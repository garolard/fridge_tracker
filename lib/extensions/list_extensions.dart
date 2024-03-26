extension ListExtensions on List {
  List<T> sorted<T, U extends Comparable>(U Function(T) by) {
    return cast<T>().toList()
      ..sort((a, b) {
        return by(a).compareTo(by(b));
      });
  }
}
