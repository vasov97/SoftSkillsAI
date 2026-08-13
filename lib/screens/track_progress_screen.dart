// import 'package:cloud_functions/cloud_functions.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:softai/cubit/user_cubit.dart';
// import 'package:softai/di/di.dart';

// class TrackProgressScreen extends StatefulWidget {
//   const TrackProgressScreen({super.key});

//   @override
//   State<TrackProgressScreen> createState() => _TrackProgressScreenState();
// }

// class _TrackProgressScreenState extends State<TrackProgressScreen> {
//   late final userCubit;

//   List<String> assetNames = [
//     'communication.png', //
//     'leadership.png', //
//     'teamwork.png', //
//     'problem_solving.png', //

//     'time_management.png', //
//     'adapt.png', //
//     'emotion.png', //
//     'conflict2.png', //
//     'creative.png', //
//     'decision.png', //
//     'critical.png', //
//     'negotation2.png', //
//     'active2.png',
//     'work_ethic.png', //
//     'inter2.png', //
//     'stress2.png', //
//     'networking2.png', //
//     'mentor.png', //
//     'persuasion2.png', //
//     'self_motivation.png', //
//   ];

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
//   void initState() {
//     super.initState();
//     userCubit = locator<UserCubit>();
//     userCubit.loadUser();
//     Future.delayed(const Duration(milliseconds: 500), () {
//       _sendProgressNotification();
//     });
//   }

//   Future<void> _sendProgressNotification() async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;

//     try {
//       // Call Cloud Function to send progress notification
//       final callable =
//           FirebaseFunctions.instance.httpsCallable('sendProgressNotification');
//       final result = await callable.call({'uid': uid});

//       debugPrint('✅ Progress notification sent: ${result.data}');

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Progress notification sent!'),
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint('❌ Failed to send progress notification: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         scrolledUnderElevation: 0,
//         foregroundColor: Colors.white,
//         title: const Text(
//           "Track Progress",
//           style: TextStyle(
//             fontFamily: 'Montserrat',
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: const Color(0xFF006FFF),
//         centerTitle: true,
//       ),
//       body: Stack(
//         children: [
//           // Background gradient
//           Container(
//             width: double.infinity,
//             height: double.infinity,
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Color(0xFF006FFF),
//                   Color(0xFF00AAF2),
//                   Color(0xFF00E5E5),
//                   Color(0xFF0BFF96),
//                 ],
//                 stops: [0.0, 0.24, 0.49, 1.0],
//               ),
//             ),
//           ),

//           // Content
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: BlocBuilder<UserCubit, UserState>(
//                 bloc: userCubit,
//                 builder: (context, state) {
//                   if (state is UserLoading || state is UserInitial) {
//                     return const Center(
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                       ),
//                     );
//                   }

//                   if (state is UserError) {
//                     return Center(
//                       child: Text(
//                         state.message,
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     );
//                   }

//                   if (state is UserLoaded) {
//                     final user = state.user;
//                     final selectedSkills = user.selectedSkills;

//                     if (selectedSkills.isEmpty) {
//                       return const Center(
//                         child: Text(
//                           "No skills tracked yet.\nSelect skills to start tracking progress.",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontFamily: 'Montserrat',
//                             fontSize: 18,
//                           ),
//                         ),
//                       );
//                     }

//                     return ListView.separated(
//                       itemCount: selectedSkills.length,
//                       separatorBuilder: (_, __) => const SizedBox(height: 16),
//                       itemBuilder: (context, index) {
//                         final entry = selectedSkills.entries.elementAt(index);
//                         final skillName = entry.key;
//                         final progressFraction = entry.value; // e.g. 0.02
//                         final progressPercent = (progressFraction * 100)
//                             .clamp(0.0, 100.0); // Convert to % safely

//                         return Container(
//                           padding: const EdgeInsets.all(3),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(
//                               color: Colors.white.withValues(alpha: 0.8),
//                               width: 1.5,
//                             ),
//                           ),
//                           child: Container(
//                             padding: const EdgeInsets.all(14),
//                             decoration: BoxDecoration(
//                               gradient: const LinearGradient(
//                                 begin: Alignment.centerLeft,
//                                 end: Alignment.centerRight,
//                                 colors: [
//                                   Color(0xFFFFFFFF),
//                                   Color(0x4000E5E5),
//                                 ],
//                               ),
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Title + Icon row
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: Text(
//                                         skillName,
//                                         style: const TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                           color: Color(0xFF0055CC),
//                                           fontFamily: 'Montserrat',
//                                         ),
//                                       ),
//                                     ),
//                                     Container(
//                                       width: 44,
//                                       height: 44,
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         border: Border.all(
//                                           color: const Color(0xFF0077DD),
//                                           width: 1.5,
//                                         ),
//                                       ),
//                                       child: ClipOval(
//                                         child: Padding(
//                                           padding: const EdgeInsets.all(6),
//                                           child: Image.asset(
//                                             _getSkillIcon(skillName),
//                                             fit: BoxFit.contain,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 10),
//                                 // Progress bar
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: ClipRRect(
//                                         borderRadius: BorderRadius.circular(8),
//                                         child: LinearProgressIndicator(
//                                           value:
//                                               progressFraction.clamp(0.0, 1.0),
//                                           minHeight: 12,
//                                           backgroundColor: Colors.white
//                                               .withValues(alpha: 0.5),
//                                           color: const Color(0xFF003399),
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 10),
//                                     Text(
//                                       "${progressPercent.toStringAsFixed(1)}%",
//                                       style: const TextStyle(
//                                         color: Color(0xFF003399),
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w600,
//                                         fontFamily: 'Montserrat',
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   }

//                   return const SizedBox.shrink();
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softai/cubit/user_cubit.dart';
import 'package:softai/di/di.dart';
import 'package:softai/extensions/l10n_extension.dart';

class TrackProgressScreen extends StatefulWidget {
  const TrackProgressScreen({super.key});

  @override
  State<TrackProgressScreen> createState() => _TrackProgressScreenState();
}

class _TrackProgressScreenState extends State<TrackProgressScreen> {
  late final userCubit;

  static const List<Color> _progressColors = [
    Color(0xFF0066FF),
    Color(0xFF00CC88),
    Color(0xFF00AADD),
    Color(0xFF44BB66),
    Color(0xFF0088CC),
    Color(0xFF33DD99),
  ];

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
  void initState() {
    super.initState();
    userCubit = locator<UserCubit>();
    userCubit.loadUser();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
          child: BlocBuilder<UserCubit, UserState>(
            bloc: userCubit,
            builder: (context, state) {
              if (state is UserLoading || state is UserInitial) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (state is UserError) {
                return Center(
                  child: Text(
                    state.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                );
              }

              if (state is UserLoaded) {
                final user = state.user;
                final selectedSkills = user.selectedSkills;

                double overallProgress = 0;
                if (selectedSkills.isNotEmpty) {
                  overallProgress = selectedSkills.values
                          .fold<double>(0, (sum, v) => sum + v) /
                      selectedSkills.length;
                }
                final overallPercent =
                    (overallProgress * 100).clamp(0, 100).round();

                // Placeholder stats
                const int conversations = 0;
                const int completedExercises = 0;
                const int daysInARow = 0;
                final int activeGoals = selectedSkills.length;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      // Skillena AI header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Skillena',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 84, 204, 204),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'AI',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Text(
                        l10n.yourProgress,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Overview card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Left: circle + label
                            Column(
                              children: [
                                SizedBox(
                                  width: 110,
                                  height: 110,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: CustomPaint(
                                          painter: _CircularProgressPainter(
                                            progress:
                                                overallProgress.clamp(0, 1),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '$overallPercent%',
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF1A1A2E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.totalProgress,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),

                            // Right: stats
                            Expanded(
                              child: Column(
                                children: [
                                  _StatRow(
                                    icon: Icons.chat_bubble_outline,
                                    label: l10n.conversations,
                                    value: '$conversations',
                                    color: const Color(0xFF0066FF),
                                  ),
                                  const SizedBox(height: 14),
                                  _StatRow(
                                    icon: Icons.check_circle_outline,
                                    label: l10n.completedExercises,
                                    value: '$completedExercises',
                                    color: const Color(0xFF00CC88),
                                  ),
                                  const SizedBox(height: 14),
                                  _StatRow(
                                    icon: Icons.local_fire_department_outlined,
                                    label: l10n.daysInARow,
                                    value: '$daysInARow',
                                    color: const Color(0xFFFF8800),
                                  ),
                                  const SizedBox(height: 14),
                                  _StatRow(
                                    icon: Icons.gps_fixed,
                                    label: l10n.activeGoals,
                                    value: '$activeGoals',
                                    color: const Color(0xFF0088CC),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Skills section title
                      Text(
                        l10n.progressBySkills,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Skills card
                      if (selectedSkills.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l10n.noSkillsTracked,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 15,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: List.generate(
                              selectedSkills.length,
                              (index) {
                                final entry =
                                    selectedSkills.entries.elementAt(index);
                                final skillName = entry.key;
                                final fraction = entry.value;
                                final percent =
                                    (fraction * 100).clamp(0, 100).round();
                                final color = _progressColors[
                                    index % _progressColors.length];

                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: index < selectedSkills.length - 1
                                        ? 18
                                        : 0,
                                  ),
                                  child: Row(
                                    children: [
                                      // Icon
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: color.withValues(alpha: 0.12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Image.asset(
                                            _getSkillIcon(skillName),
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Name + bar
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    context.getSkillTranslation(
                                                        skillName, l10n),
                                                    style: const TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xFF1A1A2E),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text(
                                                  '$percent%',
                                                  style: TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color: color,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              child: LinearProgressIndicator(
                                                value: fraction.clamp(0.0, 1.0),
                                                minHeight: 10,
                                                backgroundColor:
                                                    Colors.grey.shade200,
                                                color: color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;

  _CircularProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Background track
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Gradient arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: const [
          Color(0xFF0066FF),
          Color(0xFF00BBDD),
          Color(0xFF00CC88),
        ],
      ).createShader(rect);

    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter old) =>
      old.progress != progress;
}
