import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String themeKey = 'theme';

  Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeKey, theme);
  }

  Future<String?> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(themeKey);
  }
}