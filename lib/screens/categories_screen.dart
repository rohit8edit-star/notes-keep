import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _db = DatabaseService.instance;
  final _uuid = const Uuid();
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cats = await _db.getAllCategories();
    setState(() => _categories = cats);
  }

  Future<void> _showCategoryDialog({Category? category}) async {
    final controller =
        TextEditingController(text: category?.name ?? '');
    int selectedColor = category?.colorIndex ?? 0;

    final colors = [
      AppTheme.primaryBlue,
      const Color(0xFF26C6DA),
      const Color(0xFF66BB6A),
      const Color(0xFFFFCA28),
      const Color(0xFFEF5350),
      const Color(0xFFAB47BC),
      const Color(0xFFFF7043),
    ];

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(category == null ? 'New Category' : 'Edit Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Category name',
                  prefixIcon: Icon(Icons.folder_outlined),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Color',
                    style: Theme.of(context).textTheme.bodySmall),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: List.generate(colors.length, (i) {
                  return GestureDetector(
                    onTap: () => setLocal(() => selectedColor = i),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colors[i],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor == i
                              ? Colors.white
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: selectedColor == i
                            ? [
                                BoxShadow(
                                  color: colors[i].withOpacity(0.5),
                                  blurRadius: 8,
                                )
                              ]
                            : null,
                      ),
                      child: selectedColor == i
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;
                if (category == null) {
                  final cat = Category(
                    id: _uuid.v4(),
                    name: name,
                    colorIndex: selectedColor,
                    createdAt: DateTime.now(),
                  );
                  await _db.insertCategory(cat);
                } else {
                  final updated = Category(
                    id: category.id,
                    name: name,
                    colorIndex: selectedColor,
                    iconIndex: category.iconIndex,
                    createdAt: category.createdAt,
                  );
                  await _db.updateCategory(updated);
                }
                if (ctx.mounted) Navigator.pop(ctx);
                _load();
              },
              child: Text(category == null ? 'Create' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCategory(Category cat) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete category?'),
        content: Text(
            '"${cat.name}" will be deleted. Notes inside will remain but won\'t have a category.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _db.deleteCategory(cat.id);
      _load();
    }
  }

  final _categoryColors = [
    AppTheme.primaryBlue,
    const Color(0xFF26C6DA),
    const Color(0xFF66BB6A),
    const Color(0xFFFFCA28),
    const Color(0xFFEF5350),
    const Color(0xFFAB47BC),
    const Color(0xFFFF7043),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: _categories.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.folder_outlined,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.3)),
                  const SizedBox(height: 12),
                  Text('No categories yet',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.4))),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final cat = _categories[i];
                final color =
                    _categoryColors[cat.colorIndex % _categoryColors.length];
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.folder_rounded, color: color),
                    ),
                    title: Text(cat.name,
                        style: Theme.of(context).textTheme.titleMedium),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () =>
                              _showCategoryDialog(category: cat),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 20, color: Colors.red),
                          onPressed: () => _deleteCategory(cat),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        tooltip: 'New Category',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
