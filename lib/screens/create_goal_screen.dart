// import 'package:flutter/material.dart';
// import 'package:softai/extensions/l10n_extension.dart';

// class CreateGoalScreen extends StatefulWidget {
//   const CreateGoalScreen({super.key});

//   @override
//   State<CreateGoalScreen> createState() => _CreateGoalScreenState();
// }

// class _CreateGoalScreenState extends State<CreateGoalScreen> {
//   final TextEditingController _titleController = TextEditingController();
//   String? _selectedSkill;

//   static const List<String> _skillsList = [
//     "Communication",
//     "Leadership",
//     "Teamwork",
//     "Problem-Solving",
//     "Time Management",
//     "Adaptability",
//     "Emotional Intelligence",
//     "Conflict Resolution",
//     "Creativity",
//     "Decision Making",
//     "Critical Thinking",
//     "Negotiation",
//     "Active Listening",
//     "Work Ethic",
//     "Interpersonal Skills",
//     "Stress Management",
//     "Networking",
//     "Coaching & Mentoring",
//     "Persuasion",
//     "Self-Motivation",
//   ];

//   @override
//   void dispose() {
//     _titleController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final l10n = context.l10n;

//     return Scaffold(
//       backgroundColor: const Color(0xFF006FFF),
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               'Skillena',
//               style: TextStyle(
//                 fontFamily: 'Montserrat',
//                 color: Colors.white,
//                 fontSize: 22,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//             const SizedBox(width: 6),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
//               decoration: BoxDecoration(
//                 color: const Color.fromARGB(255, 84, 204, 204),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Text(
//                 'AI',
//                 style: TextStyle(
//                   fontFamily: 'Montserrat',
//                   color: Colors.white,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         centerTitle: true,
//       ),
//       body: Stack(
//         children: [
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
//           SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Title
//                   Text(
//                     l10n.createNewGoal,
//                     style: const TextStyle(
//                       fontFamily: 'Montserrat',
//                       fontSize: 22,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     l10n.createGoalSubtitle,
//                     style: TextStyle(
//                       fontFamily: 'Montserrat',
//                       fontSize: 14,
//                       color: Colors.white.withValues(alpha: 0.7),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   // Goal title label
//                   Text(
//                     l10n.goalTitle,
//                     style: TextStyle(
//                       fontFamily: 'Montserrat',
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white.withValues(alpha: 0.7),
//                     ),
//                   ),
//                   const SizedBox(height: 8),

//                   // Goal title input
//                   Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: TextField(
//                       controller: _titleController,
//                       style: const TextStyle(
//                         fontFamily: 'Montserrat',
//                         fontSize: 15,
//                         color: Colors.black87,
//                       ),
//                       decoration: InputDecoration(
//                         hintText: l10n.addGoalTitle,
//                         hintStyle: TextStyle(
//                           fontFamily: 'Montserrat',
//                           fontSize: 15,
//                           color: Colors.grey.shade400,
//                         ),
//                         border: InputBorder.none,
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 14),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   // Select skill label
//                   Text(
//                     l10n.selectSkill,
//                     style: TextStyle(
//                       fontFamily: 'Montserrat',
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white.withValues(alpha: 0.7),
//                     ),
//                   ),
//                   const SizedBox(height: 12),

//                   // Skill chips
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: _skillsList.map((skill) {
//                       final isSelected = _selectedSkill == skill;
//                       return GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             _selectedSkill = isSelected ? null : skill;
//                           });
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 14, vertical: 10),
//                           decoration: BoxDecoration(
//                             color: isSelected
//                                 ? Colors.white
//                                 : Colors.white.withValues(alpha: 0.15),
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(
//                               color: isSelected
//                                   ? Colors.white
//                                   : Colors.white.withValues(alpha: 0.4),
//                               width: 1.5,
//                             ),
//                           ),
//                           child: Text(
//                             context.getSkillTranslation(skill, l10n),
//                             style: TextStyle(
//                               fontFamily: 'Montserrat',
//                               fontSize: 13,
//                               fontWeight: FontWeight.w600,
//                               color: isSelected
//                                   ? const Color(0xFF0055CC)
//                                   : Colors.white,
//                             ),
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                   const SizedBox(height: 32),

//                   // AI suggestion info
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withValues(alpha: 0.15),
//                       borderRadius: BorderRadius.circular(14),
//                       border: Border.all(
//                         color: Colors.white.withValues(alpha: 0.3),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.auto_awesome,
//                             color: Colors.white, size: 20),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             l10n.aiWillGenerateSubtasks,
//                             style: TextStyle(
//                               fontFamily: 'Montserrat',
//                               fontSize: 13,
//                               color: Colors.white.withValues(alpha: 0.8),
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 32),

//                   // Create button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 48,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         final title = _titleController.text.trim();
//                         if (title.isEmpty || _selectedSkill == null) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text(l10n.pleaseFillGoalFields),
//                               behavior: SnackBarBehavior.floating,
//                               backgroundColor: Colors.red.shade600,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                           );
//                           return;
//                         }
//                         // TODO: call AI to generate subtasks, save goal, navigate
//                         Navigator.of(context).pop({
//                           'title': title,
//                           'skill': _selectedSkill,
//                         });
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF0055CC),
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(24),
//                         ),
//                         elevation: 0,
//                       ),
//                       child: Text(
//                         l10n.createGoal,
//                         style: const TextStyle(
//                           fontFamily: 'Montserrat',
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),

//                   // Cancel
//                   SizedBox(
//                     width: double.infinity,
//                     child: TextButton(
//                       onPressed: () => Navigator.of(context).pop(),
//                       child: Text(
//                         l10n.cancel,
//                         style: const TextStyle(
//                           fontFamily: 'Montserrat',
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Avatar bottom right
//           Positioned(
//             bottom: 24,
//             right: 16,
//             child: Image.asset(
//               'assets/avatar.png',
//               width: 80,
//               height: 80,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:softai/cubit/user_cubit.dart';
import 'package:softai/di/di.dart';
import 'package:softai/extensions/l10n_extension.dart';

class CreateGoalScreen extends StatefulWidget {
  final String apiKey;

  const CreateGoalScreen({
    super.key,
    required this.apiKey,
  });

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final TextEditingController _titleController = TextEditingController();
  String? _selectedSkill;
  bool _isCreating = false;

  late final UserCubit userCubit;

  static const List<String> _skillsList = [
    "Communication",
    "Leadership",
    "Teamwork",
    "Problem-Solving",
    "Time Management",
    "Adaptability",
    "Emotional Intelligence",
    "Conflict Resolution",
    "Creativity",
    "Decision Making",
    "Critical Thinking",
    "Negotiation",
    "Active Listening",
    "Work Ethic",
    "Interpersonal Skills",
    "Stress Management",
    "Networking",
    "Coaching & Mentoring",
    "Persuasion",
    "Self-Motivation",
  ];

  @override
  void initState() {
    super.initState();
    userCubit = locator<UserCubit>();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<List<String>> _generateSubtasks(String title, String skill) async {
    final isSerbian = !context.isEnglish;

    final system = isSerbian
        ? '''
Ti si ekspert za meke veštine i planiranje zadataka.
Vrati SAMO strogi JSON (bez teksta) za podzadatke cilja.
VAŽNO: Piši isključivo na srpskom jeziku, ekavica. Ne koristi ijekavicu ili hrvatski.
'''
        : '''
You are an expert soft-skills coach and task planner.
Return ONLY strict JSON (no prose) for the subtasks of a goal.
''';

    final userPrompt = '''
Goal title: "$title"
Primary skill: "$skill"

Constraints for subtasks:
- Exactly 5 items.
- Each is a short, actionable step (max ~8–10 words).
- Concrete and behavioral (not vague).
- Use imperative tone (e.g., "Draft a message", "Rehearse out loud").

Output JSON schema:
{"subtasks": ["...", "...", "...", "...", "..."]}
Return ONLY the JSON. No extra text.
''';

    try {
      final response = await http.post(
        Uri.parse("https://api.openai.com/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer ${widget.apiKey}",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "model": "gpt-4o-mini",
          "temperature": 0.3,
          "response_format": {"type": "json_object"},
          "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": userPrompt},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        final parsed = json.decode(content) as Map<String, dynamic>;
        final list = (parsed['subtasks'] as List)
            .map((e) => e.toString().trim())
            .where((s) => s.isNotEmpty)
            .toList();

        if (list.length == 5) return list;
      }
    } catch (_) {}

    // Fallback
    return isSerbian
        ? [
            "Jasno definiši željeni ishod",
            "Napravi listu prepreka i rešenja",
            "Napiši prvi konkretan korak",
            "Zakaži akciju u kalendaru",
            "Podeli cilj sa nekim za podršku",
          ]
        : [
            "Define the desired outcome clearly",
            "List obstacles and quick mitigations",
            "Draft first concrete action step",
            "Schedule action in calendar today",
            "Share goal with an accountability buddy",
          ];
  }

  Future<void> _createGoal() async {
    final title = _titleController.text.trim();
    final skill = _selectedSkill;
    final l10n = context.l10n;

    if (title.isEmpty || skill == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseFillGoalFields),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      // 1. Generate subtasks
      final subtasks = await _generateSubtasks(title, skill);

      // 2. Save goal
      await userCubit.addGoal(title, skill, subtasks);

      if (!mounted) return;

      // 3. Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF0055CC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.goalAddedMessage(
                    title,
                    context.getSkillTranslation(skill, l10n),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      // 4. Pop back with result
      Navigator.of(context).pop({
        'title': title,
        'skill': skill,
        'subtasks': subtasks,
      });
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
      if (mounted) setState(() => _isCreating = false);
    }
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    l10n.createNewGoal,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.createGoalSubtitle,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Goal title label
                  Text(
                    l10n.goalTitle,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Goal title input
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
                        hintText: l10n.addGoalTitle,
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
                  const SizedBox(height: 24),

                  // Select skill label
                  Text(
                    l10n.selectSkill,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Skill chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skillsList.map((skill) {
                      final isSelected = _selectedSkill == skill;
                      return GestureDetector(
                        onTap: _isCreating
                            ? null
                            : () {
                                setState(() {
                                  _selectedSkill = isSelected ? null : skill;
                                });
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            context.getSkillTranslation(skill, l10n),
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF0055CC)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // AI info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 63, 63, 63)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color.fromARGB(255, 48, 48, 48)
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.aiWillGenerateSubtasks,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              color: const Color.fromARGB(255, 22, 22, 22)
                                  .withValues(alpha: 0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Create button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isCreating ? null : _createGoal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0055CC),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: _isCreating
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              l10n.createGoal,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Cancel
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _isCreating
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(
                        l10n.cancel,
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

          // Avatar
          Positioned(
            bottom: 24,
            right: 16,
            child: Image.asset(
              'assets/avatar.png',
              width: 80,
              height: 80,
            ),
          ),
        ],
      ),
    );
  }
}
