class Note {
  final String id;
  String title;
  String content; // JSON string for rich text (Quill Delta)
  String contentPlain; // Plain text for search
  String? categoryId;
  bool isPinned;
  DateTime createdAt;
  DateTime updatedAt;
  int colorIndex;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.contentPlain,
    this.categoryId,
    this.isPinned = false,
    required this.createdAt,
    required this.updatedAt,
    this.colorIndex = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'contentPlain': contentPlain,
      'categoryId': categoryId,
      'isPinned': isPinned ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'colorIndex': colorIndex,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      contentPlain: map['contentPlain'] ?? '',
      categoryId: map['categoryId'],
      isPinned: map['isPinned'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      colorIndex: map['colorIndex'] ?? 0,
    );
  }

  Note copyWith({
    String? title,
    String? content,
    String? contentPlain,
    String? categoryId,
    bool? isPinned,
    DateTime? updatedAt,
    int? colorIndex,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      contentPlain: contentPlain ?? this.contentPlain,
      categoryId: categoryId ?? this.categoryId,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }
}
