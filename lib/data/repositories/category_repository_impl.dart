import 'package:moneytrackerapp/domain/entities/category.dart';
import 'package:moneytrackerapp/domain/repositories/category_repository.dart';
import 'package:moneytrackerapp/data/models/category_model.dart';
import 'package:moneytrackerapp/data/datasources/database_helper.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final DatabaseHelper dbHelper;

  CategoryRepositoryImpl(this.dbHelper);

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final db = await dbHelper.database;
    final result = await db.query('categories', orderBy: 'name ASC');
    return result.map((json) => CategoryModel.fromJson(json)).toList();
  }

  @override
  Future<void> addCategory(CategoryEntity category) async {
    final db = await dbHelper.database;
    final model = CategoryModel.fromEntity(category);
    await db.insert('categories', model.toJson());
  }

  @override
  Future<void> updateCategory(CategoryEntity category) async {
    final db = await dbHelper.database;
    final model = CategoryModel.fromEntity(category);
    await db.update(
      'categories',
      model.toJson(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    final db = await dbHelper.database;
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
