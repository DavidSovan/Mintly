import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneytrackerapp/core/providers/global_providers.dart';
import 'package:moneytrackerapp/domain/entities/category.dart';

class CategoryNotifier extends AsyncNotifier<List<CategoryEntity>> {
  @override
  Future<List<CategoryEntity>> build() async {
    return _loadCategories();
  }

  Future<List<CategoryEntity>> _loadCategories() async {
    final repository = ref.read(categoryRepositoryProvider);
    return await repository.getCategories();
  }

  Future<void> addCategory(CategoryEntity category) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(categoryRepositoryProvider);
      await repository.addCategory(category);
      final categories = await _loadCategories();
      state = AsyncValue.data(categories);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateCategory(CategoryEntity category) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(categoryRepositoryProvider);
      await repository.updateCategory(category);
      final categories = await _loadCategories();
      state = AsyncValue.data(categories);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteCategory(String id) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(categoryRepositoryProvider);
      await repository.deleteCategory(id);
      final categories = await _loadCategories();
      state = AsyncValue.data(categories);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final categoriesProvider = AsyncNotifierProvider<CategoryNotifier, List<CategoryEntity>>(() {
  return CategoryNotifier();
});
