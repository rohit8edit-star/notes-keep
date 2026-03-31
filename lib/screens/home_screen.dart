import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../models/category.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/note_card.dart';
import '../widgets/category_chip.dart';
import 'editor_screen.dart';
import 'categories_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseService.instance;
  final _searchController = TextEditingController();

  List<Note> _notes = [];
  List<Category> _categories = [];
  String? _selectedCategoryId; // null = All
  bool _isSearching = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final notes = _searchController.text.isEmpty
        ? await _db.getAllNotes(categoryId: _selectedCategoryId)
        : await _db.searchNotes(_searchController.text);
    final categories = await _db.getAllCategories();
    setState(() {
      _notes = notes;
      _categories = categories;
      _isLoading = false;
    });
  }

  Future<void> _onSearch(String query) async {
    if (query.isEmpty) {
      await _loadData();
      return;
    }
    final results = await _db.searchNotes(query);
    setState(() => _notes = results);
  }

  Future<void> _deleteNote(Note note) async {
    await _db.deleteNote(note.id);
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Note deleted'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );
    }
  }

  Future<void> _togglePin(Note note) async {
    await _db.togglePin(note.id, !note.isPinned);
    _loadData();
  }

  void _openEditor({Note? note}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditorScreen(
          note: note,
          categoryId: _selectedCategoryId,
          categories: _categories,
        ),
      ),
    );
    _loadData();
  }

  List<Note> get _pinnedNotes => _notes.where((n) => n.isPinned).toList();
  List<Note> get _otherNotes => _notes.where((n) => !n.isPinned).toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Logo + Title
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.primaryBlue,
                            AppTheme.primaryBlueLight
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.note_alt_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Notes Keep',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontSize: 22),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.folder_outlined,
                          color: scheme.primary),
                      tooltip: 'Categories',
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CategoriesScreen()),
                        );
                        _loadData();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── Search Bar ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  onTap: () => setState(() => _isSearching = true),
                  decoration: InputDecoration(
                    hintText: 'Search notes...',
                    hintStyle:
                        TextStyle(color: scheme.onSurface.withOpacity(0.4)),
                    prefixIcon:
                        Icon(Icons.search_rounded, color: scheme.primary),
                    suffixIcon: _isSearching && _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _isSearching = false);
                              _loadData();
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),

            // ── Category Chips ────────────────────────────
            if (_categories.isNotEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 48,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    scrollDirection: Axis.horizontal,
                    children: [
                      CategoryChip(
                        label: 'All',
                        isSelected: _selectedCategoryId == null,
                        onTap: () {
                          setState(() => _selectedCategoryId = null);
                          _loadData();
                        },
                      ),
                      const SizedBox(width: 8),
                      ..._categories.map((cat) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CategoryChip(
                              label: cat.name,
                              isSelected: _selectedCategoryId == cat.id,
                              colorIndex: cat.colorIndex,
                              onTap: () {
                                setState(
                                    () => _selectedCategoryId = cat.id);
                                _loadData();
                              },
                            ),
                          )),
                    ],
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // ── Notes List ────────────────────────────────
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_notes.isEmpty)
              SliverFillRemaining(
                child: _EmptyState(onAdd: () => _openEditor()),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Pinned section
                    if (_pinnedNotes.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, top: 4),
                        child: Row(
                          children: [
                            Icon(Icons.push_pin_rounded,
                                size: 14,
                                color: scheme.primary),
                            const SizedBox(width: 4),
                            Text('PINNED',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: scheme.primary,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    )),
                          ],
                        ),
                      ),
                      MasonryGridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _pinnedNotes.length,
                        itemBuilder: (ctx, i) => NoteCard(
                          note: _pinnedNotes[i],
                          categories: _categories,
                          onTap: () => _openEditor(note: _pinnedNotes[i]),
                          onDelete: () => _deleteNote(_pinnedNotes[i]),
                          onTogglePin: () => _togglePin(_pinnedNotes[i]),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Other notes
                    if (_otherNotes.isNotEmpty) ...[
                      if (_pinnedNotes.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('OTHERS',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  )),
                        ),
                      MasonryGridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _otherNotes.length,
                        itemBuilder: (ctx, i) => NoteCard(
                          note: _otherNotes[i],
                          categories: _categories,
                          onTap: () => _openEditor(note: _otherNotes[i]),
                          onDelete: () => _deleteNote(_otherNotes[i]),
                          onTogglePin: () => _togglePin(_otherNotes[i]),
                        ),
                      ),
                    ],

                    const SizedBox(height: 100), // FAB space
                  ]),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        tooltip: 'New Note',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.note_alt_outlined,
              size: 72, color: scheme.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No notes yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onSurface.withOpacity(0.4),
                  )),
          const SizedBox(height: 8),
          Text('Tap + to create your first note',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Note'),
          ),
        ],
      ),
    );
  }
}
