import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:softai/cubit/user_cubit.dart';
import 'package:softai/di/di.dart';
import 'package:softai/extensions/l10n_extension.dart';

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
  bool _greetingAdded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_greetingAdded) {
      _greetingAdded = true;
      _messages.add({
        "role": "assistant",
        "text": context.isEnglish
            ? "Hi! I'm your soft skills coach. How can I help you today?"
            : "Zdravo! Ja sam tvoj trener za meke veštine. Kako mogu da ti pomognem danas?"
      });
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    userCubit = locator<UserCubit>();
    _messages.add({
      "role": "assistant",
      "text": "Hi! I'm your soft skills coach. How can I help you today?"
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
            "content": context.isEnglish
                ? '''
You are a concise mentor for soft skills.
Always respond with exactly 5 short, clear tips in bullet point format.
Each tip should be 1 sentence, and avoid repetition.
'''
                : '''
Ti si koncizan mentor za meke veštine.
Uvek odgovaraj sa tačno 5 kratkih, jasnih saveta u formatu nabrajanja.
Svaki savet treba da bude 1 rečenica, bez ponavljanja.
VAŽNO: Piši isključivo na srpskom jeziku, ekavica (npr. "rečenica" NE "riječ", "vreme" NE "vrijeme", "potrebno" NE "potrebno"). Ne koristi ijekavicu ili hrvatski.
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      backgroundColor: const Color.fromARGB(0, 89, 89, 89),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main dialog container
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 1.5,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 157, 243, 243),
                    Color.fromARGB(255, 150, 234, 224),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header - Add Goal button
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 12, top: 12, right: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 243, 243, 244),
                                Color.fromARGB(0, 242, 244, 243),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: GestureDetector(
                            onTap: () => _openGoalDialog(context),
                            child: const Row(
                              children: [
                                Text(
                                  '+',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0055CC),
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Add Goal',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0055CC),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Chat messages
                  Flexible(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isUser = msg["role"] == "user";

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: isUser
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Bot icon (left side)
                              if (!isUser) ...[
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF0077DD),
                                    border: Border.all(
                                      color: const Color.fromARGB(
                                          255, 247, 248, 249),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Image.asset(
                                        'assets/avatar.png',
                                        fit: BoxFit.contain,
                                        // color: Colors.white,
                                        //colorBlendMode: BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              // Message bubble
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: isUser
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFF007BFF),
                                              Color(0xFF00C6FF),
                                            ],
                                          )
                                        : const LinearGradient(
                                            colors: [
                                              Color(0xFFFFFFFF),
                                              Color(0xFFEEFAFA),
                                            ],
                                          ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: isUser
                                        ? null
                                        : Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.6),
                                            width: 1,
                                          ),
                                  ),
                                  child: Text(
                                    msg["text"]!,
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      color: isUser
                                          ? Colors.white
                                          : Colors.black87,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              // User icon (right side)
                              if (isUser) ...[
                                const SizedBox(width: 6),
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF0077DD),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: Color(0xFF0077DD),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF0055CC),
                        ),
                      ),
                    ),

                  // Input field
                  // Input field
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 246, 247, 247),
                            Color.fromARGB(0, 242, 243, 243),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Ask about soft skills',
                                hintStyle: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                  color: Color(0xFF0055CC),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                border: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFF0077DD)),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFF0077DD)),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFF0055CC)),
                                ),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: _sendMessage,
                            icon: const Icon(
                              Icons.send,
                              color: Color(0xFF0055CC),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Avatar positioned on top-right of dialog
          Positioned(
            top: -36,
            right: 12,
            child: Image.asset(
              'assets/avatar.png',
              width: 72,
              height: 72,
            ),
          ),
        ],
      ),
    );
  }

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
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 1.5,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF4DD9E8),
                    Color(0xFF80F0D0),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.addNewGoal,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0055CC),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 246, 247, 247),
                          Color.fromARGB(0, 242, 243, 243),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: goalTitleController,
                      decoration: InputDecoration(
                        hintText: 'Enter goal title',
                        hintStyle: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          color: Color(0xFF0055CC),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF0077DD)),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF0077DD)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF0055CC)),
                        ),
                        // focusedBorder: OutlineInputBorder(
                        //   borderRadius: BorderRadius.circular(8),
                        //   borderSide: const BorderSide(
                        //       color: Color(0xFF0055CC), width: 2),
                        // ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
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
                          backgroundColor: const Color(0xFF0055CC),
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
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.red.shade600,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 16),
                                content: const Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: Colors.white, size: 22),
                                    SizedBox(width: 10),
                                    Text(
                                      'Could not match a skill.',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                            return;
                          }

                          // 2) Generate 5 subtasks using current chat context
                          final subtasks = await _generateSubtasksFromChat(
                              goalTitle, matchedSkill);

                          // 3) Save goal
                          await userCubit.addGoal(
                            goalTitle,
                            matchedSkill,
                            subtasks,
                          );

                          // 4) Navigate to Goal page with full data
                          final goalDraft = <String, dynamic>{
                            'title': goalTitle,
                            'skill': matchedSkill,
                            'subtasks': subtasks,
                          };

                          if (!mounted) return;
                          ScaffoldMessenger.of(parentContext).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: const Color(0xFF0055CC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Colors.white, size: 22),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      context.l10n.goalAddedMessage(
                                        goalTitle,
                                        context.getSkillTranslation(
                                            matchedSkill, context.l10n),
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
                          Navigator.pushNamed(parentContext, '/goal',
                              arguments: goalDraft);
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

  Future<List<String>> _generateSubtasksFromChat(
      String title, String skill) async {
    final recent = _messages.length <= 8
        ? _messages
        : _messages.sublist(_messages.length - 8);

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

        final clean = list.where((s) => s.isNotEmpty).toList();
        if (clean.length == 5) return clean;
      }
    } catch (_) {}

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
            "content": context.isEnglish
                ? "You are a soft skills expert assistant."
                : "Ti si ekspert za meke veštine. Odgovaraj na srpskom, ekavica."
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
