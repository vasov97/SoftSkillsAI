import 'package:flutter/material.dart';
import 'package:softai/extensions/l10n_extension.dart';
import 'package:softai/screens/chat_screen.dart';

class PracticeScreen extends StatefulWidget {
  final String apiKey;

  const PracticeScreen({
    super.key,
    required this.apiKey,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  String? _selectedScenario;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final scenarios = [
      _ScenarioData(
        key: 'difficult_conversation',
        label: l10n.scenarioDifficultConversation,
        icon: Icons.chat_bubble_outline,
      ),
      _ScenarioData(
        key: 'presentation',
        label: l10n.scenarioPresentation,
        icon: Icons.present_to_all,
      ),
      _ScenarioData(
        key: 'feedback',
        label: l10n.scenarioFeedback,
        icon: Icons.rate_review_outlined,
      ),
      _ScenarioData(
        key: 'client_meeting',
        label: l10n.scenarioClientMeeting,
        icon: Icons.handshake_outlined,
      ),
      _ScenarioData(
        key: 'negotiation',
        label: l10n.scenarioNegotiation,
        icon: Icons.balance_outlined,
      ),
      _ScenarioData(
        key: 'other',
        label: l10n.scenarioOther,
        icon: Icons.more_horiz,
      ),
    ];

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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    l10n.practiceWithSkillena,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.chooseScenario,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Scenario tiles
                  Expanded(
                    child: ListView.builder(
                      itemCount: scenarios.length,
                      itemBuilder: (context, index) {
                        final scenario = scenarios[index];
                        final isSelected = _selectedScenario == scenario.key;

                        return GestureDetector(
                          onTap: () {
                            if (scenario.key == 'other') {
                              _showCustomScenarioDialog();
                              return;
                            }

                            final navigator = Navigator.of(context);
                            setState(() => _selectedScenario = scenario.key);

                            Future.delayed(
                              const Duration(milliseconds: 300),
                              () {
                                navigator.push(
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      apiKey: widget.apiKey,
                                      practiceScenario: scenario.label,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF0055CC)
                                        .withValues(alpha: 0.15),
                                  ),
                                  child: Icon(
                                    scenario.icon,
                                    size: 20,
                                    color: const Color(0xFF0055CC),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    scenario.label,
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.black.withValues(alpha: 0.3),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Avatar bottom right
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

  void _showCustomScenarioDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final l10n = context.l10n;
        return Dialog(
          backgroundColor: Colors.transparent,
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
              padding: const EdgeInsets.all(20),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.describeYourSituation,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0055CC),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: controller,
                      maxLines: 3,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.describeScenarioHint,
                        hintStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          l10n.cancel,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final text = controller.text.trim();
                          if (text.isEmpty) return;

                          final navigator = Navigator.of(context);
                          Navigator.pop(dialogContext);

                          navigator.push(
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                apiKey: widget.apiKey,
                                practiceScenario: text,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0055CC),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          elevation: 0,
                        ),
                        child: Text(
                          l10n.startPractice,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
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
}

class _ScenarioData {
  final String key;
  final String label;
  final IconData icon;

  const _ScenarioData({
    required this.key,
    required this.label,
    required this.icon,
  });
}
