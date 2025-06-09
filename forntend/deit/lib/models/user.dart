import 'package:flutter/foundation.dart';

class UserModel extends ChangeNotifier {
  int? id;
  String? name;
  int? age;
  String? gender;
  double? height;
  double? weight;
  String? activityLevel;
  String? goal;

  void setUser(Map<String, dynamic> data) {
    id = data['id'] as int;
    name = data['name'] as String;
    age = data['age'] as int;
    gender = data['gender'] as String;
    height = (data['height'] as num).toDouble();
    weight = (data['weight'] as num).toDouble();
    activityLevel = data['activity_level'] as String;
    goal = data['goal'] as String;
    notifyListeners();
  }
}
