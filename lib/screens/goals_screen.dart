// import 'package:flutter/material.dart';
// import 'package:softai/cubit/user_cubit.dart';
// import 'package:softai/di/di.dart';
// import 'package:softai/model/goal.dart';
// import 'package:softai/theme/app_colors.dart';

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

//   Future<void> _toggleGoal(Goal goal) async {
//     await userCubit.completeGoal(goal);
//     await _loadGoals(); // refresh list
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               AppColors.primaryBlue,
//               AppColors.primaryGreen,
//             ],
//           ),
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
//         child: _isLoading
//             ? const Center(
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                 ),
//               )
//             : ListView(
//                 children: _goals.map((goal) {
//                   return CheckboxListTile(
//                     value: goal.isActive,
//                     onChanged: goal.isActive ? null : (_) => _toggleGoal(goal),
//                     title: Text(
//                       goal.title,
//                       style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                           color: Colors.white,
//                           fontFamily: 'Montserrat'),
//                     ),
//                     subtitle: Text(
//                       goal.skill,
//                       style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.white70,
//                           fontFamily: 'Montserrat'),
//                     ),
//                     checkColor: Colors.white,
//                     activeColor: Colors.greenAccent,
//                   );
//                 }).toList(),
//               ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:softai/cubit/user_cubit.dart';
import 'package:softai/di/di.dart';
import 'package:softai/model/goal.dart';
import 'package:softai/theme/app_colors.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final userCubit = locator<UserCubit>();
  List<Goal> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final goals = await userCubit.getGoals();
    setState(() {
      _goals = goals;
      _isLoading = false;
    });
  }

  Future<void> _toggleGoal(Goal goal) async {
    await userCubit.completeGoal(goal);
    await _loadGoals(); // refresh list
  }

  Future<void> _toggleSubtask({
    required Goal goal,
    required int index,
    required bool done,
  }) async {
    try {
      await userCubit.toggleSkill(goalId: goal.id, index: index, done: done);
      await _loadGoals();
    } catch (_) {
      // Fallback UI-only toggle if backend method not yet implemented
      setState(() {
        final i = _goals.indexWhere((g) => g.id == goal.id);
        if (i != -1) {
          final g = _goals[i];
          final updated = List<bool>.from(g.subtasksDone);
          if (index >= 0 && index < updated.length) {
            updated[index] = done;
          }
          _goals[i] = Goal(
            id: g.id,
            title: g.title,
            skill: g.skill,
            isActive: g.isActive,
            subtasks: g.subtasks,
            createdAt: DateTime.now(),
            subtasksDone: updated,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryBlue, AppColors.primaryGreen],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : ListView.separated(
                itemCount: _goals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final goal = _goals[i];
                  final total = goal.subtasks.length;
                  final doneCount = goal.subtasksDone.where((d) => d).length;
                  final progress =
                      total == 0 ? 0.0 : (doneCount / total).clamp(0.0, 1.0);

                  return _GoalCard(
                    goal: goal,
                    progress: progress,
                    onToggleGoal: () => _toggleGoal(goal),
                    onToggleSubtask: (idx, v) =>
                        _toggleSubtask(goal: goal, index: idx, done: v),
                  );
                },
              ),
      ),
    );
  }
}

class _GoalCard extends StatefulWidget {
  final Goal goal;
  final double progress;
  final VoidCallback onToggleGoal;
  final void Function(int index, bool value) onToggleSubtask;

  const _GoalCard({
    required this.goal,
    required this.progress,
    required this.onToggleGoal,
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          listTileTheme: const ListTileThemeData(iconColor: Colors.white),
        ),
        child: ExpansionTile(
          key: PageStorageKey('goal-${goal.id}'),
          initiallyExpanded: false,
          onExpansionChanged: (v) => setState(() => _expanded = v),
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          collapsedIconColor: Colors.white,
          iconColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title & quick-complete
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      goal.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Mark goal complete (keeps your existing API)
                  Checkbox(
                    value: goal.isActive, // your original field
                    onChanged:
                        goal.isActive ? null : (_) => widget.onToggleGoal(),
                    // NOTE: you used isActive to disable the toggle when true.
                    // If you actually want "completed" semantics, invert or rename in your model.
                    checkColor: Colors.white,
                    activeColor: Colors.greenAccent,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Skill chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  goal.skill,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: widget.progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.18),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.greenAccent.withOpacity(0.9),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(widget.progress * 100).round()}% complete',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          children: [
            if (subtasks.isEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Text(
                  'No subtasks yet.',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  children: List.generate(subtasks.length, (i) {
                    final done = i < states.length ? states[i] : false;
                    return CheckboxListTile(
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      value: done,
                      onChanged: (v) => widget.onToggleSubtask(i, v ?? false),
                      title: Text(
                        subtasks[i],
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontSize: 14,
                          decoration: done ? TextDecoration.lineThrough : null,
                          decorationColor: Colors.white70,
                        ),
                      ),
                      checkColor: Colors.white,
                      activeColor: Colors.greenAccent,
                    );
                  }),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
