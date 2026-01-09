import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:piggy_log/core/database/repository/category_repository.dart';
import 'package:piggy_log/data/models/category_model.dart';
import 'package:piggy_log/providers/settings_provider.dart';
import 'package:piggy_log/providers/dashboard_provider.dart';
import 'package:piggy_log/providers/calendar_provider.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryRepository _repository;
  
  List<CategoryModel> _categories = [];
  bool _isEditMode = false;

  CategoryProvider(this._repository);

  // --- [Getters] ---
  List<CategoryModel> get categories => _categories;
  bool get isEditMode => _isEditMode;

  // --- [UI State Management] ---
  void toggleEditMode() {
    _isEditMode = !_isEditMode;
    notifyListeners();
  }

  void setEditModeFalse() {
    if (_isEditMode) {
      _isEditMode = false;
      notifyListeners();
    }
  }

  // --- [Data Operations] ---

  /// Fetches all categories from the repository
  Future<void> fetchCategories() async {
    _categories = await _repository.getAllCategories();
    notifyListeners();
  }

  /// Adds a new category and refreshes the list
  Future<void> addCategory(CategoryModel category) async {
    await _repository.insertCategory(category);
    await fetchCategories();
  }

  /// Updates an existing category
  Future<void> updateCategory(CategoryModel category) async {
    if (category.id != null) {
      await _repository.updateCategory(category);
      await fetchCategories();
    }
  }

  /// Deletes a category and triggers a global refresh for other providers
  Future<void> deleteCategory(BuildContext context, int id) async {
    // 1. Physical delete from DB (Cascade delete for related records is handled in Repository)
    await _repository.deleteCategory(id);
    await fetchCategories();

    // 2. Global Refresh: Ensure other screens reflect the changes immediately
    if (context.mounted) {
      final settings = context.read<SettingProvider>();
      final dash = context.read<DashboardProvider>();
      final cal = context.read<CalendarProvider>();

      // Re-sync all related data layers
      await settings.refreshAllData(
        dashboardProvider: dash,
        calendarProvider: cal,
      );
    }
  }
  

}