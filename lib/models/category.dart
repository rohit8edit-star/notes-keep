class Category {
  final String id;
  String name;
  int colorIndex;
  int iconIndex;
  DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    this.colorIndex = 0,
    this.iconIndex = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorIndex': colorIndex,
      'iconIndex': iconIndex,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      colorIndex: map['colorIndex'] ?? 0,
      iconIndex: map['iconIndex'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
