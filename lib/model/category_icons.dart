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
  /// IconData 객체를 Category()에 필요한 map 형식으로 변환
  static Map<String, dynamic> iconToDB(IconData icon, String name) {
    return {
      'name': name,
      'icon_codepoint': icon.codePoint,
      'icon_font_family': icon.fontFamily,
      'icon_font_package': icon.fontPackage,
    };
  }
}
/// Predefined list of icons that users can select for a category.
// class CategoryIcons {
//   static final List<Map<String, dynamic>> icons = [
//     // ────────────── Food ──────────────
//     {
//       'name': 'Food',
//       'icon': Icons.fastfood, // Material
//     },
//     {
//       'name': 'Food',
//       'icon': CupertinoIcons.cart, // Cupertino
//     },
//     {
//       'name': 'Food',
//       'icon': FontAwesomeIcons.utensils, // FontAwesome
//     },
//     {
//       'name': 'Coffee',
//       'icon': Icons.local_cafe_outlined,
//     },
//     {
//       'name': 'Coffee',
//       'icon': FontAwesomeIcons.mugSaucer,
//     },
//     {
//       'name': 'Restaurant',
//       'icon': Icons.restaurant_outlined,
//     },
//     {
//       'name': 'Restaurant',
//       'icon': CupertinoIcons.house_fill,
//     },
//     {
//       'name': 'Restaurant',
//       'icon': FontAwesomeIcons.utensils,
//     },

//     // ────────────── Shopping ──────────────
//     {
//       'name': 'Shopping',
//       'icon': Icons.shopping_bag_outlined,
//     },
//     {
//       'name': 'Shopping',
//       'icon': CupertinoIcons.cart,
//     },
//     {
//       'name': 'Shopping',
//       'icon': FontAwesomeIcons.bagShopping,
//     },
//     {
//       'name': 'Clothes',
//       'icon': Icons.checkroom_outlined,
//     },
//     {
//       'name': 'Clothes',
//       'icon': FontAwesomeIcons.shirtsinbulk,
//     },
//     {
//       'name': 'Beauty',
//       'icon': Icons.face_retouching_natural_outlined,
//     },
//     {
//       'name': 'Beauty',
//       'icon': FontAwesomeIcons.spa,
//     },

//     // ────────────── Transportation ──────────────
//     {
//       'name': 'Car',
//       'icon': CupertinoIcons.car_detailed,
//     },
//     {
//       'name': 'Car',
//       'icon': Icons.directions_car,
//     },
//     {
//       'name': 'Car',
//       'icon': FontAwesomeIcons.car,
//     },
//     {
//       'name': 'Bus',
//       'icon': Icons.directions_bus_outlined,
//     },
//     {
//       'name': 'Bus',
//       'icon': FontAwesomeIcons.bus,
//     },
//     {
//       'name': 'Taxi',
//       'icon': Icons.local_taxi_outlined,
//     },
//     {
//       'name': 'Transit',
//       'icon': Icons.train_outlined,
//     },
//     {
//       'name': 'Plane',
//       'icon': FontAwesomeIcons.plane,
//     },

//     // ────────────── Bills / Home ──────────────
//     {
//       'name': 'Home',
//       'icon': Icons.home_outlined,
//     },
//     {
//       'name': 'Home',
//       'icon': CupertinoIcons.house_fill,
//     },
//     {
//       'name': 'Utilities',
//       'icon': Icons.power_outlined,
//     },
//     {
//       'name': 'Utilities',
//       'icon': FontAwesomeIcons.lightbulb,
//     },
//     {
//       'name': 'Phone',
//       'icon': Icons.phone_outlined,
//     },
//     {
//       'name': 'Phone',
//       'icon': FontAwesomeIcons.phone,
//     },
//     {
//       'name': 'Internet',
//       'icon': Icons.wifi_outlined,
//     },

//     // ────────────── Fitness / Health ──────────────
//     {
//       'name': 'Health',
//       'icon': Icons.favorite_border,
//     },
//     {
//       'name': 'Health',
//       'icon': CupertinoIcons.heart_fill,
//     },
//     {
//       'name': 'Health',
//       'icon': FontAwesomeIcons.heart,
//     },
//     {
//       'name': 'Workout',
//       'icon': Icons.fitness_center_outlined,
//     },
//     {
//       'name': 'Workout',
//       'icon': FontAwesomeIcons.dumbbell,
//     },
//     {
//       'name': 'Medicine',
//       'icon': Icons.local_pharmacy_outlined,
//     },
//     {
//       'name': 'Medicine',
//       'icon': FontAwesomeIcons.pills,
//     },

//     // ────────────── Money / Income ──────────────
//     {
//       'name': 'Cash',
//       'icon': Icons.account_balance_wallet_outlined,
//     },
//     {
//       'name': 'Cash',
//       'icon': FontAwesomeIcons.moneyBillWave,
//     },
//     {
//       'name': 'Bank',
//       'icon': Icons.account_balance,
//     },
//     {
//       'name': 'Bank',
//       'icon': FontAwesomeIcons.buildingColumns,
//     },
//     {
//       'name': 'ATM',
//       'icon': Icons.account_balance_wallet,
//     },
//     {
//       'name': 'Savings',
//       'icon': Icons.savings_outlined,
//     },

//     // ────────────── Entertainment ──────────────
//     {
//       'name': 'Movie',
//       'icon': Icons.movie_outlined,
//     },
//     {
//       'name': 'Movie',
//       'icon': FontAwesomeIcons.film,
//     },
//     {
//       'name': 'Game',
//       'icon': Icons.videogame_asset_outlined,
//     },
//     {
//       'name': 'Game',
//       'icon': FontAwesomeIcons.gamepad,
//     },
//     {
//       'name': 'Music',
//       'icon': Icons.music_note_outlined,
//     },
//     {
//       'name': 'Music',
//       'icon': FontAwesomeIcons.music,
//     },

//     // ────────────── Others / Misc ──────────────
//     {
//       'name': 'Gift',
//       'icon': Icons.card_giftcard_outlined,
//     },
//     {
//       'name': 'Gift',
//       'icon': FontAwesomeIcons.gift,
//     },
//     {
//       'name': 'Book',
//       'icon': Icons.menu_book_outlined,
//     },
//     {
//       'name': 'Pets',
//       'icon': Icons.pets_outlined,
//     },
//     {
//       'name': 'Travel',
//       'icon': FontAwesomeIcons.planeDeparture,
//     },
//     {
//       'name': 'Star',
//       'icon': Icons.star_border,
//     },
//     {
//       'name': 'Tag',
//       'icon': CupertinoIcons.tag,
//     },
//   ];

//   /// Converts an IconData object into the map format needed for Category().
//   /// IconData 객체를 Category()에 필요한 map 형식으로 변환
//   static Map<String, dynamic> iconToDB(IconData icon, String name) {
//     return {
//       'name': name,
//       'icon_codepoint': icon.codePoint,
//       'icon_font_family': icon.fontFamily,
//       'icon_font_package': icon.fontPackage,
//     };
//   }
// }
