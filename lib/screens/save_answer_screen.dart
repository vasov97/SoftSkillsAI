import 'package:flutter/material.dart';
import 'package:softai/extensions/l10n_extension.dart';
import 'package:softai/service/lessons_service.dart';

class SaveAnswerScreen extends StatefulWidget {
  final String conversationTitle;
  final String summaryText;
  final String apiKey;
  final List<Map<String, String>> messages;

  const SaveAnswerScreen({
    super.key,
    this.conversationTitle = '',
    this.summaryText = '',
    required this.apiKey,
    required this.messages,
  });

  @override
  State<SaveAnswerScreen> createState() => _SaveAnswerScreenState();
}

class _SaveAnswerScreenState extends State<SaveAnswerScreen> {
  late final TextEditingController _titleController;
  bool _saveToLibrary = true;
  bool _saveToGoals = true;
  bool _saveAsReminder = false;
  bool _isSaving = false;

  final LessonService _lessonService = LessonService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.conversationTitle);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // Future<void> _save() async {
  //   final title = _titleController.text.trim();
  //   if (title.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(context.l10n.pleaseAddTitle),
  //         backgroundColor: Colors.red.shade600,
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //       ),
  //     );
  //     return;
  //   }

  //   setState(() => _isSaving = true);

  //   try {
  //     // Extract AI tips from messages
  //     final aiMessages = widget.messages
  //         .where((m) => m['role'] == 'assistant')
  //         .map((m) => m['text'] ?? '')
  //         .where((t) => t.isNotEmpty)
  //         .toList();

  //     // Save to library
  //     if (_saveToLibrary) {
  //       await _lessonService.saveLesson(title, aiMessages);
  //     }

  //     // TODO: Save to goals if _saveToGoals
  //     // TODO: Save as reminder if _saveAsReminder

  //     if (!mounted) return;

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Row(
  //           children: [
  //             const Icon(Icons.check_circle, color: Colors.white, size: 20),
  //             const SizedBox(width: 10),
  //             Expanded(
  //               child: Text(
  //                 context.l10n.conversationSaved,
  //                 style: const TextStyle(
  //                   fontFamily: 'Montserrat',
  //                   fontWeight: FontWeight.w600,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         backgroundColor: const Color(0xFF0055CC),
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         duration: const Duration(seconds: 3),
  //       ),
  //     );

  //     Navigator.of(context).pop(true); // return true = saved
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error: $e'),
  //         backgroundColor: Colors.red.shade600,
  //         behavior: SnackBarBehavior.floating,
  //       ),
  //     );
  //   } finally {
  //     if (mounted) setState(() => _isSaving = false);
  //   }
  // }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.pleaseAddTitle),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (!_saveToLibrary && !_saveToGoals && !_saveAsReminder) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.pleaseSelectOption),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final aiMessages = widget.messages
          .where((m) => m['role'] == 'assistant')
          .map((m) => m['text'] ?? '')
          .where((t) => t.isNotEmpty)
          .toList();

      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Save to library (lessons tab)
      if (_saveToLibrary) {
        await _lessonService.saveLesson(title, aiMessages);
      }

      // Save as conversation
      if (_saveToGoals) {
        await _lessonService.saveConversation(
          title: title,
          summary: widget.summaryText.isNotEmpty
              ? widget.summaryText
              : aiMessages.isNotEmpty
                  ? aiMessages.first
                  : '',
          date: dateStr,
          messages: widget.messages,
        );
      }

      // Save as reminder
      if (_saveAsReminder) {
        await _lessonService.saveReminder(
          title: title,
          summary: widget.summaryText.isNotEmpty
              ? widget.summaryText
              : aiMessages.isNotEmpty
                  ? aiMessages.first
                  : '',
          date: dateStr,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.conversationSaved,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0055CC),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Future<void> _save() async {
  //   final title = _titleController.text.trim();
  //   if (title.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(context.l10n.pleaseAddTitle),
  //         backgroundColor: Colors.red.shade600,
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //       ),
  //     );
  //     return;
  //   }

  //   setState(() => _isSaving = true);

  //   try {
  //     final aiMessages = widget.messages
  //         .where((m) => m['role'] == 'assistant')
  //         .map((m) => m['text'] ?? '')
  //         .where((t) => t.isNotEmpty)
  //         .toList();

  //     final now = DateTime.now();
  //     final dateStr =
  //         '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

  //     // Save to library (lessons tab)
  //     if (_saveToLibrary) {
  //       await _lessonService.saveLesson(title, aiMessages);
  //     }

  //     // Save as conversation
  //     await _lessonService.saveConversation(
  //       title: title,
  //       summary: widget.summaryText.isNotEmpty
  //           ? widget.summaryText
  //           : aiMessages.isNotEmpty
  //               ? aiMessages.first
  //               : '',
  //       date: dateStr,
  //     );

  //     // TODO: Save as reminder if _saveAsReminder

  //     if (!mounted) return;

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Row(
  //           children: [
  //             const Icon(Icons.check_circle, color: Colors.white, size: 20),
  //             const SizedBox(width: 10),
  //             Expanded(
  //               child: Text(
  //                 context.l10n.conversationSaved,
  //                 style: const TextStyle(
  //                   fontFamily: 'Montserrat',
  //                   fontWeight: FontWeight.w600,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         backgroundColor: const Color(0xFF0055CC),
  //         behavior: SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         duration: const Duration(seconds: 3),
  //       ),
  //     );

  //     Navigator.of(context).pop(true);
  //   } catch (e) {
  //     if (!mounted) return;
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error: $e'),
  //         backgroundColor: Colors.red.shade600,
  //         behavior: SnackBarBehavior.floating,
  //       ),
  //     );
  //   } finally {
  //     if (mounted) setState(() => _isSaving = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final summary = widget.summaryText.isNotEmpty
        ? widget.summaryText
        : context.isEnglish
            ? "Summary could not be generated."
            : "Sažetak nije mogao biti generisan.";

    return Scaffold(
      backgroundColor: const Color(0xFF006FFF),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Skillena',
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 84, 204, 204),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'AI',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Stack(
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    l10n.saveThisConversation,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Add title label
                  Text(
                    l10n.addTitle,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Title input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _titleController,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.addTitleHint,
                        hintStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          color: Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Summary label
                  Text(
                    l10n.summaryAutomatic,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Summary box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      summary,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Add to label
                  Text(
                    l10n.addTo,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Checkboxes
                  _CheckboxItem(
                    label: l10n.myLibrary,
                    value: _saveToLibrary,
                    onChanged: (v) =>
                        setState(() => _saveToLibrary = v ?? false),
                  ),
                  const SizedBox(height: 8),
                  _CheckboxItem(
                    label: l10n.myGoals,
                    value: _saveToGoals,
                    onChanged: (v) => setState(() => _saveToGoals = v ?? false),
                  ),
                  const SizedBox(height: 8),
                  _CheckboxItem(
                    label: l10n.reminder,
                    value: _saveAsReminder,
                    onChanged: (v) =>
                        setState(() => _saveAsReminder = v ?? false),
                  ),
                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0055CC),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              l10n.save,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Skip button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        l10n.skip,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckboxItem extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CheckboxItem({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: value ? const Color(0xFF0055CC) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: value ? const Color(0xFF0055CC) : Colors.white,
                width: 2,
              ),
            ),
            child: value
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
