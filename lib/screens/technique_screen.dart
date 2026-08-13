// import 'package:flutter/material.dart';
// import 'package:softai/extensions/l10n_extension.dart';
// import 'package:softai/screens/chat_screen.dart';

// class TechniqueScreen extends StatelessWidget {
//   final String techniqueName;
//   final String explanation;
//   final String apiKey;

//   const TechniqueScreen({
//     super.key,
//     required this.techniqueName,
//     required this.explanation,
//     required this.apiKey,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final l10n = context.l10n;

//     // Placeholder steps — in future these come from AI
//     final steps = context.isEnglish
//         ? [
//             'Maintain eye contact',
//             'Don\'t interrupt',
//             'Ask open questions',
//             'Paraphrase what you heard',
//             'Show empathy and understanding',
//           ]
//         : [
//             'Održavaj kontakt očima',
//             'Ne prekidaj',
//             'Postavljaj pitanja',
//             'Parafraziraj ono što si čuo',
//             'Pokaži empatiju i razumevanje',
//           ];

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
//               padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Title
//                   Text(
//                     l10n.techniqueOfDay,
//                     style: const TextStyle(
//                       fontFamily: 'Montserrat',
//                       fontSize: 24,
//                       fontWeight: FontWeight.w800,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Main card
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Column(
//                       children: [
//                         // Icon
//                         Container(
//                           width: 56,
//                           height: 56,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color:
//                                 const Color(0xFF0066FF).withValues(alpha: 0.12),
//                           ),
//                           child: const Icon(
//                             Icons.hearing,
//                             size: 28,
//                             color: Color(0xFF0066FF),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         // Technique name
//                         Text(
//                           techniqueName,
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(
//                             fontFamily: 'Montserrat',
//                             fontSize: 20,
//                             fontWeight: FontWeight.w800,
//                             color: Color(0xFF1A1A2E),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         // Explanation
//                         Text(
//                           explanation,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontFamily: 'Montserrat',
//                             fontSize: 14,
//                             color: Colors.grey.shade600,
//                             height: 1.5,
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         // Practice with AI button
//                         SizedBox(
//                           width: double.infinity,
//                           height: 48,
//                           child: ElevatedButton(
//                             onPressed: () {
//                               Navigator.of(context).push(
//                                 MaterialPageRoute(
//                                   builder: (_) => ChatScreen(
//                                     apiKey: apiKey,
//                                     practiceScenario: techniqueName,
//                                   ),
//                                 ),
//                               );
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF0055CC),
//                               foregroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(24),
//                               ),
//                               elevation: 0,
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   l10n.practiceWithAI,
//                                   style: const TextStyle(
//                                     fontFamily: 'Montserrat',
//                                     fontSize: 15,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 const Icon(Icons.smart_toy_outlined, size: 20),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 28),

//                   // Technique steps
//                   Text(
//                     l10n.techniqueSteps,
//                     style: const TextStyle(
//                       fontFamily: 'Montserrat',
//                       fontSize: 18,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 14),

//                   ...List.generate(steps.length, (index) {
//                     return Container(
//                       width: double.infinity,
//                       margin: const EdgeInsets.only(bottom: 10),
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withValues(alpha: 0.15),
//                         borderRadius: BorderRadius.circular(14),
//                         border: Border.all(
//                           color: Colors.white.withValues(alpha: 0.2),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 28,
//                             height: 28,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.white.withValues(alpha: 0.2),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 '${index + 1}',
//                                 style: const TextStyle(
//                                   fontFamily: 'Montserrat',
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w700,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Text(
//                               steps[index],
//                               style: const TextStyle(
//                                 fontFamily: 'Montserrat',
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:softai/extensions/l10n_extension.dart';
import 'package:softai/screens/chat_screen.dart';
import 'package:softai/service/lessons_service.dart';
import 'package:softai/widgets/app_bottom_bar.dart';

class TechniqueScreen extends StatefulWidget {
  final String techniqueName;
  final String explanation;
  final String apiKey;

  const TechniqueScreen({
    super.key,
    required this.techniqueName,
    required this.explanation,
    required this.apiKey,
  });

  @override
  State<TechniqueScreen> createState() => _TechniqueScreenState();
}

class _TechniqueScreenState extends State<TechniqueScreen> {
  final LessonService _lessonService = LessonService();
  bool _isSaved = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final techniques = await _lessonService.loadTechniques();
    final alreadySaved =
        techniques.any((t) => t['name'] == widget.techniqueName);
    if (mounted) {
      setState(() => _isSaved = alreadySaved);
    }
  }

  Future<void> _saveTechnique() async {
    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      await _lessonService.saveTechnique(
        name: widget.techniqueName,
        description: widget.explanation,
        date: dateStr,
      );

      if (!mounted) return;

      setState(() {
        _isSaved = true;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF0055CC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.techniqueSaved,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
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
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final steps = context.isEnglish
        ? [
            'Maintain eye contact',
            'Don\'t interrupt',
            'Ask open questions',
            'Paraphrase what you heard',
            'Show empathy and understanding',
          ]
        : [
            'Održavaj kontakt očima',
            'Ne prekidaj',
            'Postavljaj pitanja',
            'Parafraziraj ono što si čuo',
            'Pokaži empatiju i razumevanje',
          ];

    return Scaffold(
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          // MainScreen handles tab switching via its own state
        },
      ),
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    l10n.techniqueOfDay,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Main card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // Icon
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                const Color(0xFF0066FF).withValues(alpha: 0.12),
                          ),
                          child: const Icon(
                            Icons.hearing,
                            size: 28,
                            color: Color(0xFF0066FF),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Technique name
                        Text(
                          widget.techniqueName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Explanation
                        Text(
                          widget.explanation,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Practice with AI button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(
                                    apiKey: widget.apiKey,
                                    practiceScenario: widget.techniqueName,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0055CC),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.practiceWithAI,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.smart_toy_outlined, size: 20),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Save technique button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed:
                                _isSaved || _isSaving ? null : _saveTechnique,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _isSaved
                                  ? const Color(0xFF00CC88)
                                  : const Color(0xFF0055CC),
                              side: BorderSide(
                                color: _isSaved
                                    ? const Color(0xFF00CC88)
                                    : const Color(0xFF0055CC),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF0055CC),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _isSaved
                                            ? Icons.check_circle
                                            : Icons.bookmark_border,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isSaved
                                            ? l10n.techniqueSaved
                                            : l10n.saveTechnique,
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Technique steps
                  Text(
                    l10n.techniqueSteps,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),

                  ...List.generate(steps.length, (index) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
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
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color.fromARGB(255, 17, 17, 17),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              steps[index],
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color.fromARGB(255, 17, 17, 17),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
