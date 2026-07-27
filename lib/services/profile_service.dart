import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const _imageKey = 'profile_image';

  static Future<void> saveProfileImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_imageKey, path);
  }

  static Future<String?> getProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_imageKey);
  }

  // ---------- BMI ----------

  static Future<void> saveBMI({
    required double bmi,
    required double height,
    required double weight,
    required String category,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('bmi', bmi);
    await prefs.setDouble('height', height);
    await prefs.setDouble('weight', weight);
    await prefs.setString('category', category);
  }

  static Future<double?> getBMI() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('bmi');
  }

  static Future<double?> getHeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('height');
  }

  static Future<double?> getWeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('weight');
  }

  static Future<String?> getCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('category');
  }
}