import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../models/category.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class EditorScreen extends StatefulWidget {
  final Note? note;
  final String? categoryId;
  final List<Category> categories;

  const EditorScreen({
    super.key,
    this.note,
    this.categoryId,
    required this.categories,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late QuillController _quillController;
  late TextEditingController _titleController;
  final _db = DatabaseService.instance;
  final _uuid = const Uuid();

  String? _selectedCategoryId;
  int _colorIndex = 0;
  bool _hasChanges = false;
  late DateTime _createdAt;

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    _titleController = TextEditingController(text: note?.title ?? '');
    _selectedCategoryId = note?.categoryId ?? widget.categoryId;
    _colorIndex = note?.colorIndex ?? 0;
    _createdAt = note?.createdAt ?? DateTime.now();

    if (note != null && note.content.isNotEmpty) {
      try {
        final doc =
            Document.fromJson(jsonDecode(note.content) as List<dynamic>);
        _quillController = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (_) {
        _quillController = QuillController.basic();
      }
    } else {
      _quillController = QuillController.basic();
    }

    _titleController.addListener(() => setState(() => _hasChanges = true));
    _quillController.addListener(() => setState(() => _hasChanges = true));
  }

  @override
  void dispose() {
    _quillController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final contentJson =
        jsonEncode(_quillController.document.toDelta().toJson());
    final contentPlain = _quillController.document.toPlainText().trim();

    if (title.isEmpty && contentPlain.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final now = DateTime.now();

    if (widget.note == null) {
      final note = Note(
        id: _uuid.v4(),
        title: title.isEmpty ? 'Untitled' : title,
        content: contentJson,
        contentPlain: contentPlain,
        categoryId: _selectedCategoryId,
        colorIndex: _colorIndex,
        createdAt: now,
        updatedAt: now,
      );
      await _db.insertNote(note);
    } else {
      final updated = widget.note!.copyWith(
        title: title.isEmpty ? 'Untitled' : title,
        content: contentJson,
        contentPlain: contentPlain,
        categoryId: _selectedCategoryId,
        colorIndex: _colorIndex,
        updatedAt: now,
      );
      await _db.updateNote(updated);
    }

    if (mounted) Navigator.pop(context);
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Note color',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                AppTheme.noteColorsLight.length,
                (i) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  final color = isDark
                      ? AppTheme.noteColorsDark[i]
                      : AppTheme.noteColorsLight[i];
                  return GestureDetector(
                    onTap: () {
                      setState(() => _colorIndex = i);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _colorIndex == i
                              ? AppTheme.primaryBlue
                              : Colors.grey.withOpacity(0.3),
                          width: _colorIndex == i ? 3 : 1,
                        ),
                      ),
                      child: _colorIndex == i
                          ? const Icon(Icons.check_rounded, size: 20)
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Move to category',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.all_inbox_rounded),
              title: const Text('No category'),
              selected: _selectedCategoryId == null,
              onTap: () {
                setState(() => _selectedCategoryId = null);
                Navigator.pop(ctx);
              },
            ),
            ...widget.categories.map((cat) => ListTile(
                  leading: const Icon(Icons.folder_rounded),
                  title: Text(cat.name),
                  selected: _selectedCategoryId == cat.id,
                  onTap: () {
                    setState(() => _selectedCategoryId = cat.id);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }

  Color get _bgColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? AppTheme.noteColorsDark[_colorIndex]
        : AppTheme.noteColorsLight[_colorIndex];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () async {
            if (_hasChanges) await _save();
            else if (mounted) Navigator.pop(context);
          },
        ),
        actions: [
          // Category
          IconButton(
            icon: const Icon(Icons.folder_outlined),
            tooltip: 'Category',
            onPressed: widget.categories.isEmpty ? null : _showCategoryPicker,
          ),
          // Color
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            tooltip: 'Color',
            onPressed: _showColorPicker,
          ),
          // Save
          TextButton(
            onPressed: _save,
            child: Text(
              'Save',
              style: TextStyle(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _titleController,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0D1B2E),
              ),
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.symmetric(horizontal: 4),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),

          // Date
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                DateFormat('MMM d, yyyy • h:mm a').format(_createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),

          // Toolbar
          Container(
            decoration: BoxDecoration(
              color: _bgColor,
              border: Border(
                top: BorderSide(
                    color: scheme.outline.withOpacity(0.1)),
                bottom: BorderSide(
                    color: scheme.outline.withOpacity(0.1)),
              ),
            ),
            child: QuillSimpleToolbar(
              controller: _quillController,
              config: QuillSimpleToolbarConfig(
                showBoldButton: true,
                showItalicButton: true,
                showUnderLineButton: true,
                showStrikeThrough: false,
                showListBullets: true,
                showListNumbers: true,
                showListCheck: true,
                showHeaderStyle: true,
                showColorButton: false,
                showBackgroundColorButton: false,
                showClearFormat: true,
                showAlignmentButtons: false,
                showIndent: false,
                showLink: false,
                showSearchButton: false,
                showSubscript: false,
                showSuperscript: false,
                showCodeBlock: false,
                showInlineCode: false,
                showQuote: false,
                showSmallButton: false,
                showFontFamily: false,
                showFontSize: false,
                toolbarSize: 44,
                multiRowsDisplay: false,
                color: isDark ? Colors.white70 : Colors.black87,
                iconTheme: QuillIconTheme(
                  iconButtonSelectedData: IconButtonData(
                    color: scheme.primary,
                  ),
                ),
              ),
            ),
          ),

          // Editor
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: QuillEditor.basic(
                controller: _quillController,
                config: QuillEditorConfig(
                  placeholder: 'Start writing...',
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  autoFocus: widget.note == null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
