// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:softai/cubit/user_cubit.dart';
// import 'package:softai/di/di.dart';
// import 'package:softai/model/goal.dart';
// import 'package:softai/service/firebase_service.dart';

// class GoalsScreen extends StatefulWidget {
//   const GoalsScreen({super.key});

//   @override
//   State<GoalsScreen> createState() => _GoalsScreenState();
// }

// class _GoalsScreenState extends State<GoalsScreen> {
//   final userCubit = locator<UserCubit>();
//   List<Goal> _goals = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadGoals();
//   }

//   Future<void> _loadGoals() async {
//     final goals = await userCubit.getGoals();
//     setState(() {
//       _goals = goals;
//       _isLoading = false;
//     });
//   }

//   // Future<void> _toggleGoal(Goal goal) async {
//   //   // 1) Optimistically flip it in local state
//   //   final idx = _goals.indexWhere((g) => g.id == goal.id);
//   //   if (idx != -1) {
//   //     setState(() {
//   //       _goals[idx] = _goals[idx].copyWith(isActive: !goal.isActive);
//   //     });
//   //   }

//   //   try {
//   //     // 2) Persist server-side + bump timestamp (for the 2-min reminder)
//   //     await userCubit.completeGoal(goal);
//   //     await GoalProgressWriter.bumpGoalProgress(goal.id);
//   //   } catch (e) {
//   //     // 3) Revert on error
//   //     if (idx != -1) {
//   //       setState(() {
//   //         _goals[idx] = _goals[idx].copyWith(isActive: goal.isActive);
//   //       });
//   //     }
//   //     debugPrint('Toggle goal failed: $e');
//   //   } finally {
//   //     // 4) Refresh from source of truth
//   //     await _loadGoals();
//   //   }
//   // }

//   Future<void> _toggleSubtask({
//     required Goal goal,
//     required int index,
//     required bool done,
//   }) async {
//     // 1. Optimistic UI update
//     final gi = _goals.indexWhere((g) => g.id == goal.id);
//     List<Goal>? snapshotBefore;

//     if (gi != -1) {
//       snapshotBefore = List<Goal>.from(_goals);
//       final updatedDone = List<bool>.from(goal.subtasksDone);

//       // Extend array if needed
//       if (index >= updatedDone.length) {
//         updatedDone.length = index + 1;
//         for (var i = 0; i < updatedDone.length; i++) {
//           updatedDone[i] =
//               i < goal.subtasksDone.length ? goal.subtasksDone[i] : false;
//         }
//       }

//       updatedDone[index] = done;

//       setState(() {
//         _goals[gi] = goal.copyWith(subtasksDone: updatedDone);
//       });
//     }

//     try {
//       final uid = FirebaseAuth.instance.currentUser!.uid;

//       // 2. Update in Firestore - THIS TRIGGERS THE CLOUD FUNCTION!
//       await FirebaseService().updateGoalSubtask(
//         uid: uid,
//         goalId: goal.id,
//         index: index,
//         done: done,
//       );

//       debugPrint('✅ Subtask toggle successful');
//       if (done) {
//         debugPrint(
//             '⏰ Notification should arrive in 2 minutes at: ${DateTime.now().add(const Duration(minutes: 2))}');
//       }

//       // 3. Reload goals to get server state
//       await _loadGoals();
//     } catch (e) {
//       // 4. Revert optimistic change on error
//       if (snapshotBefore != null) {
//         setState(() => _goals = snapshotBefore!);
//       }

//       debugPrint('❌ Toggle subtask failed: $e');

//       // Show error to user
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to update subtask: $e'),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     }
//   }

//   // @override
//   // Widget build(BuildContext context) {
//   //   return Scaffold(
//   //     body: Container(
//   //       decoration: BoxDecoration(
//   //         gradient: LinearGradient(
//   //           begin: Alignment.topCenter,
//   //           end: Alignment.bottomCenter,
//   //           colors: [AppColors.primaryBlue, AppColors.primaryGreen],
//   //         ),
//   //       ),
//   //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
//   //       child: _isLoading
//   //           ? const Center(
//   //               child: CircularProgressIndicator(color: Colors.white),
//   //             )
//   //           : ListView.separated(
//   //               itemCount: _goals.length,
//   //               separatorBuilder: (_, __) => const SizedBox(height: 12),
//   //               itemBuilder: (context, i) {
//   //                 final goal = _goals[i];
//   //                 final total = goal.subtasks.length;
//   //                 final doneCount = goal.subtasksDone.where((d) => d).length;
//   //                 final progress =
//   //                     total == 0 ? 0.0 : (doneCount / total).clamp(0.0, 1.0);

//   //                 return _GoalCard(
//   //                   goal: goal,
//   //                   progress: progress,
//   //                   // onToggleGoal: () => _toggleGoal(goal),
//   //                   onToggleSubtask: (idx, v) =>
//   //                       _toggleSubtask(goal: goal, index: idx, done: v),
//   //                 );
//   //               },
//   //             ),
//   //     ),
//   //   );
//   // }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF006FFF),
//               Color(0xFF00AAF2),
//               Color(0xFF00E5E5),
//               Color(0xFF0BFF96),
//             ],
//             stops: [0.0, 0.24, 0.49, 1.0],
//           ),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
//         child: _isLoading
//             ? const Center(
//                 child: CircularProgressIndicator(color: Colors.white),
//               )
//             : _goals.isEmpty
//                 ? const Center(
//                     child: Text(
//                       'No goals yet.\nCreate your first goal to get started!',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         fontFamily: 'Montserrat',
//                       ),
//                     ),
//                   )
//                 : ListView.separated(
//                     itemCount: _goals.length,
//                     separatorBuilder: (_, __) => const SizedBox(height: 12),
//                     itemBuilder: (context, i) {
//                       final goal = _goals[i];
//                       final total = goal.subtasks.length;
//                       final doneCount =
//                           goal.subtasksDone.where((d) => d).length;
//                       final progress = total == 0
//                           ? 0.0
//                           : (doneCount / total).clamp(0.0, 1.0);

//                       return _GoalCard(
//                         goal: goal,
//                         progress: progress,
//                         onToggleSubtask: (idx, v) =>
//                             _toggleSubtask(goal: goal, index: idx, done: v),
//                       );
//                     },
//                   ),
//       ),
//     );
//   }
// }

// class _GoalCard extends StatefulWidget {
//   final Goal goal;
//   final double progress;
//   final void Function(int index, bool value) onToggleSubtask;

//   const _GoalCard({
//     required this.goal,
//     required this.progress,
//     required this.onToggleSubtask,
//   });

//   @override
//   State<_GoalCard> createState() => _GoalCardState();
// }

// class _GoalCardState extends State<_GoalCard> {
//   bool _expanded = false;

//   String _getSkillIcon(String skillKey) {
//     const map = {
//       'Communication': 'assets/communication2.png',
//       'Leadership': 'assets/leader.png',
//       'Teamwork': 'assets/team.png',
//       'Problem-Solving': 'assets/solve.png',
//       'Time Management': 'assets/time.png',
//       'Adaptability': 'assets/skill_adaptability.png',
//       'Emotional Intelligence': 'assets/skill_emotional_intelligence.png',
//       'Conflict Resolution': 'assets/conflict.png',
//       'Creativity': 'assets/creativity.png',
//       'Decision Making': 'assets/skill_decision_making.png',
//       'Critical Thinking': 'assets/skill_critical_thinking.png',
//       'Negotiation': 'assets/negotation.png',
//       'Active Listening': 'assets/active.png',
//       'Work Ethic': 'assets/skill_work_ethic.png',
//       'Interpersonal Skills': 'assets/inter.png',
//       'Stress Management': 'assets/stress.png',
//       'Networking': 'assets/networking.png',
//       'Coaching & Mentoring': 'assets/mentoring.png',
//       'Persuasion': 'assets/persuasion.png',
//       'Self-Motivation': 'assets/skill_self_motivation.png',
//     };
//     return map[skillKey] ?? 'assets/communication2.png';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final goal = widget.goal;
//     final subtasks = goal.subtasks;
//     final states = goal.subtasksDone;

//     return GestureDetector(
//       onTap: () => setState(() => _expanded = !_expanded),
//       child: Container(
//         padding: const EdgeInsets.all(3),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: Colors.white.withValues(alpha: 0.8),
//             width: 1.5,
//           ),
//         ),
//         child: Container(
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//               colors: [
//                 Color(0xFFFFFFFF),
//                 Color(0x4000E5E5),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Title + Icon
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       goal.title,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         fontFamily: 'Montserrat',
//                         fontSize: 17,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF0055CC),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Container(
//                     width: 44,
//                     height: 44,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: const Color(0xFF0077DD),
//                         width: 1.5,
//                       ),
//                     ),
//                     child: ClipOval(
//                       child: Padding(
//                         padding: const EdgeInsets.all(6),
//                         child: Image.asset(
//                           _getSkillIcon(goal.skill),
//                           fit: BoxFit.contain,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 6),
// // Skill chip
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF0055CC).withValues(alpha: 0.1),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: const Color(0xFF0055CC).withValues(alpha: 0.3),
//                   ),
//                 ),
//                 child: Text(
//                   goal.skill,
//                   style: const TextStyle(
//                     fontFamily: 'Montserrat',
//                     color: Color(0xFF0055CC),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               // Progress bar
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: LinearProgressIndicator(
//                   value: widget.progress,
//                   minHeight: 12,
//                   backgroundColor: Colors.white.withValues(alpha: 0.5),
//                   color: const Color(0xFF003399),
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: Text(
//                   '${(widget.progress * 100).round()}% complete',
//                   style: const TextStyle(
//                     fontFamily: 'Montserrat',
//                     color: Color(0xFF0055CC),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//               // Subtasks (expanded)
//               if (_expanded && subtasks.isNotEmpty) ...[
//                 const SizedBox(height: 8),
//                 ...List.generate(subtasks.length, (i) {
//                   final done = i < states.length ? states[i] : false;
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                     child: GestureDetector(
//                       onTap: () => widget.onToggleSubtask(i, !done),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 26,
//                             height: 26,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: done
//                                   ? const Color(0xFF2196F3)
//                                   : Colors.transparent,
//                               border: Border.all(
//                                 color: done
//                                     ? const Color(0xFF2196F3)
//                                     : const Color(0xFF0055CC)
//                                         .withValues(alpha: 0.5),
//                                 width: 1.5,
//                               ),
//                             ),
//                             child: done
//                                 ? const Icon(Icons.check,
//                                     size: 16, color: Colors.white)
//                                 : null,
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               subtasks[i],
//                               style: TextStyle(
//                                 fontFamily: 'Montserrat',
//                                 fontSize: 14,
//                                 color: const Color(0xFF0055CC)
//                                     .withValues(alpha: 0.8),
//                                 decoration:
//                                     done ? TextDecoration.lineThrough : null,
//                                 decorationColor: const Color(0xFF0055CC)
//                                     .withValues(alpha: 0.5),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }),
//               ],
//               if (_expanded && subtasks.isEmpty)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 8),
//                   child: Text(
//                     'No subtasks yet.',
//                     style: TextStyle(
//                       fontFamily: 'Montserrat',
//                       color: const Color(0xFF0055CC).withValues(alpha: 0.6),
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:softai/cubit/user_cubit.dart';
import 'package:softai/di/di.dart';
import 'package:softai/extensions/l10n_extension.dart';
import 'package:softai/model/goal.dart';
import 'package:softai/service/firebase_service.dart';

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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadGoals();
  }

// Add this — reload when screen becomes visible again
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

  final Map<String, String> _translations = {};
  bool _isTranslating = false;

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
                  "Translate the following text to Serbian (ekavica). Use correct Serbian grammar — proper cases, gender agreement, and natural phrasing. Return ONLY the translation in nominative case, nothing else."
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

  Future<void> _translateAllGoals() async {
    if (context.isEnglish) return;

    if (!mounted) return;
    setState(() => _isTranslating = true);

    for (final goal in _goals) {
      await _translate(goal.title);
      for (final subtask in goal.subtasks) {
        await _translate(subtask);
      }
    }

    if (mounted) setState(() => _isTranslating = false);
  }

  Future<void> _loadGoals() async {
    final goals = await userCubit.getGoals();
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
    }

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseService().updateGoalSubtask(
        uid: uid,
        goalId: goal.id,
        index: index,
        done: done,
      );

      await _loadGoals();
    } catch (e) {
      if (snapshotBefore != null) {
        setState(() => _goals = snapshotBefore!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update subtask: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
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
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
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

                    // Tabs
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

                    // Tab content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Active goals
                          _buildGoalList(activeGoals, l10n, isEmpty: false),
                          // Completed goals
                          _buildGoalList(completedGoals, l10n, isEmpty: false),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildGoalList(List<Goal> goals, dynamic l10n,
      {required bool isEmpty}) {
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
          translatedTitle: _translations[goal.title] ?? goal.title,
          translatedSubtasks:
              goal.subtasks.map((s) => _translations[s] ?? s).toList(),
          skillIcon: _getSkillIcon(goal.skill),
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
