class AppCategory {
  final String name;

  const AppCategory({required this.name});

  factory AppCategory.fromJson(dynamic json) {
    return AppCategory(name: json?.toString() ?? '');
  }
}
