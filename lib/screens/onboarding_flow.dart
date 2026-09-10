import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softai/extensions/l10n_extension.dart';
import 'package:softai/screens/paywall_screen.dart';
import 'package:softai/screens/start_screen.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 6;
  final Set<String> _selectedInterests = {};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (_selectedInterests.isNotEmpty) {
      await prefs.setStringList(
          'onboarding_interests', _selectedInterests.toList());
    }
    if (!mounted) return;

    // Show paywall first
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );

    if (!mounted) return;

    // Then continue to start screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const StartScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
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
            child: Column(
              children: [
                // Top bar: progress + skip
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 12, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (_currentPage + 1) / _totalPages,
                            minHeight: 6,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.3),
                            color: Colors.white,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _finishOnboarding,
                        child: Text(
                          l10n.skip,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) =>
                        setState(() => _currentPage = page),
                    children: [
                      _WelcomePage(),
                      _SkillsPage(),
                      _ChatPage(),
                      _GoalsPage(),
                      _InterestsPage(
                        selected: _selectedInterests,
                        onChanged: (skill) {
                          setState(() {
                            if (_selectedInterests.contains(skill)) {
                              _selectedInterests.remove(skill);
                            } else {
                              _selectedInterests.add(skill);
                            }
                          });
                        },
                      ),
                      _ReadyPage(),
                    ],
                  ),
                ),

                // Bottom button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0055CC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _totalPages - 1
                            ? l10n.getStarted
                            : l10n.continueForward,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============ PAGE 1: WELCOME ============
class _WelcomePage extends StatefulWidget {
  @override
  State<_WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<_WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _bounce = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -20), weight: 30),
      TweenSequenceItem(tween: Tween(begin: -20, end: 0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -10, end: 0), weight: 20),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _bounce,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _bounce.value),
                child: child,
              );
            },
            child: Image.asset('assets/avatar.png', width: 180, height: 180),
          ),
          const SizedBox(height: 40),
          Text(
            l10n.onboardingWelcomeTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingWelcomeSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16,
              color:
                  const Color.fromARGB(255, 44, 43, 43).withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ PAGE 2: SKILLS ============
class _SkillsPage extends StatefulWidget {
  @override
  State<_SkillsPage> createState() => _SkillsPageState();
}

class _SkillsPageState extends State<_SkillsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<_SkillIcon> _skillIcons = [
    _SkillIcon('assets/communication2.png', 'Communication'),
    _SkillIcon('assets/leader.png', 'Leadership'),
    _SkillIcon('assets/team.png', 'Teamwork'),
    _SkillIcon('assets/creativity.png', 'Creativity'),
    _SkillIcon('assets/negotation.png', 'Negotiation'),
    _SkillIcon('assets/active.png', 'Active Listening'),
    _SkillIcon('assets/stress.png', 'Stress Management'),
    _SkillIcon('assets/time.png', 'Time Management'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 220,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: _skillIcons.length,
              itemBuilder: (context, index) {
                final start = index * 0.1;
                final end = (start + 0.4).clamp(0.0, 1.0);
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final value = Interval(start, end, curve: Curves.easeOut)
                        .transform(_controller.value);
                    return Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: 0.5 + 0.5 * value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(_skillIcons[index].asset),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
          Text(
            l10n.onboardingSkillsTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingSkillsSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 15,
              color:
                  const Color.fromARGB(255, 44, 43, 43).withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillIcon {
  final String asset;
  final String label;
  _SkillIcon(this.asset, this.label);
}

// ============ PAGE 3: CHAT ============
class _ChatPage extends StatefulWidget {
  @override
  State<_ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<_ChatPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Bot bubble
                Positioned(
                  left: 20,
                  top: 20,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final v = Interval(0.0, 0.4, curve: Curves.easeOut)
                          .transform(_controller.value);
                      return Opacity(
                        opacity: v,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - v)),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        l10n.onboardingChatBubble1,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
                // User bubble
                Positioned(
                  right: 20,
                  top: 90,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final v = Interval(0.3, 0.7, curve: Curves.easeOut)
                          .transform(_controller.value);
                      return Opacity(
                        opacity: v,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - v)),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0055CC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        l10n.onboardingChatBubble2,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                // Second bot bubble
                Positioned(
                  left: 40,
                  top: 160,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final v = Interval(0.6, 1.0, curve: Curves.easeOut)
                          .transform(_controller.value);
                      return Opacity(
                        opacity: v,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - v)),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        l10n.onboardingChatBubble3,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text(
            l10n.onboardingChatTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingChatSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 15,
              color:
                  const Color.fromARGB(255, 44, 43, 43).withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ PAGE 4: GOALS ============
class _GoalsPage extends StatefulWidget {
  @override
  State<_GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<_GoalsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _progress = Tween<double>(begin: 0, end: 0.75).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0066FF).withValues(alpha: 0.12),
                      ),
                      child: const Icon(Icons.gps_fixed,
                          color: Color(0xFF0066FF), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.onboardingGoalExample,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AnimatedBuilder(
                  animation: _progress,
                  builder: (context, _) {
                    return Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: _progress.value,
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade200,
                            color: const Color(0xFF0066FF),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${(_progress.value * 100).round()}%',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text(
            l10n.onboardingGoalsTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingGoalsSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ PAGE 5: INTERESTS ============
class _InterestsPage extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onChanged;

  const _InterestsPage({
    required this.selected,
    required this.onChanged,
  });

  static const List<String> _interests = [
    'Communication',
    'Leadership',
    'Public speaking',
    'Networking',
    'Confidence',
    'Time Management',
    'Negotiation',
    'Teamwork',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.onboardingInterestsTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.onboardingInterestsSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: _interests.map((skill) {
              final isSelected = selected.contains(skill);
              return GestureDetector(
                onTap: () => onChanged(skill),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(Icons.check,
                              size: 16, color: Color(0xFF0055CC)),
                        ),
                      Text(
                        skill,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF0055CC)
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ============ PAGE 6: READY ============
class _ReadyPage extends StatefulWidget {
  @override
  State<_ReadyPage> createState() => _ReadyPageState();
}

class _ReadyPageState extends State<_ReadyPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _scale,
            builder: (context, child) {
              return Transform.scale(
                scale: _scale.value.clamp(0.0, 1.5),
                child: child,
              );
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 72,
                color: Color(0xFF00CC88),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            l10n.onboardingReadyTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.onboardingReadySubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
