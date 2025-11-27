// Category Model
// Represents a user-defined category in the app.

class Category {
  /// Auto-incremented ID from the database.
  /// Null when the category is newly created (before saving).
  final int? id;

  /// Icon data stored using codePoint + fontFamily + package.
  final int iconCodePoint;
  final String? iconFontFamily;
  final String? iconFontPackage;

  /// Category color stored as HEX.
  final String color;

  /// Category display name.
  final String c_name;

  /// Constructor for creating or loading a category.
  Category({
    this.id,
    required this.iconCodePoint,
    required this.iconFontFamily,
    required this.iconFontPackage,
    required this.color,
    required this.c_name,
  });

  /// Factory constructor for converting a DB row into a Category object.
  Category.fromMap(Map<String, dynamic> res)
      : id = res['id'],
        iconCodePoint = res['icon_codepoint'],
        iconFontFamily = res['icon_font_family'],
        iconFontPackage = res['icon_font_package'],
        color = res['color'],
        c_name = res['c_name'];
}
