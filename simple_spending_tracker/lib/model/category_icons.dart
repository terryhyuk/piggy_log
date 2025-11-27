import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Predefined list of icons that users can select for a category.
class CategoryIcons {
  static final List<Map<String, dynamic>> icons = [

    // ─────────────────────────
    // Food
    // ─────────────────────────
    {
      'name': 'Food',
      'icon': Icons.fastfood,
    },
    {
      'name': 'Restaurant',
      'icon': CupertinoIcons.house_fill,
    },

    // ─────────────────────────
    // Shopping
    // ─────────────────────────
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag_outlined,
    },
    {
      'name': 'Cart',
      'icon': CupertinoIcons.cart,
    },

    // ─────────────────────────
    // Transportation
    // ─────────────────────────
    {
      'name': 'Car',
      'icon': CupertinoIcons.car_detailed,
    },
    {
      'name': 'Transit',
      'icon': Icons.train_outlined,
    },

    // ─────────────────────────
    // Bills / Home
    // ─────────────────────────
    {
      'name': 'Home',
      'icon': Icons.home_outlined,
    },
    {
      'name': 'Utilities',
      'icon': CupertinoIcons.house_fill,
    },

    // ─────────────────────────
    // Fitness
    // ─────────────────────────
    {
      'name': 'Health',
      'icon': Icons.favorite_border,
    },
    {
      'name': 'Workout',
      'icon': CupertinoIcons.heart_fill,
    },

    // ─────────────────────────
    // General / Misc
    // ─────────────────────────
    {
      'name': 'Star',
      'icon': Icons.star_border,
    },
    {
      'name': 'Tag',
      'icon': CupertinoIcons.tag,
    },
  ];

  /// Converts an IconData object into the map format needed for Category().
  static Map<String, dynamic> iconToDB(IconData icon, String name) {
    return {
      'name': name,
      'icon_codepoint': icon.codePoint,
      'icon_font_family': icon.fontFamily,
      'icon_font_package': icon.fontPackage,
    };
  }
}
