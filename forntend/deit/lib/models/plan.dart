import 'package:flutter/foundation.dart';

class MealItem {
  final int id;
  final String description;
  final double caloriesPer100g;
  final double servingSize;

  MealItem({
    required this.id,
    required this.description,
    required this.caloriesPer100g,
    required this.servingSize,
  });
}

class PlanModel extends ChangeNotifier {
  int? planId;
  double? totalCalories;
  List<MealItem> items = [];

  void setPlan(Map<String, dynamic> data) {
    planId = data['id'] as int;
    totalCalories = (data['total_calories'] as num).toDouble();
    items = (data['items'] as List<dynamic>).map((item) {
      final meal = item['meal'] as Map<String, dynamic>;
      return MealItem(
        id: item['id'] as int,
        description: meal['description'] as String,
        caloriesPer100g: (meal['calories_per_100g'] as num).toDouble(),
        servingSize: (item['serving_size'] as num).toDouble(),
      );
    }).toList();
    notifyListeners();
  }
}
