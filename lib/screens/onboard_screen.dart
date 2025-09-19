import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softai/cubit/user_cubit.dart';
import 'package:softai/di/di.dart';
import 'package:softai/extensions/l10n_extension.dart';

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
        context.l10n.helloSkillPrompt,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
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
                      Color(0xFF007BFF),
                      Color(0xFF00FFD5),
                    ],
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
                          // Speech bubble (left & above avatar)
                          Positioned(
                            left: -16,
                            top: 32,
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
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            top: 320, // position below avatar & bubble
                            child: Opacity(
                              opacity: _skillsOpacity.value,
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child:
                                      // BlocBuilder<UserCubit, UserState>(
                                      //   bloc: userCubit,
                                      //   builder: (context, state) {
                                      //     if (state is UserLoading ||
                                      //         state is UserInitial) {
                                      //       return const Center(
                                      //           child: CircularProgressIndicator());
                                      //     }

                                      //     if (state is UserError) {
                                      //       return Center(child: Text(state.message));
                                      //     }
                                      //     if (state is UserLoaded) {
                                      //       final user = state.user;
                                      //       final userSkills = user.selectedSkills;
                                      //       return Scrollbar(
                                      //         controller: _scrollController,
                                      //         thumbVisibility: true,
                                      //         child: Padding(
                                      //           padding: const EdgeInsets.all(8.0),
                                      //           child: ListView(
                                      //             controller: _scrollController,
                                      //             children: [
                                      //               for (final skill in _skillsList)
                                      //                 _SoftSkillTile(
                                      //                   text: context
                                      //                       .getSkillTranslation(
                                      //                           skill, l10n),
                                      //                   isSelected: user
                                      //                       .selectedSkills
                                      //                       .containsKey(skill),
                                      //                   isDisabled: userSkills
                                      //                       .containsKey(skill),
                                      //                   onTap: () {
                                      //                     userCubit
                                      //                         .toggleSkill(skill);
                                      //                     setState(() {
                                      //                       _newlySelectedSkills
                                      //                           .add(skill);
                                      //                     });
                                      //                   },
                                      //                 ),
                                      //             ],
                                      //           ),
                                      //         ),
                                      //       );
                                      //     }
                                      //     return const SizedBox.shrink();
                                      //   },
                                      // ),
                                      BlocBuilder<UserCubit, UserState>(
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

                                                return _SoftSkillTile(
                                                  text: context
                                                      .getSkillTranslation(
                                                          skill, l10n),
                                                  isSelected: isSelected,
                                                  isDisabled:
                                                      isSelected, // keep your original behavior
                                                  onTap: () async {
                                                    // New signature:
                                                    // Future<void> toggleSkill({required String goalId, required int index, required bool done})
                                                    await userCubit.toggleSkill(
                                                      goalId:
                                                          'selectedSkills', // stable "container" id for skills
                                                      index:
                                                          i, // index of this skill within _skillsList
                                                      done:
                                                          !isSelected, // true to add/select, false to remove/unselect
                                                    );

                                                    // local UI hint you already had
                                                    setState(() {
                                                      _newlySelectedSkills
                                                          .add(skill);
                                                    });
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
                        ],
                      ),
                    );
                  },
                ),
              ),

              Positioned(
                bottom: 24,
                child: Opacity(
                  opacity: _buttonOpacity.value,
                  child: SizedBox(
                    width: 180,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        final state = userCubit.state;
                        if (state is UserLoaded) {
                          final selectedSkills = state.user.selectedSkills;
                          final user = state.user;

                          if (_newlySelectedSkills.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.l10n.pleaseSelectSkill,
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                            return;
                          }

                          final Map<String, double> skillsToSend =
                              Map.fromEntries(
                            user.selectedSkills.entries.where(
                              (entry) =>
                                  _newlySelectedSkills.contains(entry.key),
                            ),
                          );

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SkillDetailScreen(
                                user: user,
                                skills: skillsToSend,
                              ),
                            ),
                          );
                        }
                      },

                      // onPressed: () {
                      //   final state = userCubit.state;
                      //   if (state is UserLoaded) {
                      //     final selectedSkills = state.user.selectedSkills;
                      //     final user = state.user;
                      //     if (selectedSkills.isEmpty) {
                      //       ScaffoldMessenger.of(context).showSnackBar(
                      //         const SnackBar(
                      //             content:
                      //                 Text("Please select at least one skill")),
                      //       );
                      //       return;
                      //     }
                      //     Navigator.of(context).push(
                      //       MaterialPageRoute(
                      //         builder: (context) => SkillDetailScreen(
                      //           user: user,
                      //           skills: user.selectedSkills,
                      //         ),
                      //       ),
                      //     );
                      //   }
                      // },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
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
// const List<String> _skillsList = [
//   "communication",
//   "leadership",
//   "teamwork",
//   "problemSolving",
//   "timeManagement",
//   "adaptability",
//   "emotionalIntelligence",
//   "conflictResolution",
//   "creativity",
//   "decisionMaking",
//   "criticalThinking",
//   "negotiation",
//   "activeListening",
//   "workEthic",
//   "interpersonalSkills",
//   "stressManagement",
//   "networking",
//   "coachingMentoring",
//   "persuasion",
//   "selfMotivation",
// ];

class _SoftSkillTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _SoftSkillTile({
    required this.text,
    required this.isSelected,
    this.isDisabled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDisabled
        ? Colors.grey.shade300
        : (isSelected ? Colors.blue : Colors.white);
    final textColor =
        isDisabled ? Colors.grey : (isSelected ? Colors.white : Colors.blue);

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
    );
  }
}
