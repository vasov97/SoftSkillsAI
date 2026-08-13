import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:softai/cubit/auth_cubit.dart';
import 'package:softai/cubit/user_cubit.dart';
import 'package:softai/di/di.dart';
import 'package:softai/extensions/l10n_extension.dart';
import 'package:softai/screens/create_goal_screen.dart';
import 'package:softai/screens/practice_screen.dart';
import 'package:softai/screens/save_answer_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatScreen extends StatefulWidget {
  final String apiKey;
  final String? practiceScenario;
  final List<Map<String, String>>? initialMessages;

  const ChatScreen({
    super.key,
    required this.apiKey,
    this.practiceScenario,
    this.initialMessages,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  bool _greetingAdded = false;
  bool _isPracticeMode = false;
  late final userCubit;
  late final AuthCubit authCubit;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _spokenText = '';

  @override
  void initState() {
    super.initState();
    userCubit = locator<UserCubit>();
    authCubit = locator<AuthCubit>();
    _speech = stt.SpeechToText();
  }

  // Future<void> _saveAnswer() async {
  //   if (_messages.length < 2) return;

  //   // Show loading
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (_) => const Center(
  //       child: CircularProgressIndicator(color: Colors.white),
  //     ),
  //   );

  //   // Build conversation text for summary
  //   final conversationText = _messages
  //       .where((m) => m['text'] != null && m['text']!.isNotEmpty)
  //       .map((m) => '${m["role"]}: ${m["text"]}')
  //       .join('\n');

  //   // Get last user message as default title
  //   final lastUserMsg = _messages.lastWhere((m) => m['role'] == 'user',
  //       orElse: () => {'text': ''});
  //   final defaultTitle = lastUserMsg['text'] ?? '';

  //   try {
  //     final response = await http.post(
  //       Uri.parse("https://api.openai.com/v1/chat/completions"),
  //       headers: {
  //         "Authorization": "Bearer ${widget.apiKey}",
  //         "Content-Type": "application/json",
  //       },
  //       body: json.encode({
  //         "model": "gpt-4o-mini",
  //         "temperature": 0.3,
  //         "max_tokens": 200,
  //         "messages": [
  //           {
  //             "role": "system",
  //             "content": context.isEnglish
  //                 ? "Summarize this conversation in 2-3 sentences. Return ONLY the summary, nothing else."
  //                 : "Sažmi ovaj razgovor u 2-3 rečenice. Vrati SAMO sažetak, ništa drugo. Piši na srpskom, ekavica.",
  //           },
  //           {"role": "user", "content": conversationText},
  //         ],
  //       }),
  //     );

  //     String summary = '';
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       summary = data['choices'][0]['message']['content'] ?? '';
  //     }

  //     if (!mounted) return;
  //     Navigator.of(context).pop(); // close loading

  //     final navigator = Navigator.of(context);
  //     navigator.push(
  //       MaterialPageRoute(
  //         builder: (_) => SaveAnswerScreen(
  //           conversationTitle: defaultTitle,
  //           summaryText: summary,
  //           apiKey: widget.apiKey,
  //           messages: _messages,
  //         ),
  //       ),
  //     );
  //   } catch (e) {
  //     if (!mounted) return;
  //     Navigator.of(context).pop(); // close loading

  //     Navigator.of(context).push(
  //       MaterialPageRoute(
  //         builder: (_) => SaveAnswerScreen(
  //           conversationTitle: defaultTitle,
  //           summaryText: '',
  //           apiKey: widget.apiKey,
  //           messages: _messages,
  //         ),
  //       ),
  //     );
  //   }
  // }

  Future<void> _saveAnswer() async {
    if (_messages.length < 2) return;

    final navigator = Navigator.of(context);
    final isEng = context.isEnglish;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    final conversationText = _messages
        .where((m) => m['text'] != null && m['text']!.isNotEmpty)
        .map((m) => '${m["role"]}: ${m["text"]}')
        .join('\n');

    final lastUserMsg = _messages.lastWhere(
      (m) => m['role'] == 'user',
      orElse: () => {'text': ''},
    );
    final defaultTitle = lastUserMsg['text'] ?? '';
    final messagesCopy = List<Map<String, String>>.from(_messages);

    String summary = '';

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
          "max_tokens": 200,
          "messages": [
            {
              "role": "system",
              "content": isEng
                  ? "Summarize this conversation in 2-3 sentences. Return ONLY the summary, nothing else."
                  : "Sažmi ovaj razgovor u 2-3 rečenice. Vrati SAMO sažetak, ništa drugo. Piši na srpskom, ekavica.",
            },
            {"role": "user", "content": conversationText},
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        summary = data['choices'][0]['message']['content'] ?? '';
      }
    } catch (_) {}

    navigator.pop(); // close loading
    navigator.push(
      MaterialPageRoute(
        builder: (_) => SaveAnswerScreen(
          conversationTitle: defaultTitle,
          summaryText: summary,
          apiKey: widget.apiKey,
          messages: messagesCopy,
        ),
      ),
    );
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (!_greetingAdded) {
  //     _greetingAdded = true;
  //     _messages.add({
  //       "role": "assistant",
  //       "text": context.isEnglish
  //           ? "Hi! I'm your soft skills coach. How can I help you today?"
  //           : "Zdravo! Ja sam tvoj AI trener. Kako mogu da ti pomognem danas?",
  //       "time": TimeOfDay.now().format(context),
  //     });
  //   }
  // }
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (!_greetingAdded) {
  //     _greetingAdded = true;

  //     if (widget.initialMessages != null &&
  //         widget.initialMessages!.isNotEmpty) {
  //       _messages.addAll(widget.initialMessages!);
  //     } else if (widget.practiceScenario != null) {
  //        _isPracticeMode = true;
  //       _messages.add({
  //         "role": "assistant",
  //         "text": context.isEnglish
  //             ? "Great! Let's practice: ${widget.practiceScenario}. I'll set the scene — you respond as you would in real life."
  //             : "Odlično! Hajde da vežbamo: ${widget.practiceScenario}. Ja ću postaviti scenu — ti odgovori kao u stvarnom životu.",
  //         "time": TimeOfDay.now().format(context),
  //       });
  //       Future.microtask(() => _sendPracticePrompt());
  //     } else {
  //       _messages.add({
  //         "role": "assistant",
  //         "text": context.isEnglish
  //             ? "Hi! I'm your soft skills coach. How can I help you today?"
  //             : "Zdravo! Ja sam tvoj AI trener. Kako mogu da ti pomognem danas?",
  //         "time": TimeOfDay.now().format(context),
  //       });
  //     }
  //   }
  // }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_greetingAdded) {
      _greetingAdded = true;

      if (widget.initialMessages != null &&
          widget.initialMessages!.isNotEmpty) {
        _messages.addAll(widget.initialMessages!);
      } else if (widget.practiceScenario != null) {
        _isPracticeMode = true;
        _messages.add({
          "role": "assistant",
          "text": context.isEnglish
              ? "Great! Let's practice: ${widget.practiceScenario}. I'll set the scene — you respond as you would in real life."
              : "Odlično! Hajde da vežbamo: ${widget.practiceScenario}. Ja ću postaviti scenu — ti odgovori kao u stvarnom životu.",
          "time": TimeOfDay.now().format(context),
        });
        Future.microtask(() => _sendPracticePrompt());
      } else {
        _messages.add({
          "role": "assistant",
          "text": context.isEnglish
              ? "Hi! I'm your soft skills coach. How can I help you today?"
              : "Zdravo! Ja sam tvoj AI trener. Kako mogu da ti pomognem danas?",
          "time": TimeOfDay.now().format(context),
        });
      }
    }
  }

  Future<void> _listen() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);

      if (_spokenText.isNotEmpty) {
        _controller.text = _spokenText;
        _spokenText = '';
        _sendMessage();
      }
      return;
    }

    final available = await _speech.initialize(
      onError: (error) {
        debugPrint('Speech error: $error');
        if (mounted) setState(() => _isListening = false);
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (_isListening && mounted) {
            setState(() => _isListening = false);
            if (_spokenText.isNotEmpty) {
              _controller.text = _spokenText;
              _spokenText = '';
              _sendMessage();
            }
          }
        }
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _spokenText = '';
      });

      await _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _spokenText = result.recognizedWords;
              _controller.text = _spokenText;
            });
          }
        },
        localeId: context.isEnglish ? 'en_US' : 'sr_RS',
        listenMode: stt.ListenMode.dictation,
        cancelOnError: true,
        listenFor: const Duration(seconds: 30),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _speech.stop();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

//   Future<void> _sendMessage() async {
//     final text = _controller.text.trim();
//     if (text.isEmpty) return;

//     final time = TimeOfDay.now().format(context);

//     setState(() {
//       _messages.add({"role": "user", "text": text, "time": time});
//       _isLoading = true;
//     });
//     _controller.clear();
//     _scrollToBottom();

//     final response = await http.post(
//       Uri.parse("https://api.openai.com/v1/chat/completions"),
//       headers: {
//         "Authorization": "Bearer ${widget.apiKey}",
//         "Content-Type": "application/json",
//       },
//       body: json.encode({
//         "model": "gpt-4-turbo",
//         "messages": [
//           {
//             "role": "system",
//             "content": context.isEnglish
//                 ? '''
// You are a concise mentor for soft skills.
// Always respond with exactly 5 short, clear tips in bullet point format.
// Each tip should be 1 sentence, and avoid repetition.
// '''
//                 : '''
// Ti si koncizan mentor za meke veštine.
// Uvek odgovaraj sa tačno 5 kratkih, jasnih saveta u formatu nabrajanja.
// Svaki savet treba da bude 1 rečenica, bez ponavljanja.
// VAŽNO: Piši isključivo na srpskom jeziku, ekavica. Ne koristi ijekavicu ili hrvatski.
// ''',
//           },
//           ..._messages.map((m) => {"role": m["role"], "content": m["text"]}),
//           {"role": "user", "content": text},
//         ],
//       }),
//     );

//     final replyTime = TimeOfDay.now().format(context);

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final reply = data['choices'][0]['message']['content'];
//       setState(() {
//         _messages.add({"role": "assistant", "text": reply, "time": replyTime});
//         _isLoading = false;
//       });
//     } else {
//       setState(() {
//         _messages.add({
//           "role": "assistant",
//           "text": "Error: ${response.body}",
//           "time": replyTime,
//         });
//         _isLoading = false;
//       });
//     }
//     _scrollToBottom();
//   }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final time = TimeOfDay.now().format(context);

    setState(() {
      _messages.add({"role": "user", "text": text, "time": time});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    String systemPrompt;

    if (_isPracticeMode) {
      systemPrompt = context.isEnglish
          ? '''You are a soft skills practice partner. You are role-playing a workplace scenario with the user. Stay in character. React naturally to what they say. After their response, give brief constructive feedback on how they handled it, then continue the scenario or offer a new challenge. Do NOT give generic tips — respond to what they actually said.'''
          : '''Ti si partner za vežbanje mekih veština. Igraš ulogu u scenariju sa posla sa korisnikom. Ostani u ulozi. Reaguj prirodno na ono što kažu. Posle njihovog odgovora, daj kratak konstruktivan komentar o tome kako su reagovali, pa nastavi scenario ili ponudi novi izazov. NE daj generičke savete — odgovori na ono što su zaista rekli.
VAŽNO: Piši isključivo na srpskom jeziku, ekavica.''';
    } else {
      systemPrompt = context.isEnglish
          ? '''You are a concise mentor for soft skills. Respond helpfully based on the conversation context. If the user asks a question, answer it directly. If they want tips, give them. Be conversational and relevant to what was discussed.'''
          : '''Ti si koncizan mentor za meke veštine. Odgovaraj korisno na osnovu konteksta razgovora. Ako korisnik postavi pitanje, odgovori direktno. Ako želi savete, daj ih. Budi konverzacijski i relevantan za ono što je diskutovano.
VAŽNO: Piši isključivo na srpskom jeziku, ekavica.''';
    }

    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer ${widget.apiKey}",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "model": "gpt-4-turbo",
        "messages": [
          {"role": "system", "content": systemPrompt},
          ..._messages.map((m) => {"role": m["role"], "content": m["text"]}),
        ],
      }),
    );

    final replyTime = TimeOfDay.now().format(context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final reply = data['choices'][0]['message']['content'];
      setState(() {
        _messages.add({"role": "assistant", "text": reply, "time": replyTime});
        _isLoading = false;
      });
    } else {
      setState(() {
        _messages.add({
          "role": "assistant",
          "text": "Error: ${response.body}",
          "time": replyTime,
        });
        _isLoading = false;
      });
    }
    _scrollToBottom();
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
        actions: [
          IconButton(
            onPressed: () => authCubit.signOut(),
            icon: const Icon(Icons.logout, color: Colors.white, size: 24),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background
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
              children: [
                // Messages
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg["role"] == "user";
                      final time = msg["time"] ?? "";

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          crossAxisAlignment: isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            // Bot label + time
                            if (!isUser)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 40, bottom: 4),
                                child: Row(
                                  children: [
                                    const Text(
                                      'Skillena',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      time,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 11,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Bubble row
                            Row(
                              mainAxisAlignment: isUser
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Bot avatar
                                if (!isUser) ...[
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF0077DD),
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: ClipOval(
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Image.asset(
                                          'assets/avatar.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                // Message bubble
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isUser
                                          ? const Color(0xFF0055CC)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
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
                                // User time
                                if (isUser) ...[
                                  const SizedBox(width: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      time,
                                      style: const TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 11,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Loading
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),

                // Action buttons
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: _ActionChip(
                              icon: Icons.bookmark_border,
                              label: l10n.saveAnswer,
                              // onTap: () {
                              //   Navigator.of(context).push(
                              //     MaterialPageRoute(
                              //       builder: (_) => const SaveAnswerScreen(
                              //         conversationTitle: '',
                              //         summaryText: '',
                              //       ),
                              //     ),
                              //   );
                              // },
                              onTap: _saveAnswer,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: _ActionChip(
                              icon: Icons.gps_fixed,
                              label: l10n.createGoal,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CreateGoalScreen(apiKey: widget.apiKey),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: _ActionChip(
                          icon: Icons.fitness_center,
                          label: l10n.practiceWithMe,
                          onTap: () {
                            if (_messages.length > 1) {
                              // Already chatting — switch to practice mode in-place
                              setState(() => _isPracticeMode = true);
                              _sendPracticePrompt();
                            } else {
                              // Fresh chat — go to scenario picker
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PracticeScreen(apiKey: widget.apiKey),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      // _ActionChip(
                      //   icon: Icons.refresh,
                      //   label: l10n.continueChat,
                      //   onTap: () {
                      //     _controller.clear();
                      //     FocusScope.of(context).requestFocus(FocusNode());
                      //     Future.delayed(const Duration(milliseconds: 100), () {
                      //       _scrollToBottom();
                      //     });
                      //   },
                      // ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                // Listening overlay
                if (_isListening) const _ListeningIndicator(),

                // Input field
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _listen,
                          child: Container(
                            margin: const EdgeInsets.only(left: 4),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _isListening
                                  ? Colors.red
                                  : const Color(0xFF0055CC)
                                      .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              _isListening ? Icons.stop : Icons.mic,
                              color: _isListening
                                  ? Colors.white
                                  : const Color(0xFF0055CC),
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: _isListening
                                  ? (context.isEnglish
                                      ? 'Listening...'
                                      : 'Slušam...')
                                  : l10n.askAboutSoftSkills,
                              hintStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: _isListening
                                    ? Colors.red.shade300
                                    : Colors.grey.shade400,
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0055CC),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: IconButton(
                            onPressed: _sendMessage,
                            icon: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Input field
                // Padding(
                //   padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                //   child: Container(
                //     padding:
                //         const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: BorderRadius.circular(28),
                //     ),
                //     child: Row(
                //       children: [
                //         Expanded(
                //           child: TextField(
                //             controller: _controller,
                //             style: const TextStyle(
                //               fontFamily: 'Montserrat',
                //               fontSize: 14,
                //               color: Colors.black87,
                //             ),
                //             decoration: InputDecoration(
                //               hintText: l10n.askAboutSoftSkills,
                //               hintStyle: TextStyle(
                //                 fontFamily: 'Montserrat',
                //                 fontSize: 14,
                //                 color: Colors.grey.shade400,
                //               ),
                //               border: InputBorder.none,
                //               contentPadding:
                //                   const EdgeInsets.symmetric(horizontal: 16),
                //             ),
                //             onSubmitted: (_) => _sendMessage(),
                //           ),
                //         ),
                //         Container(
                //           margin: const EdgeInsets.only(right: 4),
                //           decoration: BoxDecoration(
                //             color: const Color(0xFF0055CC),
                //             borderRadius: BorderRadius.circular(22),
                //           ),
                //           child: IconButton(
                //             onPressed: _sendMessage,
                //             icon: const Icon(
                //               Icons.send,
                //               color: Colors.white,
                //               size: 20,
                //             ),
                //             constraints: const BoxConstraints(
                //               minWidth: 40,
                //               minHeight: 40,
                //             ),
                //             padding: EdgeInsets.zero,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

//   Future<void> _sendPracticePrompt() async {
//     setState(() => _isLoading = true);
//     _scrollToBottom();

//     final response = await http.post(
//       Uri.parse("https://api.openai.com/v1/chat/completions"),
//       headers: {
//         "Authorization": "Bearer ${widget.apiKey}",
//         "Content-Type": "application/json",
//       },
//       body: json.encode({
//         "model": "gpt-4-turbo",
//         "messages": [
//           {
//             "role": "system",
//             "content": context.isEnglish
//                 ? '''You are a soft skills practice partner. Create a short, realistic workplace scenario (3-4 sentences) where the user needs to apply a soft skill. Then say "Your turn — how would you respond?" Do NOT give tips yet. Wait for the user to respond, then give brief feedback.'''
//                 : '''Ti si partner za vežbanje mekih veština. Napravi kratak, realističan scenario sa posla (3-4 rečenice) gde korisnik treba da primeni neku meku veštinu. Zatim reci "Tvoj red — kako bi odgovorio?" NE daj savete još. Sačekaj da korisnik odgovori, pa daj kratak komentar.
// VAŽNO: Piši isključivo na srpskom jeziku, ekavica.''',
//           },
//           ..._messages.map((m) => {"role": m["role"], "content": m["text"]}),
//         ],
//       }),
//     );

//     final replyTime = TimeOfDay.now().format(context);

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final reply = data['choices'][0]['message']['content'];
//       setState(() {
//         _messages.add({"role": "assistant", "text": reply, "time": replyTime});
//         _isLoading = false;
//       });
//     } else {
//       setState(() {
//         _messages
//             .add({"role": "assistant", "text": "Error", "time": replyTime});
//         _isLoading = false;
//       });
//     }
//     _scrollToBottom();
//   }
  Future<void> _sendPracticePrompt() async {
    setState(() => _isLoading = true);
    _scrollToBottom();

    final scenario = widget.practiceScenario ?? '';

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
                ? '''You are a soft skills practice partner. The user wants to practice: "$scenario". Create a short, realistic workplace scenario (3-4 sentences) related to this topic. Play the role of the other person in the scenario. End with "Your turn — how would you respond?" Do NOT give tips yet. Stay in character.'''
                : '''Ti si partner za vežbanje mekih veština. Korisnik želi da vežba: "$scenario". Napravi kratak, realističan scenario sa posla (3-4 rečenice) vezan za ovu temu. Igraj ulogu druge osobe u scenariju. Završi sa "Tvoj red — kako bi odgovorio?" NE daj savete još. Ostani u ulozi.
VAŽNO: Piši isključivo na srpskom jeziku, ekavica.''',
          },
          ..._messages.map((m) => {"role": m["role"], "content": m["text"]}),
        ],
      }),
    );

    final replyTime = TimeOfDay.now().format(context);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final reply = data['choices'][0]['message']['content'];
      setState(() {
        _messages.add({"role": "assistant", "text": reply, "time": replyTime});
        _isLoading = false;
      });
    } else {
      setState(() {
        _messages
            .add({"role": "assistant", "text": "Error", "time": replyTime});
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }
}

class _ListeningIndicator extends StatefulWidget {
  const _ListeningIndicator();

  @override
  State<_ListeningIndicator> createState() => _ListeningIndicatorState();
}

class _ListeningIndicatorState extends State<_ListeningIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pulsing mic icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(alpha: 0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red
                            .withValues(alpha: 0.4 * _pulseAnimation.value),
                        blurRadius: 12 * _pulseAnimation.value,
                        spreadRadius: 4 * (_pulseAnimation.value - 0.8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          // Sound wave bars
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(7, (index) {
                  final offset = index * 0.12;
                  final value = ((_waveController.value + offset) % 1.0);
                  final height = 8.0 +
                      16.0 *
                          (0.5 + 0.5 * _sin(value * 3.14159 * 2))
                              .clamp(0.0, 1.0);
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 4,
                    height: height,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                          alpha: (0.5 + 0.5 * _sin(value * 3.14159 * 2))
                              .clamp(0.0, 1.0)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(width: 16),
          // Label
          Text(
            context.isEnglish ? 'Listening...' : 'Slušam...',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  double _sin(double x) {
    // Simple sine approximation
    x = x % (2 * 3.14159);
    if (x < 0) x += 2 * 3.14159;
    double result = x;
    double term = x;
    for (int i = 1; i <= 5; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromARGB(255, 10, 10, 10),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color.fromARGB(255, 14, 13, 13)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color.fromARGB(255, 12, 12, 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
