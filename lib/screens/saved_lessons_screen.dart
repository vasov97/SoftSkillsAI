import 'package:flutter/material.dart';
import 'package:softai/extensions/l10n_extension.dart';
import 'package:softai/model/user.dart';
import 'package:softai/service/lessons_service.dart';

class SavedLessonsScreen extends StatefulWidget {
  const SavedLessonsScreen({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  State<SavedLessonsScreen> createState() => _SavedLessonsScreenState();
}

class _SavedLessonsScreenState extends State<SavedLessonsScreen> {
  final LessonService _lessonService = LessonService();
  Map<String, List<String>> _lessons = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    final lessons = await _lessonService.loadLessons();
    setState(() {
      _lessons = lessons;
      _isLoading = false;
    });
  }

  Future<void> _removeLesson(String skill) async {
    await _lessonService.removeLesson(skill);
    setState(() {
      _lessons.remove(skill);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color.fromARGB(255, 12, 126, 219),
          content: Text(
            '${context.l10n.lesson} "$skill" ${context.l10n.removed}.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.savedLessons,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontFamily: 'Montserrat',
          ),
        ),
        backgroundColor: const Color(0xFF007BFF),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF007BFF),
                        Color(0xFF00FFD5),
                      ],
                    ),
                  ),
                ),
                _lessons.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noSavedLessons,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: _lessons.entries.map((entry) {
                          final skill = entry.key;
                          final tips = entry.value;

                          return Dismissible(
                              key: Key(skill),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) => _removeLesson(skill),
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: Colors.red,
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Stack(
                                    children: [
                                      // Column for title + tips
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              skill,
                                              style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                                fontFamily: 'Montserrat',
                                              ),
                                              softWrap:
                                                  true, // ✅ allows wrapping
                                              maxLines:
                                                  null, // ✅ unlimited lines
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ...tips.map((tip) => Text(
                                                "• $tip",
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black54,
                                                  fontFamily: 'Montserrat',
                                                ),
                                              )),
                                        ],
                                      ),
                                      // Delete button in top-right
                                      Positioned(
                                        right: -16,
                                        top: -8,
                                        child: IconButton(
                                          iconSize: 32,
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => _removeLesson(skill),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ));
                        }).toList(),
                      ),
              ],
            ),
    );
  }
}
