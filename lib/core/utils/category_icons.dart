import 'package:flutter/material.dart';

class CategoryIcons {
  static const Map<String, IconData> map = {
    'shopping_bag': Icons.shopping_bag_outlined,
    'local_offer': Icons.local_offer_outlined,
    'devices': Icons.devices_outlined,
    'smartphone': Icons.smartphone_outlined,
    'laptop': Icons.laptop_outlined,
    'tv': Icons.tv_outlined,
    'headphones': Icons.headphones_outlined,
    'checkroom': Icons.checkroom_outlined,
    'dry_cleaning': Icons.dry_cleaning_outlined,
    'home': Icons.home_outlined,
    'chair': Icons.chair_outlined,
    'kitchen': Icons.kitchen_outlined,
    'restaurant': Icons.restaurant_outlined,
    'local_grocery_store': Icons.local_grocery_store_outlined,
    'fastfood': Icons.fastfood_outlined,
    'sports_soccer': Icons.sports_soccer_outlined,
    'fitness_center': Icons.fitness_center_outlined,
    'directions_car': Icons.directions_car_outlined,
    'two_wheeler': Icons.two_wheeler_outlined,
    'build': Icons.build_outlined,
    'palette': Icons.palette_outlined,
    'pets': Icons.pets_outlined,
    'toys': Icons.toys_outlined,
    'child_care': Icons.child_care_outlined,
    'menu_book': Icons.menu_book_outlined,
    'camera_alt': Icons.camera_alt_outlined,
    'watch': Icons.watch_outlined,
    'favorite': Icons.favorite_outline,
    'diamond': Icons.diamond_outlined,
    'card_giftcard': Icons.card_giftcard_outlined,
    'category': Icons.category_outlined,
  };

  static IconData getIcon(String? name) {
    if (name == null || name.isEmpty) return Icons.category_outlined;
    return map[name] ?? Icons.category_outlined;
  }
}

