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

  // Add these constants and methods to your existing LessonService class

  static const String _keySavedConversations = 'saved_conversations';
  static const String _keySavedTechniques = 'saved_techniques';

// --- Conversations ---
  Future<List<Map<String, String>>> loadConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keySavedConversations);
    if (raw == null) return [];
    final decoded = json.decode(raw) as List<dynamic>;
    return decoded.map((e) => Map<String, String>.from(e as Map)).toList();
  }

  // Future<void> saveConversation({
  //   required String title,
  //   required String summary,
  //   required String date,
  // }) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final conversations = await loadConversations();
  //   conversations.insert(0, {
  //     'title': title,
  //     'summary': summary,
  //     'date': date,
  //   });
  //   await prefs.setString(_keySavedConversations, json.encode(conversations));
  // }

  Future<void> saveConversation({
    required String title,
    required String summary,
    required String date,
    List<Map<String, String>>? messages,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final conversations = await loadConversations();
    conversations.insert(0, {
      'title': title,
      'summary': summary,
      'date': date,
      if (messages != null) 'messages': json.encode(messages),
    });
    await prefs.setString(_keySavedConversations, json.encode(conversations));
  }

  Future<void> removeConversation(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final conversations = await loadConversations();
    if (index >= 0 && index < conversations.length) {
      conversations.removeAt(index);
      await prefs.setString(_keySavedConversations, json.encode(conversations));
    }
  }

// --- Techniques ---
  Future<List<Map<String, String>>> loadTechniques() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keySavedTechniques);
    if (raw == null) return [];
    final decoded = json.decode(raw) as List<dynamic>;
    return decoded.map((e) => Map<String, String>.from(e as Map)).toList();
  }

  Future<void> saveTechnique({
    required String name,
    required String description,
    required String date,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final techniques = await loadTechniques();
    techniques.insert(0, {
      'name': name,
      'description': description,
      'date': date,
    });
    await prefs.setString(_keySavedTechniques, json.encode(techniques));
  }

  Future<void> removeTechnique(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final techniques = await loadTechniques();
    if (index >= 0 && index < techniques.length) {
      techniques.removeAt(index);
      await prefs.setString(_keySavedTechniques, json.encode(techniques));
    }
  }

  static const String _keySavedReminders = 'saved_reminders';

  Future<List<Map<String, String>>> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keySavedReminders);
    if (raw == null) return [];
    final decoded = json.decode(raw) as List<dynamic>;
    return decoded.map((e) => Map<String, String>.from(e as Map)).toList();
  }

  Future<void> saveReminder({
    required String title,
    required String summary,
    required String date,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final reminders = await loadReminders();
    reminders.insert(0, {
      'title': title,
      'summary': summary,
      'date': date,
    });
    await prefs.setString(_keySavedReminders, json.encode(reminders));
  }

  Future<void> removeReminder(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final reminders = await loadReminders();
    if (index >= 0 && index < reminders.length) {
      reminders.removeAt(index);
      await prefs.setString(_keySavedReminders, json.encode(reminders));
    }
  }
}
