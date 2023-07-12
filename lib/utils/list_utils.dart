extension ListExtension<T> on List<T> {
  T? find(bool Function(T item) test) {
    for (var item in this) {
      if (test(item)) return item;
    }
    return null;
  }
}
