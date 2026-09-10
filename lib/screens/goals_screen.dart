import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:softai/cubit/user_cubit.dart';
import 'package:softai/di/di.dart';
import 'package:softai/extensions/l10n_extension.dart';
import 'package:softai/model/goal.dart';
import 'package:softai/screens/quiz_screen.dart';
import 'package:softai/service/firebase_service.dart';
import 'package:softai/service/subscription_service.dart';
import 'package:softai/widgets/pro_overlay.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with SingleTickerProviderStateMixin {
  final userCubit = locator<UserCubit>();
  List<Goal> _goals = [];
  bool _isLoading = true;
  bool _quizOpen = false;
  late TabController _tabController;
  final _subscriptionService = locator<SubscriptionService>();
  final Map<String, String> _translations = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadGoals();
  }

  @override
  void activate() {
    super.activate();
    _loadGoals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<String> _translate(String text) async {
    if (context.isEnglish) return text;
    if (_translations.containsKey(text)) return _translations[text]!;

    try {
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer ${dotenv.env['OPEN_API_KEY'] ?? ''}",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "model": "gpt-4o-mini",
          "max_tokens": 100,
          "temperature": 0.2,
          "messages": [
            {
              "role": "system",
              "content":
                  "Translate the following text to Serbian (ekavica). Use correct Serbian grammar. Return ONLY the translation in nominative case."
            },
            {"role": "user", "content": text}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translated =
            data['choices'][0]['message']['content'].toString().trim();
        _translations[text] = translated;
        return translated;
      }
    } catch (_) {}
    return text;
  }

  //final _subscriptionService = locator<SubscriptionService>();
  Future<void> _translateAllGoals() async {
    if (context.isEnglish) return;
    for (final goal in _goals) {
      await _translate(goal.title);
      for (final subtask in goal.subtasks) {
        await _translate(subtask);
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _loadGoals() async {
    debugPrint('📥 _loadGoals called');
    //final goals = await userCubit.getGoals();
    final goals = await locator<FirebaseService>().getGoals();
    debugPrint('📥 Got ${goals.length} goals');
    for (final g in goals) {
      debugPrint('  - ${g.title}: ${g.subtasks.length} subtasks');
    }
    if (!mounted) return;
    setState(() {
      _goals = goals;
      _isLoading = false;
    });
    await _translateAllGoals();
  }

  Future<void> _toggleSubtask({
    required Goal goal,
    required int index,
    required bool done,
  }) async {
    if (_quizOpen) return;

    final gi = _goals.indexWhere((g) => g.id == goal.id);
    List<Goal>? snapshotBefore;

    if (gi != -1) {
      snapshotBefore = List<Goal>.from(_goals);
      final updatedDone = List<bool>.from(goal.subtasksDone);

      if (index >= updatedDone.length) {
        updatedDone.length = index + 1;
        for (var i = 0; i < updatedDone.length; i++) {
          updatedDone[i] =
              i < goal.subtasksDone.length ? goal.subtasksDone[i] : false;
        }
      }

      updatedDone[index] = done;

      setState(() {
        _goals[gi] = goal.copyWith(subtasksDone: updatedDone);
      });

      try {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseService().updateGoalSubtask(
          uid: uid,
          goalId: goal.id,
          index: index,
          done: done,
        );
      } catch (e) {
        if (mounted) setState(() => _goals = snapshotBefore!);
        return;
      }

      final updatedGoal = _goals[gi];
      final allDone = updatedGoal.subtasks.isNotEmpty &&
          updatedGoal.subtasksDone.length == updatedGoal.subtasks.length &&
          updatedGoal.subtasksDone.every((d) => d);

      if (allDone && !_quizOpen) {
        // Pro check for quiz
        if (!_subscriptionService.canTakeQuiz) {
          await ProLockOverlay.show(
            context,
            reason: context.isEnglish
                ? 'Complete your goal with the Skill Quiz — a Pro feature that certifies your mastery.'
                : 'Završi cilj kroz kviz veština — Pro opcija koja sertifikuje tvoje ovladavanje.',
          );
          return;
        }

        _quizOpen = true;
        userCubit.setPendingQuiz(updatedGoal.id);

        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const QuizScreen()),
        );

        _quizOpen = false;
        userCubit.clearQuizResult();
        await _loadGoals();
      }
    }
  }

  String _getSkillIcon(String skillKey) {
    const map = {
      'Communication': 'assets/communication2.png',
      'Leadership': 'assets/leader.png',
      'Teamwork': 'assets/team.png',
      'Problem-Solving': 'assets/solve.png',
      'Time Management': 'assets/time.png',
      'Adaptability': 'assets/skill_adaptability.png',
      'Emotional Intelligence': 'assets/skill_emotional_intelligence.png',
      'Conflict Resolution': 'assets/conflict.png',
      'Creativity': 'assets/creativity.png',
      'Decision Making': 'assets/skill_decision_making.png',
      'Critical Thinking': 'assets/skill_critical_thinking.png',
      'Negotiation': 'assets/negotation.png',
      'Active Listening': 'assets/active.png',
      'Work Ethic': 'assets/skill_work_ethic.png',
      'Interpersonal Skills': 'assets/inter.png',
      'Stress Management': 'assets/stress.png',
      'Networking': 'assets/networking.png',
      'Coaching & Mentoring': 'assets/mentoring.png',
      'Persuasion': 'assets/persuasion.png',
      'Self-Motivation': 'assets/skill_self_motivation.png',
    };
    return map[skillKey] ?? 'assets/communication2.png';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final activeGoals = _goals.where((g) => g.isActive).toList();
    final completedGoals = _goals.where((g) => !g.isActive).toList();

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
                  child: CircularProgressIndicator(color: Colors.white))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Text(
                        l10n.myGoals,
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
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          tabs: [
                            Tab(text: '${l10n.active} (${activeGoals.length})'),
                            Tab(
                                text:
                                    '${l10n.completed} (${completedGoals.length})'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildGoalList(activeGoals, l10n),
                          _buildGoalList(completedGoals, l10n),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildGoalList(List<Goal> goals, dynamic l10n) {
    if (goals.isEmpty) {
      return Center(
        child: Text(
          l10n.noGoalsYet,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: goals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final goal = goals[i];
        final total = goal.subtasks.length;
        final doneCount = goal.subtasksDone.where((d) => d).length;
        final progress = total == 0 ? 0.0 : (doneCount / total).clamp(0.0, 1.0);

        return _GoalCard(
          goal: goal,
          progress: progress,
          doneCount: doneCount,
          totalCount: total,
          skillIcon: _getSkillIcon(goal.skill),
          translatedTitle: _translations[goal.title] ?? goal.title,
          translatedSubtasks:
              goal.subtasks.map((s) => _translations[s] ?? s).toList(),
          onToggleSubtask: (idx, v) =>
              _toggleSubtask(goal: goal, index: idx, done: v),
        );
      },
    );
  }
}

class _GoalCard extends StatefulWidget {
  final Goal goal;
  final double progress;
  final int doneCount;
  final int totalCount;
  final String skillIcon;
  final String translatedTitle;
  final List<String> translatedSubtasks;
  final void Function(int index, bool value) onToggleSubtask;

  const _GoalCard({
    required this.goal,
    required this.progress,
    required this.doneCount,
    required this.totalCount,
    required this.skillIcon,
    required this.translatedTitle,
    required this.translatedSubtasks,
    required this.onToggleSubtask,
  });

  @override
  State<_GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<_GoalCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    final subtasks = goal.subtasks;
    final states = goal.subtasksDone;
    final l10n = context.l10n;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon + Title + Description
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Skill icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0066FF).withValues(alpha: 0.12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      widget.skillIcon,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Title + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.translatedTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      if (goal.subtasks.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.translatedSubtasks.first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Progress label + bar + fraction
            Text(
              l10n.progress,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: widget.progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      color: const Color(0xFF0066FF),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${widget.doneCount}/${widget.totalCount} ${l10n.steps}',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),

            // Expanded subtasks
            if (_expanded && subtasks.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                height: 1,
                color: Colors.grey.shade200,
              ),
              const SizedBox(height: 10),
              ...List.generate(subtasks.length, (i) {
                final done = i < states.length ? states[i] : false;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: GestureDetector(
                    onTap: () => widget.onToggleSubtask(i, !done),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done
                                ? const Color(0xFF0066FF)
                                : Colors.transparent,
                            border: Border.all(
                              color: done
                                  ? const Color(0xFF0066FF)
                                  : Colors.grey.shade400,
                              width: 1.5,
                            ),
                          ),
                          child: done
                              ? const Icon(Icons.check,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.translatedSubtasks[i],
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: done
                                  ? Colors.grey.shade400
                                  : const Color(0xFF1A1A2E),
                              decoration:
                                  done ? TextDecoration.lineThrough : null,
                              decorationColor: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],

            if (_expanded && subtasks.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  l10n.noSubtasksYet,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
