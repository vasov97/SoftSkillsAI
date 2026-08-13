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

class _SavedLessonsScreenState extends State<SavedLessonsScreen>
    with SingleTickerProviderStateMixin {
  final LessonService _lessonService = LessonService();
  Map<String, List<String>> _lessons = {};
  List<Map<String, String>> _conversations = [];
  List<Map<String, String>> _techniques = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    final lessons = await _lessonService.loadLessons();
    final conversations = await _lessonService.loadConversations();
    final techniques = await _lessonService.loadTechniques();
    setState(() {
      _lessons = lessons;
      _conversations = conversations;
      _techniques = techniques;
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
          backgroundColor: const Color(0xFF0055CC),
          content: Text(
            '${context.l10n.lesson} "$skill" ${context.l10n.removed}.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Montserrat',
            ),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _removeConversation(int index) async {
    final title = _conversations[index]['title'] ?? '';
    await _lessonService.removeConversation(index);
    setState(() {
      _conversations.removeAt(index);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF0055CC),
          content: Text(
            '"$title" ${context.l10n.removed}.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Montserrat',
            ),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _removeTechnique(int index) async {
    final name = _techniques[index]['name'] ?? '';
    await _lessonService.removeTechnique(index);
    setState(() {
      _techniques.removeAt(index);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF0055CC),
          content: Text(
            '"$name" ${context.l10n.removed}.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Montserrat',
            ),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  String _daysAgo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date).inDays;
      if (diff == 0) return context.isEnglish ? 'today' : 'danas';
      if (diff == 1) return context.isEnglish ? 'yesterday' : 'juče';
      return context.isEnglish ? '$diff days ago' : 'pre $diff dana';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final allLessons = _lessons.entries.toList();

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF006FFF),
                Color(0xFF00AAF2),
                Color(0xFF00E5E5),
                Color(0xFF0BFF96),
              ],
              stops: [0.0, 0.24, 0.49, 1.0],
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Text(
                        l10n.myLibrary,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: const Color(0xFF0055CC),
                          unselectedLabelColor: Colors.white,
                          labelStyle: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          labelPadding: EdgeInsets.zero,
                          tabs: [
                            Tab(text: l10n.tabConversations),
                            Tab(text: l10n.tabLessons),
                            Tab(text: l10n.tabTechniques),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildConversationsList(),
                          _buildLessonsList(allLessons, l10n),
                          _buildTechniquesList(),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  // --- Conversations tab ---
  Widget _buildConversationsList() {
    if (_conversations.isEmpty) {
      return Center(
        child: Text(
          context.l10n.noConversationsSaved,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            color: const Color.fromARGB(255, 26, 25, 25).withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: _conversations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final conv = _conversations[index];
        return Dismissible(
          key: Key('conv_${index}_${conv['title']}'),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _removeConversation(index),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: _LibraryCard(
            title: conv['title'] ?? '',
            subtitle: _daysAgo(conv['date']),
            tagText: context.l10n.tagConversation,
            tagColor: const Color(0xFF00AADD),
            icon: Icons.chat_bubble_outline,
            onTap: () => _showConversationDetail(conv),
          ),
        );
      },
    );
  }

  void _showConversationDetail(Map<String, String> conv) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                const Color(0xFF00AADD).withValues(alpha: 0.12),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline,
                            size: 20,
                            color: Color(0xFF00AADD),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            conv['title'] ?? '',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      conv['summary'] ?? '',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        color: Color(0xFF1A1A2E),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _daysAgo(conv['date']),
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Lessons tab ---
  Widget _buildLessonsList(
      List<MapEntry<String, List<String>>> lessons, dynamic l10n) {
    if (lessons.isEmpty) {
      return Center(
        child: Text(
          l10n.noSavedLessons,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            color: const Color.fromARGB(255, 26, 25, 25).withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: lessons.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final entry = lessons[index];
        final skill = entry.key;
        final tips = entry.value;

        return Dismissible(
          key: Key(skill),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _removeLesson(skill),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: _LibraryCard(
            title: skill,
            subtitle: tips.isNotEmpty ? tips.first : '',
            tagText: context.l10n.tagLesson,
            tagColor: const Color(0xFF0066FF),
            icon: Icons.menu_book_outlined,
            onTap: () => _showLessonDetail(skill, tips),
          ),
        );
      },
    );
  }

  void _showLessonDetail(String skill, List<String> tips) {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF0066FF)
                                  .withValues(alpha: 0.12),
                            ),
                            child: const Icon(
                              Icons.menu_book_outlined,
                              size: 20,
                              color: Color(0xFF0066FF),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              skill,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...tips.map((tip) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '•  ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF0066FF),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 15,
                                      color: Color(0xFF1A1A2E),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _removeLesson(skill);
                          },
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red, size: 20),
                          label: Text(
                            l10n.removeLesson,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Techniques tab ---
  Widget _buildTechniquesList() {
    if (_techniques.isEmpty) {
      return Center(
        child: Text(
          context.l10n.noTechniquesSaved,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            color: const Color.fromARGB(255, 26, 25, 25).withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: _techniques.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final tech = _techniques[index];
        return Dismissible(
          key: Key('tech_${index}_${tech['name']}'),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _removeTechnique(index),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: _LibraryCard(
            title: tech['name'] ?? '',
            subtitle: _daysAgo(tech['date']),
            tagText: context.l10n.tagTechnique,
            tagColor: const Color(0xFF00CC88),
            icon: Icons.psychology_outlined,
            onTap: () => _showTechniqueDetail(tech),
          ),
        );
      },
    );
  }

  void _showTechniqueDetail(Map<String, String> tech) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                const Color(0xFF00CC88).withValues(alpha: 0.12),
                          ),
                          child: const Icon(
                            Icons.psychology_outlined,
                            size: 20,
                            color: Color(0xFF00CC88),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tech['name'] ?? '',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tech['description'] ?? '',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        color: Color(0xFF1A1A2E),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _daysAgo(tech['date']),
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String tagText;
  final Color tagColor;
  final IconData icon;
  final VoidCallback onTap;

  const _LibraryCard({
    required this.title,
    required this.subtitle,
    required this.tagText,
    required this.tagColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: tagColor.withValues(alpha: 0.12),
              ),
              child: Icon(icon, size: 20, color: tagColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: tagColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tagText,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: tagColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
