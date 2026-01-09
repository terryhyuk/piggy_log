class CategoryModel {
  final int? id;                  
  final String name;              
  final int iconCodePoint;        // [DB: INTEGER] Icon numeric code
  final String? iconFontFamily;   // [DB: TEXT] Optional font family (e.g., FontAwesome)
  final String? iconFontPackage;  // [DB: TEXT] Optional font package
  final String color;             // [DB: TEXT] Hex string like '0xFFFF6B6B'

  CategoryModel({
    this.id,
    required this.name,
    required this.iconCodePoint,
    this.iconFontFamily,
    this.iconFontPackage,
    required this.color,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      iconCodePoint: map['icon_codepoint'],
      iconFontFamily: map['icon_font_family'],
      iconFontPackage: map['icon_font_package'],
      color: map['color'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_codepoint': iconCodePoint,
      'icon_font_family': iconFontFamily,
      'icon_font_package': iconFontPackage,
      'color': color,
    };
  }
}