import 'package:shared_preferences/shared_preferences.dart';

class GoalService {
  static const String weightKey = "target_weight";
  static const String stepsKey = "daily_steps";
  static const String caloriesKey = "daily_calories";
  static const String waterKey = "daily_water";

  Future<void> saveGoals({
    required String weight,
    required String steps,
    required String calories,
    required String water,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(weightKey, weight);
    await prefs.setString(stepsKey, steps);
    await prefs.setString(caloriesKey, calories);
    await prefs.setString(waterKey, water);
  }

  Future<Map<String, String>> loadGoals() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      "weight": prefs.getString(weightKey) ?? "",
      "steps": prefs.getString(stepsKey) ?? "",
      "calories": prefs.getString(caloriesKey) ?? "",
      "water": prefs.getString(waterKey) ?? "",
    };
  }
}