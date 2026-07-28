/// ============================================================================
/// File: esrimap_search_category.dart
/// Description: Model and utility helpers representing search categories
///              (e.g., Dining, Parking, Library) shown in suggestions.
/// ============================================================================

import 'package:flutter/material.dart';

/// Data class representing a quick search category chip shown on the map UI.
class EsriSearchCategory {
  /// Display label for the category (e.g. "Dining", "Parking").
  final String label;

  /// Icon visual representation for the category.
  final IconData icon;

  /// Underlying POI class string value used for filtering server queries.
  final String poiClassValue;

  /// Accent or background color associated with the category.
  final Color color;

  /// Constructs an [EsriSearchCategory] instance.
  const EsriSearchCategory({
    required this.label,
    required this.icon,
    required this.poiClassValue,
    this.color = const Color(0xFFF5F0E6),
  });
}

/// Utility function mapping string icon names from config to [IconData] constants.
IconData iconDataForName(String name) {
  switch (name) {
    case 'restaurant':
      return Icons.restaurant;
    case 'menu_book':
      return Icons.menu_book;
    case 'local_parking':
      return Icons.local_parking;
    case 'fitness_center':
      return Icons.fitness_center;
    case 'directions_bus':
      return Icons.directions_bus;
    default:
      return Icons.place;
  }
}

/// Utility function converting hexadecimal color strings (e.g., "#FFCD00") to Flutter [Color] objects.
Color colorFromHex(String? hex) {
  final isHexEmpty = hex == null || hex.isEmpty;
  if (isHexEmpty) return const Color(0xFFF5F0E6);
  final stripped = hex.replaceFirst('#', '');
  final value = int.tryParse(stripped, radix: 16);
  if (value == null) return const Color(0xFFF5F0E6);
  return Color(0xFF000000 | value);
}
