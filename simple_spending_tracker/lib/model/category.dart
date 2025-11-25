class Category {
  // Property
  final int? id;
  final String icon; // asset name
  final String color; // "#RRGGBB"
  final String c_name;

  Category({
    this.id,
    required this.icon,
    required this.color,
    required this.c_name,
  });

  Category.fromMap(Map<String, dynamic> res)
    : id = res['id'],
      icon = res['icon'],
      color = res['color'],
      c_name = res['c_name'];
}
