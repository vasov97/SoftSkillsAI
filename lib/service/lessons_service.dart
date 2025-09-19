import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LessonService {
  static const String _keySavedLessons = "saved_lessons";

  /// Save lesson for a skill
  Future<void> saveLesson(String skill, List<String> tips) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_keySavedLessons);
    final lessons = existing != null
        ? json.decode(existing) as Map<String, dynamic>
        : <String, dynamic>{};

    lessons[skill] = tips;
    await prefs.setString(_keySavedLessons, json.encode(lessons));
  }

  /// Load all lessons
  Future<Map<String, List<String>>> loadLessons() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_keySavedLessons);
    if (existing == null) return {};
    final decoded = json.decode(existing) as Map<String, dynamic>;

    return decoded.map((key, value) {
      return MapEntry(key, List<String>.from(value));
    });
  }

  /// Remove a lesson by skill
  Future<void> removeLesson(String skill) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_keySavedLessons);
    if (existing == null) return;
    final lessons = json.decode(existing) as Map<String, dynamic>;
    lessons.remove(skill);
    await prefs.setString(_keySavedLessons, json.encode(lessons));
  }

  /// Clear all lessons
  Future<void> clearLessons() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySavedLessons);
  }
}
