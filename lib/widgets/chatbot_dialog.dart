import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:softai/cubit/user_cubit.dart';
import 'package:softai/di/di.dart';
import 'package:softai/theme/app_colors.dart';

class ChatBotDialog extends StatefulWidget {
  final String apiKey;
  const ChatBotDialog({super.key, required this.apiKey});

  @override
  State<ChatBotDialog> createState() => _ChatBotDialogState();
}

class _ChatBotDialogState extends State<ChatBotDialog> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  late final userCubit;

  @override
  void initState() {
    super.initState();
    userCubit = locator<UserCubit>();
    _messages.add({
      "role": "assistant",
      "text": "Hi! I’m your soft skills coach. How can I help you today?"
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({"role": "user", "text": text});
      _isLoading = true;
    });
    _controller.clear();

    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer ${widget.apiKey}",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "model": "gpt-4-turbo",
        "messages": [
          {
            "role": "system",
            "content": '''
You are a concise mentor for soft skills.
Always respond with exactly 5 short, clear tips in bullet point format.
Each tip should be 1 sentence, and avoid repetition.
''',
          },
          ..._messages.map((m) => {"role": m["role"], "content": m["text"]}),
          {"role": "user", "content": text},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final reply = data['choices'][0]['message']['content'];
      setState(() {
        _messages.add({"role": "assistant", "text": reply});
        _isLoading = false;
      });
    } else {
      setState(() {
        _messages.add({"role": "assistant", "text": "Error: ${response.body}"});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      backgroundColor: Colors.transparent, // Important for gradient border
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryGreen,
              AppColors.primaryBlue,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(3), // Thickness of the border
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // Inner dialog background
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with avatar and Add Goal button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Image.asset(
                        'assets/avatar.png',
                        width: 48,
                        height: 48,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _openGoalDialog(context),
                      icon: Icon(
                        Icons.add,
                        color: AppColors.primaryBlue,
                        size: 24,
                      ),
                      label: const Text(
                        "Add Goal",
                        style: TextStyle(
                            color: Color(0xFF007BFF),
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            fontFamily: 'Montserrat'),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 3,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGreen,
                      AppColors.primaryGreen,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  // borderRadius: BorderRadius.circular(16),
                ),
              ),
              // Chat messages
              SizedBox(
                height: 300,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isUser = msg["role"] == "user";
                    final isFirstAssistantMessage =
                        index == 0 && msg["role"] == "assistant";

                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.blue : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          msg["text"]!,
                          style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                              fontSize: isFirstAssistantMessage ? 20 : 18,
                              fontWeight: isFirstAssistantMessage
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontFamily: 'Montserrat'),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              // Input field
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Ask about soft skills...",
                          hintStyle: TextStyle(
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: AppColors.primaryBlue,
                        ),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Future<void> _openGoalDialog(BuildContext context) async {
  //   final TextEditingController goalTitleController = TextEditingController();

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) {
  //       return Dialog(
  //         backgroundColor: Colors.transparent,
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //         child: Container(
  //           decoration: BoxDecoration(
  //             gradient: LinearGradient(
  //               colors: [AppColors.primaryBlue, AppColors.primaryGreen],
  //               begin: Alignment.topCenter,
  //               end: Alignment.bottomCenter,
  //             ),
  //             borderRadius: BorderRadius.circular(16),
  //           ),
  //           padding: const EdgeInsets.all(3), // Border thickness
  //           child: Container(
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(14),
  //             ),
  //             padding: const EdgeInsets.all(20),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Text(
  //                   'Add New Goal',
  //                   style: TextStyle(
  //                     fontFamily: 'Montserrat',
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.bold,
  //                     color: AppColors.primaryBlue,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 16),
  //                 TextField(
  //                   controller: goalTitleController,
  //                   decoration: InputDecoration(
  //                     hintText: 'Enter goal title',
  //                     hintStyle: const TextStyle(
  //                       fontFamily: 'Montserrat',
  //                       fontSize: 16,
  //                       color: Colors.black45,
  //                     ),
  //                     border: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                       borderSide: BorderSide(color: AppColors.primaryBlue),
  //                     ),
  //                     focusedBorder: OutlineInputBorder(
  //                       borderRadius: BorderRadius.circular(8),
  //                       borderSide:
  //                           BorderSide(color: AppColors.primaryBlue, width: 2),
  //                     ),
  //                   ),
  //                   style: const TextStyle(
  //                     fontFamily: 'Montserrat',
  //                     fontSize: 16,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 20),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.end,
  //                   children: [
  //                     TextButton(
  //                       onPressed: () => Navigator.pop(context),
  //                       child: const Text(
  //                         'Cancel',
  //                         style: TextStyle(
  //                           fontFamily: 'Montserrat',
  //                           fontSize: 16,
  //                           color: Colors.grey,
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 8),
  //                     ElevatedButton(
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: AppColors.primaryBlue,
  //                         foregroundColor: Colors.white,
  //                         padding: const EdgeInsets.symmetric(
  //                             horizontal: 20, vertical: 12),
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.circular(8),
  //                         ),
  //                       ),
  //                       onPressed: () async {
  //                         final goalTitle = goalTitleController.text.trim();
  //                         if (goalTitle.isEmpty) return;

  //                         Navigator.pop(context);

  //                         final matchedSkill =
  //                             await _inferSkillFromChat(goalTitle);

  //                         if (!mounted) return;

  //                         if (matchedSkill != null) {
  //                           await userCubit.addGoal(goalTitle, matchedSkill);
  //                           if (mounted) {
  //                             ScaffoldMessenger.of(context).showSnackBar(
  //                               SnackBar(
  //                                   content: Text(
  //                                       'Goal added under "$matchedSkill"')),
  //                             );
  //                           }
  //                         } else {
  //                           if (mounted) {
  //                             ScaffoldMessenger.of(context).showSnackBar(
  //                               const SnackBar(
  //                                   content: Text('Could not match a skill.')),
  //                             );
  //                           }
  //                         }
  //                       },
  //                       child: const Text(
  //                         'Add',
  //                         style: TextStyle(
  //                           fontFamily: 'Montserrat',
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
  Future<void> _openGoalDialog(BuildContext parentContext) async {
    final TextEditingController goalTitleController = TextEditingController();

    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.primaryGreen],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add New Goal',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: goalTitleController,
                    decoration: InputDecoration(
                      hintText: 'Enter goal title',
                      hintStyle: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                        color: Colors.black45,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.primaryBlue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: AppColors.primaryBlue, width: 2),
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          final goalTitle = goalTitleController.text.trim();
                          if (goalTitle.isEmpty) return;

                          Navigator.of(dialogContext).pop();

                          // 1) Infer skill
                          final matchedSkill =
                              await _inferSkillFromChat(goalTitle);
                          if (!mounted) return;

                          if (matchedSkill == null) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              const SnackBar(
                                  content: Text('Could not match a skill.')),
                            );
                            return;
                          }

                          // 2) Generate 5 subtasks using current chat context
                          final subtasks = await _generateSubtasksFromChat(
                              goalTitle, matchedSkill);

                          // 3) Save goal (optional, keeps your current behavior)
                          await userCubit.addGoal(
                            goalTitle,
                            matchedSkill,
                            subtasks,
                          );

                          // 4) Navigate to Goal page with full data
                          final goalDraft = <String, dynamic>{
                            'title': goalTitle,
                            'skill': matchedSkill,
                            'subtasks': subtasks, // List<String> length = 5
                          };

                          if (!mounted) return;
                          Navigator.pushNamed(parentContext, '/goal',
                              arguments: goalDraft);

                          if (mounted) {
                            ScaffoldMessenger.of(parentContext).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Goal added under "$matchedSkill"')),
                            );
                          }
                        },
                        child: const Text(
                          'Add',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Creates 5 short, actionable subtasks tailored to the goal and recent chat.
  /// Returns a List<String> with length==5. Falls back to reasonable defaults.
  Future<List<String>> _generateSubtasksFromChat(
      String title, String skill) async {
    // Build a compact view of recent chat for context (last ~8 messages max).
    final recent = _messages.length <= 8
        ? _messages
        : _messages.sublist(_messages.length - 8);

    // We strictly require JSON so it’s easy to parse.
    final system = '''
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
- Tailored to the chat context and this specific goal.
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
            // pass a thin slice of the chat as context
            ...recent.map((m) => {
                  "role": m["role"],
                  "content": m["text"],
                }),
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
            .toList();

        // Guardrails: ensure exactly 5 non-empty strings
        final clean = list.where((s) => s.isNotEmpty).toList();
        if (clean.length == 5) return clean;
      }
    } catch (_) {
      // swallow and fallback
    }

    // Fallback subtasks when model/parse fails
    return [
      "Define the desired outcome clearly",
      "List obstacles and quick mitigations",
      "Draft first concrete action step",
      "Schedule action in calendar today",
      "Share goal with an accountability buddy",
    ];
  }

  Future<String?> _inferSkillFromChat(String title) async {
    const skillsList = [
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
      "Self-Motivation"
    ];

    final prompt = '''
Given the following goal title: "$title"
Choose the most relevant skill from this list:
${skillsList.join(", ")}
Return only the exact skill name.
''';

    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer ${widget.apiKey}",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "model": "gpt-4-turbo",
        "messages": [
          {
            "role": "system",
            "content": "You are a soft skills expert assistant."
          },
          {"role": "user", "content": prompt},
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final content = data['choices'][0]['message']['content'];
      return skillsList
              .firstWhere(
                (skill) => content.trim().contains(skill),
                orElse: () => "",
              )
              .isEmpty
          ? null
          : content.trim();
    } else {
      return null;
    }
  }
}
