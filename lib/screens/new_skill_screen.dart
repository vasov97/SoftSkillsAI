import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softai/cubit/user_cubit.dart';
import 'package:softai/di/di.dart';
import 'package:softai/extensions/l10n_extension.dart';
import 'package:softai/model/user.dart';
import 'package:softai/service/subscription_service.dart';
import 'package:softai/widgets/pro_overlay.dart';

import 'skills_details_screen.dart';

class NewSkillScreen extends StatefulWidget {
  const NewSkillScreen({
    super.key,
    required this.user,
  });
  final UserModel user;

  @override
  State<NewSkillScreen> createState() => _NewSkillScreenState();
}

class _NewSkillScreenState extends State<NewSkillScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _avatarOpacity;
  late Animation<double> _bubbleOpacity;
  late Animation<double> _skillsOpacity;
  late Animation<double> _buttonOpacity;

  /// Tracks what the user selects in this session only
  final Map<String, double> sessionSkills = {};

  /// Cached DB skills — loaded once, never rebuilt by BlocBuilder
  Map<String, double>? _dbSkills;

  late final UserCubit userCubit;
  bool _isSaving = false;
  final _subscriptionService = locator<SubscriptionService>();
  @override
  void initState() {
    super.initState();

    userCubit = locator<UserCubit>();
    userCubit.loadUser();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _avatarOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );

    _bubbleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.50, curve: Curves.easeOut),
      ),
    );

    _skillsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.50, 0.75, curve: Curves.easeOut),
      ),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 0.99, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSpeechBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Text(
        context.l10n.timeToLearnNewSkill,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSkillsList() {
    if (_dbSkills == null) {
      return const Center(
        child: SizedBox(
          height: 32,
          width: 32,
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final l10n = context.l10n;

    return ListView(
      children: [
        for (int i = 0; i < _skillsList.length; i++)
          _SoftSkillTile(
            skillKey: _skillsList[i],
            text: context.getSkillTranslation(_skillsList[i], l10n),
            isSelected: sessionSkills.containsKey(_skillsList[i]),
            isDisabled: false,
            isLocked: _subscriptionService.isSkillLocked(i, 0),
            alreadyTrained: _dbSkills!.containsKey(_skillsList[i]),
            onTap: () async {
              if (_subscriptionService.isSkillLocked(i, 0)) {
                await ProLockOverlay.show(
                  context,
                  reason: context.isEnglish
                      ? 'Free users can access 2 skills. Upgrade to Pro to unlock all 20 skills.'
                      : 'Besplatni korisnici imaju pristup 2 veštine. Nadogradi na Pro da otključaš svih 20.',
                );
                return;
              }
              setState(() {
                if (sessionSkills.containsKey(_skillsList[i])) {
                  sessionSkills.remove(_skillsList[i]);
                } else {
                  sessionSkills[_skillsList[i]] = 0.0;
                }
              });
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<UserCubit, UserState>(
        bloc: userCubit,
        listener: (context, state) {
          // Capture DB skills once when loaded
          if (state is UserLoaded && _dbSkills == null) {
            setState(() {
              _dbSkills = Map<String, double>.from(state.user.selectedSkills);
            });
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background gradient
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

            // Animated Avatar and Bubble
            Positioned(
              bottom: 120,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Speech bubble
                        Positioned(
                          left: -16,
                          top: 60,
                          child: Opacity(
                            opacity: _bubbleOpacity.value,
                            child: _buildSpeechBubble(),
                          ),
                        ),
                        // Avatar
                        Positioned(
                          right: 0,
                          top: 48,
                          child: Opacity(
                            opacity: _avatarOpacity.value,
                            child: Image.asset(
                              'assets/avatar.png',
                              scale: 3.5,
                            ),
                          ),
                        ),
                        // Skills list
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          top: 320,
                          child: Opacity(
                            opacity: _skillsOpacity.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: _buildSkillsList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Continue button
            Positioned(
              bottom: 24,
              child: Opacity(
                opacity: _buttonOpacity.value,
                child: SizedBox(
                  width: 180,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            if (sessionSkills.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(context.l10n.pleaseSelectSkill),
                                ),
                              );
                              return;
                            }

                            setState(() => _isSaving = true);

                            // Save all selected skills to Firebase
                            for (final skill in sessionSkills.keys) {
                              await userCubit.toggleSkill(skillName: skill);
                            }

                            if (!mounted) return;
                            setState(() => _isSaving = false);

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SkillDetailScreen(
                                  user: widget.user,
                                  skills: sessionSkills,
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            context.l10n.continueForward,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const List<String> _skillsList = [
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
  "Self-Motivation",
];

class _SoftSkillTile extends StatelessWidget {
  final String text;
  final String skillKey;
  final bool isSelected;
  final bool isDisabled;
  final bool alreadyTrained;
  final VoidCallback onTap;
  final bool isLocked;
  const _SoftSkillTile({
    required this.text,
    required this.skillKey,
    required this.isSelected,
    this.isDisabled = false,
    this.alreadyTrained = false,
    required this.onTap,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.8),
            width: 1.5,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: isSelected
                  ? [
                      Colors.white.withValues(alpha: 0.9),
                      const Color(0xFF00E5E5).withValues(alpha: 0.25),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.7),
                      Colors.white.withValues(alpha: 0.05),
                    ],
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            children: [
              Image.asset(
                _getSkillIcon(skillKey),
                width: 28,
                height: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              if (isLocked)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, size: 12, color: Colors.white),
                      SizedBox(width: 3),
                      Text(
                        'PRO',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              else if (isSelected)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.9),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                )
              else if (alreadyTrained)
                const Icon(
                  Icons.replay,
                  color: Colors.white,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String _getSkillIcon(String skillKey) {
  final map = {
    'Communication': 'assets/communication2.png',
    'Leadership': 'assets/leader.png',
    'Teamwork': 'assets/team.png',
    'Problem-Solving': 'assets/solve.png',
    'Time Management': 'assets/time.png',
    'Adaptability': 'assets/skill_adaptability.png',
    'Emotional Intelligence': 'assets/skill_emotional_intelligence.png',
    'Conflict Resolution': 'assets/conflict.png',
    'Creativity': 'assets/creativity.png',
    'Decision Making': 'assets/skill_decision_making.png',
    'Critical Thinking': 'assets/skill_critical_thinking.png',
    'Negotiation': 'assets/negotation.png',
    'Active Listening': 'assets/active.png',
    'Work Ethic': 'assets/skill_work_ethic.png',
    'Interpersonal Skills': 'assets/inter.png',
    'Stress Management': 'assets/stress.png',
    'Networking': 'assets/networking.png',
    'Coaching & Mentoring': 'assets/mentoring.png',
    'Persuasion': 'assets/persuasion.png',
    'Self-Motivation': 'assets/skill_self_motivation.png',
  };
  return map[skillKey] ?? 'assets/skill_default.png';
}
