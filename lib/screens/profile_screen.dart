import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softai/cubit/auth_cubit.dart';
import 'package:softai/di/di.dart';
import 'package:softai/extensions/l10n_extension.dart';
import 'package:softai/model/user.dart';
import 'package:softai/screens/chat_screen.dart';
import 'package:softai/screens/daily_advice_screen.dart';
import 'package:softai/screens/goals_screen.dart';
import 'package:softai/screens/new_skill_screen.dart';
import 'package:softai/screens/saved_lessons_screen.dart';
import 'package:softai/screens/technique_screen.dart';
import 'package:softai/screens/track_progress_screen.dart';
import 'package:softai/service/lessons_service.dart';
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
  String get apiKey => dotenv.env['OPEN_API_KEY'] ?? '';
  // final String apiKey =
  //     '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';
  final String apiUrl = "https://api.openai.com/v1/chat/completions";

  String? dailyTip;
  String? technique;
  String? techniqueExplanation;
  bool isLoading = true;
  // Add these fields
  Map<String, String>? _lastConversation;
  List<Map<String, String>>? _lastConversationMessages;

  late AnimationController _chatbotController;
  late Animation<double> _wiggleAnimation;
  bool _showHint = false;
  late final AuthCubit authCubit;

  final int _currentNavIndex = 0;

  @override
  void dispose() {
    _chatbotController.dispose();
    super.dispose();
  }

  void _openChatDialog() {
    showDialog(
      context: context,
      builder: (context) => ChatBotDialog(apiKey: apiKey),
    );
  }

  void setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    final token = await messaging.getToken();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .update({'fcmToken': token});
    print('🔑 FCM Token: $token');
  }

  @override
  void initState() {
    super.initState();
    authCubit = locator<AuthCubit>();
    setupFCM();
    _loadDailyContent();
    _loadLastConversation();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _showHint = true);
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
      _playWiggle();
    });
  }

  Future<void> _loadLastConversation() async {
    final lessonService = LessonService();
    final conversations = await lessonService.loadConversations();
    if (conversations.isNotEmpty && mounted) {
      final last = conversations.first;
      List<Map<String, String>>? messages;

      final rawMessages = last['messages'];
      if (rawMessages != null && rawMessages.isNotEmpty) {
        try {
          final decoded = json.decode(rawMessages) as List<dynamic>;
          messages =
              decoded.map((e) => Map<String, String>.from(e as Map)).toList();
        } catch (_) {}
      }

      setState(() {
        _lastConversation = last;
        _lastConversationMessages = messages;
      });
    }
  }

  Future<void> _playWiggle() async {
    await _chatbotController.forward();
    await _chatbotController.reverse();
    await _chatbotController.animateTo(-1.0,
        duration: _chatbotController.duration!);
    await _chatbotController.forward();
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
                  ? "Ti si lični mentor za razvoj mekih veština. Piši isključivo na srpskom jeziku, ekavica."
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
    if (text == null || text.isEmpty) return "";

    final isSerbian = !context.isEnglish;
    final targetLanguage = isSerbian ? 'Serbian' : 'English';

    if ((isSerbian && text.contains(RegExp(r'[čćšđž]'))) ||
        (!isSerbian && !text.contains(RegExp(r'[čćšđž]')))) {
      return text;
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
          "max_tokens": 100,
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
        return text;
      }
    } catch (e) {
      return text;
    }
  }

  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;

    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NewSkillScreen(user: widget.user),
          ),
        );
        break;
      case 2:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TrackProgressScreen()),
        );
        break;
      case 3:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => GoalsScreen()),
        );
        break;
      case 4:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SavedLessonsScreen(user: widget.user),
          ),
        );
        break;
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   final l10n = context.l10n;

  //   final navItems = [
  //     _NavItemData(
  //       icon: Icons.home_outlined,
  //       activeIcon: Icons.home,
  //       label: l10n.home,
  //     ),
  //     _NavItemData(
  //       icon: Icons.fitness_center_outlined,
  //       activeIcon: Icons.fitness_center,
  //       label: l10n.trainNewSkill,
  //     ),
  //     _NavItemData(
  //       activeIcon: Icons.bar_chart_outlined,
  //       icon: Icons.bar_chart_sharp,
  //       label: l10n.trackProgress,
  //     ),
  //     _NavItemData(
  //       icon: Icons.gps_fixed_outlined,
  //       activeIcon: Icons.gps_fixed,
  //       label: l10n.goals,
  //     ),
  //     _NavItemData(
  //       icon: Icons.menu_book_outlined,
  //       activeIcon: Icons.menu_book,
  //       label: l10n.savedLessons,
  //     ),
  //   ];

  //   return PopScope(
  //     canPop: false,
  //     child: Scaffold(
  //       resizeToAvoidBottomInset: false,
  //       body: Stack(
  //         children: [
  //           // Gradient Background
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
  //             bottom: false,
  //             child: isLoading
  //                 ? const Center(
  //                     child: CircularProgressIndicator(color: Colors.white),
  //                   )
  //                 : Stack(
  //                     children: [
  //                       SingleChildScrollView(
  //                         padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             // Welcome + Logout
  //                             Row(
  //                               mainAxisAlignment:
  //                                   MainAxisAlignment.spaceBetween,
  //                               children: [
  //                                 Expanded(
  //                                   child: Text(
  //                                     "${l10n.welcome}, ${widget.user.fullName}",
  //                                     style: const TextStyle(
  //                                       fontSize: 22,
  //                                       fontWeight: FontWeight.bold,
  //                                       color: Colors.white,
  //                                       fontFamily: 'Montserrat',
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 IconButton(
  //                                   onPressed: () => authCubit.signOut(),
  //                                   icon: const Icon(
  //                                     Icons.logout,
  //                                     color: Colors.white,
  //                                     size: 28,
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                             const SizedBox(height: 24),
  //                             // Daily Tip
  //                             Card(
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(12),
  //                               ),
  //                               color: Colors.white.withOpacity(0.9),
  //                               child: Padding(
  //                                 padding: const EdgeInsets.all(16.0),
  //                                 child: Column(
  //                                   crossAxisAlignment:
  //                                       CrossAxisAlignment.start,
  //                                   children: [
  //                                     Text(
  //                                       l10n.dailyTip,
  //                                       style: const TextStyle(
  //                                         fontSize: 18,
  //                                         fontWeight: FontWeight.bold,
  //                                         color: Colors.blue,
  //                                         fontFamily: 'Montserrat',
  //                                       ),
  //                                     ),
  //                                     const SizedBox(height: 8),
  //                                     FutureBuilder<String>(
  //                                       future: _translateText(dailyTip),
  //                                       builder: (context, snapshot) {
  //                                         if (snapshot.connectionState ==
  //                                             ConnectionState.waiting) {
  //                                           return Text(
  //                                             l10n.loading,
  //                                             style: const TextStyle(
  //                                               fontSize: 16,
  //                                               color: Colors.black87,
  //                                               fontFamily: 'Montserrat',
  //                                             ),
  //                                           );
  //                                         }
  //                                         return Text(
  //                                           context.isEnglish
  //                                               ? (dailyTip ?? l10n.loading)
  //                                               : (snapshot.data ??
  //                                                   l10n.loading),
  //                                           style: const TextStyle(
  //                                             fontSize: 16,
  //                                             color: Colors.black87,
  //                                             fontFamily: 'Montserrat',
  //                                           ),
  //                                         );
  //                                       },
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ),
  //                             const SizedBox(height: 16),
  //                             // Technique of the Day
  //                             Card(
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(12),
  //                               ),
  //                               color: Colors.white.withOpacity(0.9),
  //                               child: Padding(
  //                                 padding: const EdgeInsets.all(16.0),
  //                                 child: Column(
  //                                   crossAxisAlignment:
  //                                       CrossAxisAlignment.start,
  //                                   children: [
  //                                     Text(
  //                                       l10n.techinqueOfTheDay,
  //                                       style: const TextStyle(
  //                                         fontSize: 18,
  //                                         fontWeight: FontWeight.bold,
  //                                         color: Colors.blue,
  //                                         fontFamily: 'Montserrat',
  //                                       ),
  //                                     ),
  //                                     const SizedBox(height: 8),
  //                                     FutureBuilder(
  //                                       future: _translateText(technique),
  //                                       builder: (context, asyncSnapshot) {
  //                                         if (asyncSnapshot.connectionState ==
  //                                             ConnectionState.waiting) {
  //                                           return Text(
  //                                             l10n.loading,
  //                                             style: const TextStyle(
  //                                               fontSize: 16,
  //                                               color: Colors.black87,
  //                                               fontFamily: 'Montserrat',
  //                                             ),
  //                                           );
  //                                         }
  //                                         return Text(
  //                                           context.isEnglish
  //                                               ? (technique ?? l10n.loading)
  //                                               : (asyncSnapshot.data ??
  //                                                   l10n.loading),
  //                                           style: const TextStyle(
  //                                             fontSize: 16,
  //                                             fontWeight: FontWeight.w600,
  //                                             color: Colors.black87,
  //                                             fontFamily: 'Montserrat',
  //                                           ),
  //                                         );
  //                                       },
  //                                     ),
  //                                     const SizedBox(height: 6),
  //                                     FutureBuilder<String>(
  //                                       future: _translateText(
  //                                           techniqueExplanation),
  //                                       builder: (context, snapshot) {
  //                                         if (snapshot.connectionState ==
  //                                             ConnectionState.waiting) {
  //                                           return Text(
  //                                             l10n.loading,
  //                                             style: const TextStyle(
  //                                               fontSize: 16,
  //                                               color: Colors.black87,
  //                                               fontFamily: 'Montserrat',
  //                                             ),
  //                                           );
  //                                         }
  //                                         return Text(
  //                                           context.isEnglish
  //                                               ? (techniqueExplanation ??
  //                                                   l10n.loading)
  //                                               : (snapshot.data ??
  //                                                   l10n.loading),
  //                                           style: const TextStyle(
  //                                             fontSize: 16,
  //                                             color: Colors.black87,
  //                                             fontFamily: 'Montserrat',
  //                                           ),
  //                                         );
  //                                       },
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                       // Chatbot avatar
  //                       Positioned(
  //                         bottom: 16,
  //                         right: 8,
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.end,
  //                           children: [
  //                             AnimatedOpacity(
  //                               opacity: _showHint ? 0.0 : 1.0,_
  //                               duration: const Duration(seconds: 3),
  //                               child: Container(
  //                                 padding: const EdgeInsets.all(8),
  //                                 decoration: BoxDecoration(
  //                                   color: Colors.black87,
  //                                   borderRadius: BorderRadius.circular(8),
  //                                 ),
  //                                 child: Text(
  //                                   l10n.needHelp,
  //                                   style: const TextStyle(color: Colors.white),
  //                                 ),
  //                               ),
  //                             ),
  //                             GestureDetector(
  //                               onTap: _openChatDialog,
  //                               child: AnimatedBuilder(
  //                                 animation: _wiggleAnimation,
  //                                 builder: (context, child) {
  //                                   return Transform.translate(
  //                                     offset: Offset(_wiggleAnimation.value, 0),
  //                                     child: Hero(
  //                                       tag: "chatbot-avatar",
  //                                       child: Image.asset(
  //                                         'assets/avatar.png',
  //                                         width: 72,
  //                                         height: 72,
  //                                       ),
  //                                     ),
  //                                   );
  //                                 },
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //           ),
  //         ],
  //       ),
  //       bottomNavigationBar: Container(
  //         decoration: const BoxDecoration(
  //           gradient: LinearGradient(
  //             begin: Alignment.centerLeft,
  //             end: Alignment.centerRight,
  //             colors: [
  //               Color(0xFF006FFF),
  //               Color.fromARGB(255, 136, 180, 236),
  //             ],
  //           ),
  //         ),
  //         child: SafeArea(
  //           top: false,
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(vertical: 8),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceAround,
  //               children: List.generate(navItems.length, (index) {
  //                 final item = navItems[index];
  //                 final isSelected = index == _currentNavIndex;
  //                 return _NavItem(
  //                   icon: isSelected ? item.activeIcon : item.icon,
  //                   label: item.label,
  //                   isSelected: isSelected,
  //                   onTap: () => _onNavTap(index),
  //                 );
  //               }),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
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
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Skillena AI + Logout
                      Row(
                        children: [
                          const SizedBox(width: 48),
                          Expanded(
                            child: Row(
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
                                    color:
                                        const Color.fromARGB(255, 84, 204, 204),
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
                          ),
                          IconButton(
                            onPressed: () => authCubit.signOut(),
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Welcome
                      Text(
                        "${l10n.welcome}, ${widget.user.fullName}! 👋",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.readyForProgress,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Chat with Skillena AI card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.chatWithSkillena,
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1A1A2E),
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.askAndGetAdvice,
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(
                                            MaterialPageRoute(
                                              builder: (_) => ChatScreen(
                                                apiKey: apiKey,
                                              ),
                                            ),
                                          )
                                          .then((_) => _loadLastConversation());
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0055CC),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      l10n.startChat,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Image.asset(
                              'assets/avatar.png',
                              width: 90,
                              height: 90,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Daily Tip card
                      _InfoCard(
                        title: l10n.dailyTip,
                        child: FutureBuilder<String>(
                          future: _translateText(dailyTip),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text(l10n.loading,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      fontFamily: 'Montserrat'));
                            }
                            return Text(
                              context.isEnglish
                                  ? (dailyTip ?? l10n.loading)
                                  : (snapshot.data ?? l10n.loading),
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  fontFamily: 'Montserrat'),
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DailyAdviceScreen(
                                tip: dailyTip ?? '',
                                explanation: techniqueExplanation ?? '',
                              ),
                            ),
                          );
                        },
                      ),

                      // Technique card
                      _InfoCard(
                        title: l10n.techinqueOfTheDay,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder(
                              future: _translateText(technique),
                              builder: (context, asyncSnapshot) {
                                if (asyncSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(l10n.loading,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                          fontFamily: 'Montserrat'));
                                }
                                return Text(
                                  context.isEnglish
                                      ? (technique ?? l10n.loading)
                                      : (asyncSnapshot.data ?? l10n.loading),
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      fontFamily: 'Montserrat'),
                                );
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TechniqueScreen(
                                techniqueName: technique ?? '',
                                explanation: techniqueExplanation ?? '',
                                apiKey: apiKey,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Continue last conversation
                      // Continue last conversation
                      GestureDetector(
                        onTap: () {
                          if (_lastConversation != null) {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      apiKey: apiKey,
                                      initialMessages:
                                          _lastConversationMessages,
                                    ),
                                  ),
                                )
                                .then((_) => _loadLastConversation());
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.continueLastChat,
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (_lastConversation != null) ...[
                                Text(
                                  _lastConversation!['title'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _lastConversation!['summary'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ] else
                                Text(
                                  l10n.lastChatPlaceholder,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 13,
                                    color: Colors.grey.shade500,
                                    fontStyle: FontStyle.italic,
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
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onTap;

  const _InfoCard({
    required this.title,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  child,
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
