import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _onboardingKey = 'has_seen_onboarding';
  static const String _themeKey = 'is_dark_mode';
  static const String _remindersKey = 'reminders_enabled';

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? true; // Default to dark
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
  }

  Future<bool> areRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_remindersKey) ?? true; // Default to on
  }

  Future<void> setRemindersEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_remindersKey, value);
  }
}
