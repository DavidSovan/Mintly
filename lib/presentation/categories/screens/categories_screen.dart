import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moneytrackerapp/presentation/categories/providers/category_provider.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Categories', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: categoriesState.when(
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No categories found.',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Color(cat.colorValue).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons'),
                        color: Color(cat.colorValue),
                        size: 26,
                      ),
                    ),
                    title: Text(
                      cat.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: cat.type.name == 'expense' 
                                  ? Colors.red.withValues(alpha: 0.1) 
                                  : Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              cat.type.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: cat.type.name == 'expense' ? Colors.red.shade700 : Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          onPressed: () {
                            context.push('/edit-category', extra: cat);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red.shade400,
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: const Text('Delete Category'),
                                content: Text('Are you sure you want to delete "${cat.name}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.red.shade400,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              ref.read(categoriesProvider.notifier).deleteCategory(cat.id);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/add-category');
        },
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add),
        label: const Text('Add Category', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
