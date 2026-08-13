import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:softai/cubit/user_cubit.dart';
import 'package:softai/di/di.dart';
import 'package:softai/extensions/l10n_extension.dart';
import 'package:softai/model/user.dart';
import 'package:softai/res/quotes.dart';
import 'package:softai/screens/chat_screen.dart';

class SkillDetailScreen extends StatefulWidget {
  final Map<String, double> skills;
  final UserModel user;
  const SkillDetailScreen({
    super.key,
    required this.skills,
    required this.user,
  });

  @override
  State<SkillDetailScreen> createState() => _SkillDetailScreenState();
}

class _SkillDetailScreenState extends State<SkillDetailScreen> {
  String get apiKey => dotenv.env['OPEN_API_KEY'] ?? '';
  final String apiUrl = "https://api.openai.com/v1/chat/completions";

  String? title;
  List<String> tips = [];
  List<String> _extraTips = [];
  bool isLoading = true;
  bool _loadingMore = false;
  String? error;
  int currentIndex = 0;
  int _quoteIndex = 0;
  Timer? _quoteTimer;
  List<MapEntry<String, double>> get skillsList =>
      widget.skills.entries.toList();
  late final UserCubit userCubit;
  bool isSaved = false;
  late bool isEnglish;

  String get currentSkill => skillsList[currentIndex].key;

  @override
  void initState() {
    super.initState();
    userCubit = locator<UserCubit>();

    _quoteTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      setState(() {
        _quoteIndex = (_quoteIndex + 1) % motivationalTextsEn.length;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isEnglish = context.isEnglish;

    if (currentIndex < 0 || currentIndex >= skillsList.length) {
      debugPrint(
          '❌ Invalid currentIndex: $currentIndex (skillsList length: ${skillsList.length})');
      return;
    }

    fetchSkillTips();
  }

  @override
  void dispose() {
    _quoteTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchSkillTips() async {
    setState(() {
      isLoading = true;
      error = null;
      _extraTips = [];
      isSaved = false;
    });

    final isEnglish = context.isEnglish;

    final prompt = isEnglish
        ? "Provide advice and tips for the skill: $currentSkill. "
            "Format the response exactly as:\n"
            "Title: [One engaging sentence about the skill]\n"
            "Tips:\n"
            "- [Tip 1, one short actionable sentence]\n"
            "- [Tip 2, one short actionable sentence]\n"
            "- [Tip 3, one short actionable sentence]\n"
            "- [Tip 4, one short actionable sentence]\n"
            "- [Tip 5, one short actionable sentence]\n"
            "Do not add anything else."
        : "Daj savete i tehnike za veštinu: $currentSkill. "
            "Format odgovora tačno kao:\n"
            "Naslov: [Jedna zanimljiva rečenica o veštini]\n"
            "Saveti:\n"
            "- [Savet 1, kratka praktična rečenica]\n"
            "- [Savet 2, kratka praktična rečenica]\n"
            "- [Savet 3, kratka praktična rečenica]\n"
            "- [Savet 4, kratka praktična rečenica]\n"
            "- [Savet 5, kratka praktična rečenica]\n"
            "Ne dodaj ništa više.";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "model": "gpt-4-turbo",
          "max_tokens": 300,
          "messages": [
            {
              "role": "system",
              "content": isEnglish
                  ? "You are a soft skills mentor. Provide structured advice for improving soft skills."
                  : "Ti si mentor za soft veštine. Daj strukturisane savete za poboljšanje soft veština. Piši isključivo na srpskom, ekavica."
            },
            {"role": "user", "content": prompt}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        final parsed = _parseSkillResponse(content, isEnglish: isEnglish);

        setState(() {
          title = parsed['title'];
          tips = parsed['tips'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Failed to fetch tips: ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Error: $e";
        isLoading = false;
      });
    }
  }

  Map<String, dynamic> _parseSkillResponse(String content,
      {required bool isEnglish}) {
    final titleRegex =
        isEnglish ? RegExp(r'Title:\s*(.*)') : RegExp(r'Naslov:\s*(.*)');
    final tipsRegex = RegExp(r'-\s*(.*)');

    final titleMatch = titleRegex.firstMatch(content);
    final tipsMatches = tipsRegex.allMatches(content);

    final parsedTitle = titleMatch != null ? titleMatch.group(1) : '';
    final parsedTips = tipsMatches.map((m) => m.group(1) ?? '').toList();

    return {
      "title": parsedTitle,
      "tips": parsedTips,
    };
  }

  Future<void> _loadMoreTips() async {
    setState(() => _loadingMore = true);

    final allTips = [...tips, ..._extraTips];
    final isSerbian = !context.isEnglish;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "model": "gpt-4o-mini",
          "max_tokens": 300,
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
                  ? 'Daj mi tačno 5 NOVIH saveta o "$currentSkill", različitih od ovih:\n${allTips.join("\n")}\n\nFormat: svaki savet na novom redu sa crticom ispred, bez numeracije, bez dodatnog teksta.'
                  : 'Give me exactly 5 NEW tips about "$currentSkill", different from these:\n${allTips.join("\n")}\n\nFormat: each tip on a new line with a dash prefix, no numbering, no extra text.',
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        final newTips = content
            .split('\n')
            .map((line) => line
                .replaceAll(RegExp(r'^[-•]\s*'), '')
                .replaceAll(RegExp(r'^\d+[\.\)]\s*'), '')
                .trim())
            .where((line) => line.isNotEmpty)
            .take(5)
            .toList();

        setState(() {
          _extraTips.addAll(newTips);
          _loadingMore = false;
        });
      } else {
        setState(() => _loadingMore = false);
      }
    } catch (_) {
      setState(() => _loadingMore = false);
    }
  }

  void _teachMeMore() {
    final allTips = [...tips, ..._extraTips];
    final tipsFormatted = allTips
        .asMap()
        .entries
        .map((e) => '${e.key + 1}. ${e.value}')
        .join('\n');

    final now = TimeOfDay.now().format(context);

    final initialMessages = <Map<String, String>>[
      {
        "role": "user",
        "text": context.isEnglish
            ? "Teach me about $currentSkill"
            : "Nauči me o ${context.getSkillTranslation(currentSkill, context.l10n)}",
        "time": now,
      },
      {
        "role": "assistant",
        "text": context.isEnglish
            ? "Here are tips for $currentSkill:\n\n$tipsFormatted\n\nWant me to explain any of these in more detail?"
            : "Evo saveta za ${context.getSkillTranslation(currentSkill, context.l10n)}:\n\n$tipsFormatted\n\nŽeliš li da objasnim neki od ovih detaljnije?",
        "time": now,
      },
    ];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          apiKey: apiKey,
          initialMessages: initialMessages,
        ),
      ),
    );
  }

  Future<void> _handleNext() async {
    final currentSkillName = skillsList[currentIndex].key;

    if (currentIndex < skillsList.length - 1) {
      setState(() {
        currentIndex++;
      });
      fetchSkillTips();
    } else {
      try {
        await userCubit.updateSoftSkillProgress(
          skillName: currentSkillName,
          progressDelta: 0.02,
        );
      } catch (e) {
        debugPrint("Failed to update skill progress: $e");
      }

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final skill = currentSkill;
    final quotes = isEnglish ? motivationalTextsEn : motivationalTextsSr;
    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          actions: [
            BlocBuilder<UserCubit, UserState>(
              bloc: userCubit,
              builder: (context, state) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.save,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_outline,
                        color: isSaved ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        if (title != null) {
                          userCubit.saveLessonForSkill(title!, tips);
                          setState(() {
                            isSaved = !isSaved;
                          });
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: isLoading
            ? Stack(
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
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 60,
                          width: 60,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          child: Text(
                            quotes[_quoteIndex % quotes.length],
                            key: ValueKey(_quoteIndex),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : error != null
                ? Stack(
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
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Stack(
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                              child: Text(
                                context.getSkillTranslation(skill, l10n),
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Title
                            if (title != null)
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 0),
                                child: Text(
                                  title!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontFamily: 'Montserrat',
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),

                            // Tips + buttons in scrollable list
                            Expanded(
                              child: ListView(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                children: [
                                  // Original tips
                                  ...List.generate(tips.length, (index) {
                                    return _TipTile(
                                      number: index + 1,
                                      text: tips[index],
                                    );
                                  }),

                                  // Extra tips
                                  if (_extraTips.isNotEmpty) ...[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8, bottom: 12),
                                      child: Container(
                                        height: 1,
                                        color:
                                            Colors.white.withValues(alpha: 0.3),
                                      ),
                                    ),
                                    ...List.generate(_extraTips.length,
                                        (index) {
                                      return _TipTile(
                                        number: tips.length + index + 1,
                                        text: _extraTips[index],
                                      );
                                    }),
                                  ],

                                  const SizedBox(height: 24),

                                  // 5 more + Teach me more
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          height: 48,
                                          child: OutlinedButton(
                                            onPressed: _loadingMore
                                                ? null
                                                : _loadMoreTips,
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              side: const BorderSide(
                                                  color: Colors.white,
                                                  width: 1.5),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                            ),
                                            child: _loadingMore
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      l10n.fiveMoreTips,
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: SizedBox(
                                          height: 48,
                                          child: ElevatedButton(
                                            onPressed: _teachMeMore,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF0055CC),
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    l10n.teachMeMore,
                                                    style: const TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  const Icon(
                                                    Icons.chat_bubble_outline,
                                                    size: 18,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Next / Finish
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _handleNext,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor:
                                            const Color(0xFF0055CC),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        currentIndex == widget.skills.length - 1
                                            ? l10n.finish
                                            : l10n.nextSkill,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _TipTile extends StatelessWidget {
  final int number;
  final String text;

  const _TipTile({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color.fromARGB(255, 18, 18, 18),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 15, 15, 15),
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
