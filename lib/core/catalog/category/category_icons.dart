import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryIcons {
  static final List<Map<String, dynamic>> icons = [
    // ────────────── Food & Drink ──────────────
    {
      'name': 'Food', 
      'icon': Icons.fastfood
      }, 
    {
      'name': 'Food', 
      'icon': FontAwesomeIcons.utensils
      },
    {
      'name': 'Coffee', 
      'icon': Icons.local_cafe_outlined
      },
    {
      'name': 'Coffee', 
      'icon': FontAwesomeIcons.mugHot
      },
    {
      'name': 'Pizza', 
      'icon': FontAwesomeIcons.pizzaSlice
      },

    // ────────────── Shopping ──────────────
    {
      'name': 'Shopping', 
      'icon': Icons.shopping_cart_outlined
      },
    {
      'name': 'Shopping', 
      'icon': FontAwesomeIcons.bagShopping
      },
    {
      'name': 'Clothes', 
      'icon': Icons.checkroom_outlined
      },
    {
      'name': 'Beauty', 
      'icon': Icons.face_retouching_natural_outlined
      },

      // ────────────── Beauty & Personal Care ──────────────
    {
      'name': 'Cosmetic',
      'icon': Icons.brush_outlined,
    },
    {
      'name': 'Beauty',
      'icon': Icons.face_retouching_natural_outlined    
      },
    {
      'name': 'Spa',
      'icon': Icons.spa_outlined,
    },

    // ────────────── Adult / Nightlife ──────────────
    {
      'name': 'Liquor',
      'icon': Icons.local_bar, 
    },
    {
      'name': 'Beer',
      'icon': FontAwesomeIcons.beerMugEmpty,
    },
    {
      'name': 'Smoking',
      'icon': Icons.smoking_rooms,
    },
    {
      'name': 'Wine',
      'icon': FontAwesomeIcons.wineGlass,
    },

    // ────────────── Transportation ──────────────
    {
      'name': 'Car', 
      'icon': Icons.directions_car_filled_outlined
      },
    {
      'name': 'Bus', 
      'icon': Icons.directions_bus_filled_outlined
      },
    {
      'name': 'Taxi', 
      'icon': Icons.local_taxi_outlined
      },
    {
      'name': 'Transit', 
      'icon': Icons.train_outlined
      },
    {
      'name': 'Plane', 
      'icon': Icons.flight_takeoff_outlined
      },

    // ────────────── Bills / Home ──────────────
    {
      'name': 'Home', 
      'icon': Icons.home_outlined
      },
    {
      'name': 'Utilities', 
      'icon': Icons.lightbulb_outline
      },
    {
      'name': 'Phone', 
      'icon': Icons.phone_android_outlined
      },
    {
      'name': 'Internet', 
      'icon': Icons.wifi
      },

    // ────────────── Fitness / Health ──────────────
    {
      'name': 'Health', 
      'icon': Icons.favorite_border
      },
    {
      'name': 'Workout', 
      'icon': Icons.fitness_center_outlined
      },
    {
      'name': 'Medicine', 
      'icon': FontAwesomeIcons.pills
      },

    // ────────────── Money / Income ──────────────
    {
      'name': 'Cash', 
      'icon': Icons.payments_outlined
      },
    {
      'name': 'Bank', 
      'icon': Icons.account_balance_outlined
      },
    {
      'name': 'Savings', 
      'icon': Icons.savings_outlined
      },

    // ────────────── Entertainment ──────────────
    {
      'name': 'Movie', 
      'icon': Icons.movie_outlined
      },
    {
      'name': 'Game', 
      'icon': Icons.videogame_asset_outlined
      },
    {
      'name': 'Music', 
      'icon': Icons.music_note_outlined
      },

    // ────────────── Others / Misc ──────────────
    {
      'name': 'Gift', 
      'icon': Icons.card_giftcard_outlined
      },
    {
      'name': 'Book', 
      'icon': Icons.menu_book_outlined
      },
    {
      'name': 'Pets', 
      'icon': Icons.pets_outlined
      },
    {
      'name': 'Travel', 
      'icon': Icons.beach_access_outlined
      },
    {
      'name': 'Star', 
      'icon': Icons.star_border
      },
    {
      'name': 'Tag', 
      'icon': Icons.local_offer_outlined
      },
  ];


  /// Converts an IconData object into the map format needed for Category().
  static Map<String, dynamic> iconToDB(IconData icon, String name) {
    return {
      'name': name,
      'icon_codepoint': icon.codePoint,      // INTEGER 
      'icon_font_family': icon.fontFamily,   // TEXT (Nullable)
      'icon_font_package': icon.fontPackage, // TEXT (Nullable)
    };
  }
}
