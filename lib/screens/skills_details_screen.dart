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
import 'package:softai/screens/profile_screen.dart';

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
  final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  final String apiUrl = "https://api.openai.com/v1/chat/completions";

  String? title;
  List<String> tips = [];
  bool isLoading = true;
  String? error;
  int currentIndex = 0;
  int _quoteIndex = 0;
  Timer? _quoteTimer;
  List<MapEntry<String, double>> get skillsList =>
      widget.skills.entries.toList();
  late final UserCubit userCubit;
  Color favoriteColor = Colors.white;
  bool isSaved = false;
  late bool isEnglish;
  // Map<String, List<String>> savedLessons;

  @override
  void initState() {
    super.initState();
    userCubit = locator<UserCubit>();

    _quoteTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      setState(() {
        _quoteIndex = (_quoteIndex + 1) % motivationalTexts.length;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isEnglish = context.isEnglish;

    final currentSkill = skillsList[currentIndex - 1].key;

    // Only fetch tips if the user hasn't already saved this skill
    if (!widget.user.selectedSkills.containsKey(currentSkill)) {
      fetchSkillTips();
    } else {
      // If skill is already saved, skip fetching tips and just go to next
      _handleNext();
    }
  }

  @override
  void dispose() {
    _quoteTimer?.cancel();
    super.dispose();
  }

  // Future<void> fetchSkillTips() async {
  //   setState(() {
  //     isLoading = true;
  //     error = null;
  //   });
  //   final skillsList = widget.skills.entries.toList();
  //   final currentSkill = skillsList[currentIndex].key;
  //   try {
  //     final response = await http.post(
  //       Uri.parse(apiUrl),
  //       headers: {
  //         'Authorization': 'Bearer $apiKey',
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode({
  //         "model": "gpt-4-turbo",
  //         "max_tokens": 300,
  //         "messages": [
  //           {
  //             "role": "system",
  //             "content":
  //                 "You are a soft skills mentor. Provide structured advice for improving soft skills."
  //           },
  //           {
  //             "role": "user",
  //             "content":
  //                 "Provide advice and tips for the skill: $currentSkill. "
  //                     "Format the response exactly as:\n"
  //                     "Title: [One engaging sentence about the skill]\n"
  //                     "Tips:\n"
  //                     "- [Tip 1, one short actionable sentence]\n"
  //                     "- [Tip 2, one short actionable sentence]\n"
  //                     "- [Tip 3, one short actionable sentence]\n"
  //                     "- [Tip 4, one short actionable sentence]\n"
  //                     "- [Tip 5, one short actionable sentence]\n"
  //                     "Do not add anything else."
  //           }
  //         ]
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       final content = data['choices'][0]['message']['content'];
  //       final parsed = _parseSkillResponse(content);

  //       setState(() {
  //         title = parsed['title'];
  //         tips = parsed['tips'];
  //         isLoading = false;
  //       });
  //     } else {
  //       setState(() {
  //         error = "Failed to fetch tips: ${response.body}";
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       error = "Error: $e";
  //       isLoading = false;
  //     });
  //   }
  // }
  Future<void> fetchSkillTips() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final skillsList = widget.skills.entries.toList();
    final currentSkill = skillsList[currentIndex].key;

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
                  : "Ti si mentor za soft veštine. Daj strukturisane savete za poboljšanje soft veština."
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

  // Map<String, dynamic> _parseSkillResponse(String content) {
  //   final titleRegex = RegExp(r'Title:\s*(.*)');
  //   final tipsRegex = RegExp(r'-\s*(.*)');

  //   final titleMatch = titleRegex.firstMatch(content);
  //   final tipsMatches = tipsRegex.allMatches(content);

  //   final parsedTitle = titleMatch != null ? titleMatch.group(1) : '';
  //   final parsedTips = tipsMatches.map((m) => m.group(1) ?? '').toList();

  //   return {
  //     "title": parsedTitle,
  //     "tips": parsedTips,
  //   };
  // }
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

  Future<void> _handleNext() async {
    final currentSkillName = skillsList[currentIndex].key;

    if (currentIndex < skillsList.length - 1) {
      setState(() {
        currentIndex++;
      });
      fetchSkillTips();
    } else {
      // ✅ Update progress for last skill
      try {
        await userCubit.updateSoftSkillProgress(
          skillName: currentSkillName,
          progressDelta: 0.02,
        );
      } catch (e) {
        debugPrint("Failed to update skill progress: $e");
      }

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfileScreen(user: widget.user),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentSkill = skillsList[currentIndex].key;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            currentSkill,
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          backgroundColor: Color(0xFF007BFF),
          actions: [
            BlocBuilder<UserCubit, UserState>(
              bloc: userCubit,
              builder: (context, state) {
                return IconButton(
                  icon: Icon(
                    isSaved ? Icons.favorite : Icons.favorite_outline,
                    color: isSaved ? Colors.red : Colors.white,
                  ),
                  onPressed: () {
                    print(title);
                    userCubit.saveLessonForSkill(title!, tips);
                    setState(() {
                      isSaved = !isSaved;
                    });
                  },
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
                          Color(0xFF007BFF),
                          Color(0xFF00FFD5),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 60,
                          width: 60,
                          child: CircularProgressIndicator(
                            color: Color(0xFF007BFF),
                          ),
                        ),
                        SizedBox(height: 20),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 500),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          child: Text(
                            motivationalTexts[_quoteIndex],
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
                ? Center(
                    child: Text(
                    error!,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 122, 26, 20),
                      fontFamily: 'Montserrat',
                    ),
                  ))
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
                              Color(0xFF007BFF),
                              Color(0xFF00FFD5),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title != null)
                              Text(
                                title!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            const SizedBox(height: 32),
                            Expanded(
                              child: ListView.builder(
                                itemCount: tips.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "• ${tips[index]}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _handleNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blue,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                currentIndex == widget.skills.length - 1
                                    ? "Finish"
                                    : "Next Skill",
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
