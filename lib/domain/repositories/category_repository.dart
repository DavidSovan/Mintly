import 'package:moneytrackerapp/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<void> addCategory(CategoryEntity category);
  Future<void> updateCategory(CategoryEntity category);
  Future<void> deleteCategory(String id);
}
