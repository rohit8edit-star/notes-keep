import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';
import '../models/category.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes_keep.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        colorIndex INTEGER DEFAULT 0,
        iconIndex INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        contentPlain TEXT DEFAULT '',
        categoryId TEXT,
        isPinned INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        colorIndex INTEGER DEFAULT 0,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');
  }

  // ─── NOTES ───────────────────────────────────────────────

  Future<List<Note>> getAllNotes({String? categoryId}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;

    if (categoryId != null) {
      maps = await db.query(
        'notes',
        where: 'categoryId = ?',
        whereArgs: [categoryId],
        orderBy: 'isPinned DESC, updatedAt DESC',
      );
    } else {
      maps = await db.query(
        'notes',
        orderBy: 'isPinned DESC, updatedAt DESC',
      );
    }

    return maps.map((m) => Note.fromMap(m)).toList();
  }

  Future<List<Note>> searchNotes(String query) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'title LIKE ? OR contentPlain LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return maps.map((m) => Note.fromMap(m)).toList();
  }

  Future<Note?> getNoteById(String id) async {
    final db = await database;
    final maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Note.fromMap(maps.first);
  }

  Future<void> insertNote(Note note) async {
    final db = await database;
    await db.insert('notes', note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateNote(Note note) async {
    final db = await database;
    await db.update('notes', note.toMap(),
        where: 'id = ?', whereArgs: [note.id]);
  }

  Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> togglePin(String id, bool isPinned) async {
    final db = await database;
    await db.update(
      'notes',
      {'isPinned': isPinned ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── CATEGORIES ─────────────────────────────────────────

  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final maps =
        await db.query('categories', orderBy: 'createdAt ASC');
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  Future<void> insertCategory(Category category) async {
    final db = await database;
    await db.insert('categories', category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateCategory(Category category) async {
    final db = await database;
    await db.update('categories', category.toMap(),
        where: 'id = ?', whereArgs: [category.id]);
  }

  Future<void> deleteCategory(String id) async {
    final db = await database;
    // Unassign notes from this category
    await db.update('notes', {'categoryId': null},
        where: 'categoryId = ?', whereArgs: [id]);
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getNoteCountForCategory(String categoryId) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM notes WHERE categoryId = ?',
        [categoryId]);
    return result.first['count'] as int? ?? 0;
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
