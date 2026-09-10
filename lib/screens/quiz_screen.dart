import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:softai/cubit/user_cubit.dart';
import 'package:softai/di/di.dart';
import 'package:softai/extensions/l10n_extension.dart';
import 'package:softai/model/goal.dart';
import 'package:softai/service/firebase_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  String get apiKey => dotenv.env['OPEN_API_KEY'] ?? '';

  List<Map<String, dynamic>> _questions = [];
  final Map<int, int> _answers = {};
  bool _isLoading = true;
  bool _submitted = false;
  int _score = 0;
  bool _passed = false;
  bool _isEnglish = true;
  late final UserCubit userCubit;
  late AnimationController _avatarController;
  Goal? _goal;

  @override
  void initState() {
    super.initState();
    userCubit = locator<UserCubit>();
    Future.microtask(() {
      if (!mounted) return;
      _isEnglish = context.isEnglish;
      _loadGoalAndGenerate();
    });
    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }

  double _fakeProgress = 0.0;
  Timer? _progressTimer;
  Future<void> _loadGoalAndGenerate() async {
    _startFakeProgress();
    final goalId = userCubit.pendingQuizGoalId;
    debugPrint('🎯 QuizScreen loaded with goalId: $goalId');
    if (goalId == null) {
      Navigator.of(context).pop();
      return;
    }
    final goals = await userCubit.getGoals();
    _goal = goals.firstWhere((g) => g.id == goalId);
    debugPrint('🎯 Loaded goal: ${_goal!.title} (id: ${_goal!.id})');
    await _generateQuiz();
  }

  void _startFakeProgress() {
    _progressTimer?.cancel();
    _fakeProgress = 0.0;
    _progressTimer = Timer.periodic(const Duration(milliseconds: 60), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_fakeProgress < 1) {
          _fakeProgress += 0.01;
        }
      });
    });
  }

  void _completeFakeProgress() {
    _progressTimer?.cancel();
    if (mounted) {
      setState(() => _fakeProgress = 1.0);
    }
  }

  Future<void> _generateQuiz() async {
    if (_goal == null) return;
    final isSerbian = !_isEnglish;

    final prompt = isSerbian
        ? '''Generiši kviz od 7 pitanja za meku veštinu "${_goal!.skill}" u kontekstu cilja "${_goal!.title}".

Format: SAMO JSON, ništa drugo.
{
  "questions": [
    {
      "type": "mcq",
      "question": "Pitanje?",
      "options": ["A", "B", "C", "D"],
      "correct": 0
    }
  ]
}

Pravila:
- Prvih 5 pitanja su scenario pitanja sa 4 opcije (type: "mcq")
- Poslednjih 2 su samoprocena sa 5 opcija od 1-5 (type: "reflection")
- Za reflection pitanja, correct je uvek 0 (svi odgovori su tačni)
- Piši na srpskom, ekavica
- Scenarija trebaju biti realistične radne situacije'''
        : '''Generate a 7-question quiz for the soft skill "${_goal!.skill}" in the context of goal "${_goal!.title}".

Format: ONLY JSON, nothing else.
{
  "questions": [
    {
      "type": "mcq",
      "question": "Question?",
      "options": ["A", "B", "C", "D"],
      "correct": 0
    }
  ]
}

Rules:
- First 5 questions are scenario-based with 4 options (type: "mcq")
- Last 2 are self-reflection with 5 options scaled 1-5 (type: "reflection")
- For reflection questions, correct is always 0 (all answers are valid)
- Scenarios should be realistic workplace situations''';

    try {
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "model": "gpt-4o-mini",
          "temperature": 0.5,
          "response_format": {"type": "json_object"},
          "messages": [
            {
              "role": "system",
              "content": isSerbian
                  ? "Ti si ekspert za meke veštine. Piši na srpskom, ekavica."
                  : "You are a soft skills expert.",
            },
            {"role": "user", "content": prompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        final parsed = json.decode(content) as Map<String, dynamic>;
        final questions = (parsed['questions'] as List)
            .map((q) => Map<String, dynamic>.from(q))
            .toList();

        if (mounted) {
          setState(() {
            _questions = questions;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          _showError();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError();
      }
    }
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEnglish
            ? 'Failed to generate quiz. Please try again.'
            : 'Neuspešno generisanje kviza. Pokušaj ponovo.'),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }

  void _submit() async {
    if (_answers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEnglish
              ? 'Please answer all questions'
              : 'Odgovori na sva pitanja'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    int correct = 0;
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      if (q['type'] == 'reflection') {
        correct++;
      } else if (_answers[i] == q['correct']) {
        correct++;
      }
    }

    final percentage = (correct / _questions.length * 100).round();
    final passed = percentage >= 90;

    setState(() {
      _score = correct;
      _passed = passed;
      _submitted = true;
    });

    userCubit.setQuizResult(passed);

    if (_goal != null) {
      debugPrint('📝 Passed=$passed, goal=${_goal!.id}');
      if (passed) {
        await userCubit.completeGoalById(_goal!.id);
      } else {
        debugPrint('📝 Calling _resetSubtasksNow');
        await _resetSubtasksNow();
      }
    } else {
      debugPrint('❌ _goal is null in _submit!');
    }
  }

  Future<void> _resetSubtasksNow() async {
    debugPrint('🔄 _resetSubtasksNow START');
    if (_goal == null) {
      debugPrint('❌ _goal is null');
      return;
    }
    debugPrint('🔄 Current subtasks: ${_goal!.subtasks.length}');
    final isSerbian = !_isEnglish;
    List<String> newSubtasks = [];

    try {
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "model": "gpt-4o-mini",
          "temperature": 0.4,
          "response_format": {"type": "json_object"},
          "messages": [
            {
              "role": "system",
              "content": isSerbian
                  ? "Ti si ekspert za meke veštine. Piši na srpskom, ekavica."
                  : "You are a soft skills expert.",
            },
            {
              "role": "user",
              "content": isSerbian
                  ? 'Daj mi tačno 2 NOVA podzadatka za cilj "${_goal!.title}" (veština: ${_goal!.skill}), različita od ovih:\n${_goal!.subtasks.join("\n")}\n\nFormat: {"subtasks": ["...", "..."]}'
                  : 'Give me exactly 2 NEW subtasks for goal "${_goal!.title}" (skill: ${_goal!.skill}), different from these:\n${_goal!.subtasks.join("\n")}\n\nFormat: {"subtasks": ["...", "..."]}',
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        final parsed = json.decode(content) as Map<String, dynamic>;
        newSubtasks = (parsed['subtasks'] as List)
            .map((e) => e.toString().trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
    } catch (_) {}

    if (newSubtasks.isEmpty) {
      newSubtasks = isSerbian
          ? ['Vežbaj ponovo sa kolegom', 'Primeni tehniku u stvarnoj situaciji']
          : ['Practice again', 'Apply in real situation'];
    }
    debugPrint('🔄 New subtasks generated: ${newSubtasks.length}');
    debugPrint('🔄 Calling addSubtasksToGoal');
    // Fetch current goal fresh from server to get latest subtasks
    final freshGoals = await locator<FirebaseService>().getGoals();
    final freshGoal = freshGoals.firstWhere((g) => g.id == _goal!.id);
    await userCubit.addSubtasksToGoal(
        _goal!.id, freshGoal.subtasks, newSubtasks);
    debugPrint('✅ addSubtasksToGoal returned');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFF006FFF),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
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
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Rotating avatar
                        RotationTransition(
                          turns: _avatarController,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.15),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Image.asset(
                                  'assets/avatar.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Progress bar with percentage
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: _fakeProgress,
                                  minHeight: 8,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.2),
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${(_fakeProgress * 100).round()}%',
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            _isEnglish
                                ? "Skillena is preparing your quiz..."
                                : "Skillena priprema tvoj kviz...",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : _submitted
                    ? _buildResult()
                    : _buildQuiz(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuiz() {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.skillQuiz,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _goal?.title ?? '',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_answers.length}/${_questions.length} ${l10n.answered}',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            itemCount: _questions.length,
            itemBuilder: (context, qi) {
              final q = _questions[qi];
              final isReflection = q['type'] == 'reflection';
              final options =
                  (q['options'] as List).map((e) => e.toString()).toList();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isReflection
                                ? const Color(0xFF00CC88)
                                    .withValues(alpha: 0.12)
                                : const Color(0xFF0066FF)
                                    .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isReflection
                                ? l10n.reflection
                                : '${l10n.question} ${qi + 1}',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isReflection
                                  ? const Color(0xFF00CC88)
                                  : const Color(0xFF0066FF),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      q['question'],
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...List.generate(options.length, (oi) {
                      final isSelected = _answers[qi] == oi;

                      return GestureDetector(
                        onTap: _submitted
                            ? null
                            : () => setState(() => _answers[qi] = oi),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF0055CC)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF0055CC)
                                  : Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Center(
                                        child: Icon(Icons.check,
                                            size: 12, color: Color(0xFF0055CC)))
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  options[oi],
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF1A1A2E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0055CC),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: Text(
                l10n.submitQuiz,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final l10n = context.l10n;
    final percentage = (_score / _questions.length * 100).round();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _passed
                      ? const Color(0xFF00CC88).withValues(alpha: 0.15)
                      : Colors.red.shade50,
                ),
                child: Icon(
                  _passed ? Icons.emoji_events : Icons.refresh,
                  size: 40,
                  color: _passed ? const Color(0xFF00CC88) : Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _passed ? l10n.quizPassed : l10n.quizFailed,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color:
                      _passed ? const Color(0xFF00CC88) : Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$_score/${_questions.length} ($percentage%)',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _passed ? l10n.quizPassedMessage : l10n.quizFailedMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              if (!_passed) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.quizFailedSubtasksAdded,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _passed
                        ? const Color(0xFF00CC88)
                        : const Color(0xFF0055CC),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _passed ? l10n.continueForward : l10n.tryAgain,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
