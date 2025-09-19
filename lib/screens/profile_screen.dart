import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softai/cubit/auth_cubit.dart';
import 'package:softai/di/di.dart';
import 'package:softai/extensions/l10n_extension.dart';
import 'package:softai/model/user.dart';
import 'package:softai/screens/goals_screen.dart';
import 'package:softai/screens/new_skill_screen.dart';
import 'package:softai/screens/saved_lessons_screen.dart';
import 'package:softai/screens/start_screen.dart';
import 'package:softai/screens/track_progress_screen.dart';
import 'package:softai/widgets/chatbot_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.user,
  });

  final UserModel user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  final String apiUrl = "https://api.openai.com/v1/chat/completions";

  String? dailyTip;
  String? technique;
  String? techniqueExplanation;
  bool isLoading = true;

  late AnimationController _chatbotController;
  late Animation<double> _wiggleAnimation;
  bool _chatbotHintShown = false;
  bool _showHint = false;
  late final AuthCubit authCubit;

  final List<Map<String, String>> _chatMessages =
      []; // {role: "user/assistant", text: "..."}
  @override
  void dispose() {
    _chatbotController.dispose();
    super.dispose();
  }

  void _openChatDialog() {
    showDialog(
      context: context,
      builder: (context) => ChatBotDialog(
        apiKey: apiKey,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    authCubit = locator<AuthCubit>();
    _loadDailyContent();
    //  _checkChatbotHint();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _showHint = true;
        });
      }
    });

    _chatbotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _wiggleAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _chatbotController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playWiggle(); // wiggle once
    });
  }

  Future<void> _playWiggle() async {
    await _chatbotController.forward(); // center → right
    await _chatbotController.reverse(); // right → center
    await _chatbotController.animateTo(-1.0,
        duration: _chatbotController.duration!); // center → left
    await _chatbotController.forward(); // left → center
  }

  Future<void> _checkChatbotHint() async {
    final prefs = await SharedPreferences.getInstance();
    final hintShown = prefs.getBool('chatbotHintShown') ?? false;
    if (!hintShown) {
      setState(() => _chatbotHintShown = true);
      _chatbotController.forward(); // Start wiggle
      // Stop after 3 wiggles
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) _chatbotController.stop();
      });
      await prefs.setBool('chatbotHintShown', true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _chatbotController.forward(from: 0).then((_) {
      _chatbotController.reverse();
    });
  }

  Future<void> _loadDailyContent() async {
    final prefs = await SharedPreferences.getInstance();

    final now = DateTime.now();
    final todayKey =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final cachedTip = prefs.getString('dailyTip_$todayKey');
    final cachedTechnique = prefs.getString('technique_$todayKey');
    final cachedExplanation = prefs.getString('techniqueExplanation_$todayKey');

    if (cachedTip != null &&
        cachedTechnique != null &&
        cachedExplanation != null) {
      setState(() {
        dailyTip = cachedTip;
        technique = cachedTechnique;
        techniqueExplanation = cachedExplanation;
        isLoading = false;
      });
    } else {
      await _fetchDailyTipAndTechnique(todayKey, prefs, context);
    }
  }

  Future<void> _fetchDailyTipAndTechnique(
      String todayKey, SharedPreferences prefs, BuildContext context) async {
    try {
      final isSerbian = !context.isEnglish;

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "model": "gpt-4-turbo",
          "max_tokens": 200,
          "messages": [
            {
              "role": "system",
              "content": isSerbian
                  ? "Ti si lični mentor za razvoj mekih veština."
                  : "You are a personal mentor for soft skills."
            },
            {
              "role": "user",
              "content": isSerbian
                  ? "Daj mi savet za meke veštine i tehniku dana za ${DateTime.now().toIso8601String().split('T').first} sa kratkim objašnjenjem zašto to funkcioniše. Format strogo:\n"
                      "Savet: [Kratak savet]\n"
                      "Tehnika: [Ime tehnike]\n"
                      "Zašto: [Kratko objašnjenje zašto ova tehnika funkcioniše]\n"
                      "Nemoj dodavati ništa drugo."
                  : "Give me a soft skill tip and a technique of the day for ${DateTime.now().toIso8601String().split('T').first} with a short explanation why it works. Format strictly as:\n"
                      "Tip: [Your tip, short]\n"
                      "Technique: [Technique name]\n"
                      "Why: [Short explanation why this technique works]\n"
                      "Do not add anything else."
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'] as String;

        final tipRegex =
            isSerbian ? RegExp(r'Savet:\s*(.*)') : RegExp(r'Tip:\s*(.*)');
        final techRegex = isSerbian
            ? RegExp(r'Tehnika:\s*(.*)')
            : RegExp(r'Technique:\s*(.*)');
        final whyRegex =
            isSerbian ? RegExp(r'Zašto:\s*(.*)') : RegExp(r'Why:\s*(.*)');

        setState(() {
          dailyTip = tipRegex.firstMatch(content)?.group(1) ??
              (isSerbian ? "Ostani motivisan!" : "Stay motivated!");
          technique = techRegex.firstMatch(content)?.group(1) ??
              (isSerbian ? "Aktivno slušanje" : "Active Listening");
          techniqueExplanation = whyRegex.firstMatch(content)?.group(1) ??
              (isSerbian
                  ? "Zato što poboljšava komunikaciju i razumevanje."
                  : "Because it improves communication and understanding.");
          isLoading = false;
        });

        prefs.getKeys().where((k) {
          final isOld = !k.contains(todayKey) &&
              (k.startsWith('dailyTip_') ||
                  k.startsWith('technique_') ||
                  k.startsWith('techniqueExplanation_'));
          return isOld;
        }).forEach(prefs.remove);

        await prefs.setString('dailyTip_$todayKey', dailyTip!);
        await prefs.setString('technique_$todayKey', technique!);
        await prefs.setString(
            'techniqueExplanation_$todayKey', techniqueExplanation!);
      } else {
        setState(() {
          dailyTip = isSerbian
              ? "Neuspešno učitavanje saveta."
              : "Failed to load daily tip.";
          technique =
              isSerbian ? "Pokušaj ponovo kasnije." : "Try again later.";
          techniqueExplanation = "";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        dailyTip = !context.isEnglish
            ? "Greška pri učitavanju saveta."
            : "Error fetching daily tip.";
        technique = "";
        techniqueExplanation = "";
        isLoading = false;
      });
    }
  }

  Future<String> _translateText(String? text) async {
    if (text == null || text.isEmpty) {
      return "";
    }

    final isSerbian = !context.isEnglish;
    final targetLanguage = isSerbian ? 'Serbian' : 'English';

    // Simple heuristic to check if text is already in the target language
    // Serbian text often contains characters like č, ć, š, đ, ž
    if ((isSerbian && text.contains(RegExp(r'[čćšđž]'))) ||
        (!isSerbian && !text.contains(RegExp(r'[čćšđž]')))) {
      return text; // Return original text if it's already in the target language
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "model": "gpt-4-turbo",
          "max_tokens": 100, // Smaller token limit for translation
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a professional translator. Translate the provided text accurately into $targetLanguage. Return only the translated text, nothing else."
            },
            {"role": "user", "content": text}
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translatedText =
            data['choices'][0]['message']['content'] as String;
        return translatedText.trim();
      } else {
        print('Translation API error: ${response.statusCode}');
        return text; // Fallback to original text on error
      }
    } catch (e) {
      print('Translation error: $e');
      return text; // Fallback to original text on error
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: false,
      child: BlocListener<AuthCubit, AuthState>(
        bloc: authCubit,
        listener: (context, state) {
          if (state is AuthSignedOut) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => StartScreen()),
            );
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              // Gradient Background
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
              SafeArea(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${l10n.welcome}, ${widget.user.fullName}",
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.notifications_outlined,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  color: Colors.white.withOpacity(0.9),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.dailyTip,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Text(
                                        //   dailyTip ?? l10n.loading,
                                        //   style: const TextStyle(
                                        //     fontSize: 16,
                                        //     color: Colors.black87,
                                        //     fontFamily: 'Montserrat',
                                        //   ),
                                        // ),
                                        FutureBuilder<String>(
                                          future: _translateText(dailyTip),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Text(
                                                l10n.loading,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black87,
                                                  fontFamily: 'Montserrat',
                                                ),
                                              );
                                            }
                                            return Text(
                                              context.isEnglish
                                                  ? (dailyTip ?? l10n.loading)
                                                  : (snapshot.data ??
                                                      l10n.loading),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                                fontFamily: 'Montserrat',
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  color: Colors.white.withOpacity(0.9),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.techinqueOfTheDay,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          technique ?? l10n.loading,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        FutureBuilder<String>(
                                          future: _translateText(
                                              techniqueExplanation),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Text(
                                                l10n.loading,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black87,
                                                  fontFamily: 'Montserrat',
                                                ),
                                              );
                                            }
                                            return Text(
                                              context.isEnglish
                                                  ? (techniqueExplanation ??
                                                      l10n.loading)
                                                  : (snapshot.data ??
                                                      l10n.loading),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                                fontFamily: 'Montserrat',
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 48,
                                ),
                                ListTile(
                                  leading: Text(
                                    l10n.savedLessons,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SavedLessonsScreen(
                                            user: widget.user,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                ListTile(
                                  leading: Text(
                                    l10n.trainNewSkill,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => NewSkillScreen(
                                            user: widget.user,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                ListTile(
                                  leading: Text(
                                    l10n.trackProgress,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TrackProgressScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                ListTile(
                                  leading: Text(
                                    l10n.goals,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => GoalsScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                ListTile(
                                  onTap: () {
                                    authCubit.signOut();
                                  },
                                  leading: Text(
                                    l10n.logOut,
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            right: 8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // if (_chatbotHintShown)
                                AnimatedOpacity(
                                  opacity: _showHint ? 0.0 : 1.0,
                                  duration: const Duration(seconds: 3),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      l10n.needHelp,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _openChatDialog();
                                  },
                                  child: AnimatedBuilder(
                                      animation: _wiggleAnimation,
                                      builder: (context, child) {
                                        return Transform.translate(
                                          offset:
                                              Offset(_wiggleAnimation.value, 0),
                                          child: Hero(
                                            tag: "chatbot-avatar",
                                            child: Image.asset(
                                              'assets/avatar.png',
                                              width: 72,
                                              height: 72,
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                              ],
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
}
