import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softai/cubit/user_cubit.dart';
import 'package:softai/di/di.dart';
import 'package:softai/extensions/l10n_extension.dart';
import 'package:softai/service/subscription_service.dart';
import 'package:softai/widgets/pro_overlay.dart';

import 'skills_details_screen.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _avatarOpacity;
  late Animation<double> _bubbleOpacity;
  late Animation<double> _skillsOpacity;
  late Animation<double> _buttonOpacity;
  final _scrollController = ScrollController();
  final Set<String> _newlySelectedSkills = {};

  late final UserCubit userCubit;
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        // backgroundColor: const Color(0xFF006FFF),

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
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 84, 204, 204),
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
        centerTitle: true,
      ),
      body: BlocBuilder<UserCubit, UserState>(
        bloc: userCubit,
        builder: (context, state) {
          return Stack(
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
              SizedBox(
                height: 32,
              ),
              // Animated Avatar and Bubble
              Positioned(
                bottom: 90,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Speech bubble (left & above avatar)
                          Positioned(
                            left: -16,
                            top: 32,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.helloSkillPrompt,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 28,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                // Text(
                                //   context.l10n.onboardSubtitle,
                                //   style: TextStyle(
                                //     fontFamily: 'Montserrat',
                                //     fontSize: 16,
                                //     color: Colors.white,
                                //     fontWeight: FontWeight.w400,
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          // Avatar

                          Positioned(
                            bottom: 0,
                            left: -40,
                            right: -12,
                            top: 100, // position below avatar & bubble
                            child: Opacity(
                              opacity: _skillsOpacity.value,
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: BlocBuilder<UserCubit, UserState>(
                                    bloc: userCubit,
                                    builder: (context, state) {
                                      if (state is UserLoading ||
                                          state is UserInitial) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }

                                      if (state is UserError) {
                                        return Center(
                                            child: Text(state.message));
                                      }

                                      if (state is UserLoaded) {
                                        final user = state.user;
                                        final userSkills = user.selectedSkills;

                                        return Scrollbar(
                                          controller: _scrollController,
                                          thumbVisibility: true,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ListView.builder(
                                              controller: _scrollController,
                                              itemCount: _skillsList.length,
                                              itemBuilder: (context, i) {
                                                final skill = _skillsList[i];
                                                final isSelected = userSkills
                                                    .containsKey(skill);
                                                final isLocked =
                                                    _subscriptionService
                                                        .isSkillLocked(i, 0);

                                                return SoftSkillTile(
                                                  skillKey: skill,
                                                  text: context
                                                      .getSkillTranslation(
                                                          skill, l10n),
                                                  isSelected: isSelected,
                                                  isDisabled: false,
                                                  isLocked: isLocked,
                                                  onTap: () async {
                                                    if (isLocked) {
                                                      await ProLockOverlay.show(
                                                        context,
                                                        reason: context
                                                                .isEnglish
                                                            ? 'Free users can select 2 skills. Upgrade to Pro to unlock all 20 skills.'
                                                            : 'Besplatni korisnici biraju 2 veštine. Nadogradi na Pro da otključaš svih 20.',
                                                      );
                                                      return;
                                                    }
                                                    final navigator =
                                                        Navigator.of(context);

                                                    await userCubit.toggleSkill(
                                                        skillName: skill);

                                                    _newlySelectedSkills
                                                        .add(skill);

                                                    final currentState =
                                                        userCubit.state;
                                                    if (currentState
                                                        is UserLoaded) {
                                                      final user =
                                                          currentState.user;
                                                      navigator.push(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              SkillDetailScreen(
                                                            user: user,
                                                            skills: {
                                                              skill: user.selectedSkills[
                                                                      skill] ??
                                                                  0.0
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    // await userCubit.toggleSkill(
                                                    //     skillName: skill);
                                                    // setState(() {
                                                    //   _newlySelectedSkills
                                                    //       .add(skill);
                                                    // });

                                                    // if (!mounted) return;

                                                    // final currentState =
                                                    //     userCubit.state;
                                                    // if (currentState
                                                    //     is UserLoaded) {
                                                    //   final user =
                                                    //       currentState.user;
                                                    //   Navigator.of(context)
                                                    //       .push(
                                                    //     MaterialPageRoute(
                                                    //       builder: (context) =>
                                                    //           SkillDetailScreen(
                                                    //         user: user,
                                                    //         skills: {
                                                    //           skill: user.selectedSkills[
                                                    //                   skill] ??
                                                    //               0.0
                                                    //         },
                                                    //       ),
                                                    //     ),
                                                    //   );
                                                    // }
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      }

                                      return const SizedBox.shrink();
                                    },
                                  )),
                            ),
                          ),
                          Positioned(
                            right: -32,
                            bottom: -80,
                            child: Opacity(
                              opacity: _avatarOpacity.value,
                              child: Image.asset(
                                'assets/avatar.png',
                                height: 112,
                                width: 112,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Positioned(
              //   bottom: 24,
              //   child: Opacity(
              //     opacity: _buttonOpacity.value,
              //     child: SizedBox(
              //       width: 180,
              //       height: 44,
              //       child: ElevatedButton(
              //         onPressed: () {
              //           final state = userCubit.state;
              //           if (state is UserLoaded) {
              //             final selectedSkills = state.user.selectedSkills;
              //             final user = state.user;

              //             if (_newlySelectedSkills.isEmpty) {
              //               ScaffoldMessenger.of(context).showSnackBar(
              //                 SnackBar(
              //                   content: Text(
              //                     context.l10n.pleaseSelectSkill,
              //                     style: TextStyle(
              //                       fontFamily: 'Montserrat',
              //                       fontSize: 16,
              //                       color: Colors.white,
              //                     ),
              //                   ),
              //                 ),
              //               );
              //               return;
              //             }

              //             final Map<String, double> skillsToSend =
              //                 Map.fromEntries(
              //               user.selectedSkills.entries.where(
              //                 (entry) =>
              //                     _newlySelectedSkills.contains(entry.key),
              //               ),
              //             );

              //             Navigator.of(context).push(
              //               MaterialPageRoute(
              //                 builder: (context) => SkillDetailScreen(
              //                   user: user,
              //                   skills: skillsToSend,
              //                 ),
              //               ),
              //             );
              //           }
              //         },
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: Colors.blue,
              //           foregroundColor: Colors.white,
              //           shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(22),
              //           ),
              //           elevation: 0,
              //         ),
              //         child: Text(
              //           l10n.continueForward,
              //           style: TextStyle(
              //             fontFamily: 'Montserrat',
              //             fontSize: 16,
              //             fontWeight: FontWeight.w700,
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          );
        },
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

class SoftSkillTile extends StatelessWidget {
  final String text;
  final String skillKey;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;
  final bool isLocked;
  const SoftSkillTile({
    super.key,
    required this.text,
    required this.skillKey,
    required this.isSelected,
    this.isDisabled = false,
    required this.onTap,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white : Colors.white.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(18),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isSelected ? const Color(0xFF0055CC) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF0055CC) : Colors.white,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
          ],
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
