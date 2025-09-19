// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:softai/cubit/user_cubit.dart';
// import 'package:softai/di/di.dart';
// import 'package:softai/model/user.dart';

// import 'skills_details_screen.dart';

// class NewSkillScreen extends StatefulWidget {
//   const NewSkillScreen({
//     super.key,
//     required this.user,
//   });
//   final UserModel user;

//   @override
//   State<NewSkillScreen> createState() => _NewSkillScreenState();
// }

// class _NewSkillScreenState extends State<NewSkillScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _avatarOpacity;
//   late Animation<double> _bubbleOpacity;
//   late Animation<double> _skillsOpacity;
//   late Animation<double> _buttonOpacity;
//   Map<String, double> tempSelectedSkills = {};

//   late final UserCubit userCubit;

//   @override
//   void initState() {
//     super.initState();

//     userCubit = locator<UserCubit>();
//     userCubit.loadUser();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     );

//     _avatarOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
//       ),
//     );

//     _bubbleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.25, 0.50, curve: Curves.easeOut),
//       ),
//     );

//     _skillsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.50, 0.75, curve: Curves.easeOut),
//       ),
//     );

//     _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.75, 0.99, curve: Curves.easeOut),
//       ),
//     );

//     _controller.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         setState(() {}); // Force UI refresh
//       }
//     });

//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   Widget _buildSpeechBubble() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 4,
//             offset: const Offset(2, 2),
//           ),
//         ],
//       ),
//       child: const Text(
//         "Time to learn new skill!",
//         style: TextStyle(
//           fontFamily: 'Montserrat',
//           fontSize: 16,
//           color: Colors.black87,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocBuilder<UserCubit, UserState>(
//         bloc: userCubit,
//         builder: (context, state) {
//           return Stack(
//             alignment: Alignment.center,
//             children: [
//               // Background gradient
//               Container(
//                 width: double.infinity,
//                 height: double.infinity,
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Color(0xFF007BFF),
//                       Color(0xFF00FFD5),
//                     ],
//                   ),
//                 ),
//               ),

//               // Animated Avatar and Bubble
//               Positioned(
//                 bottom: 120,
//                 child: AnimatedBuilder(
//                   animation: _controller,
//                   builder: (context, child) {
//                     return SizedBox(
//                       width: MediaQuery.of(context).size.width * 0.8,
//                       height: MediaQuery.of(context).size.height * 0.8,
//                       child: Stack(
//                         clipBehavior: Clip.none,
//                         children: [
//                           // Speech bubble (left & above avatar)
//                           Positioned(
//                             left: -16,
//                             top: 32,
//                             child: Opacity(
//                               opacity: _bubbleOpacity.value,
//                               child: _buildSpeechBubble(),
//                             ),
//                           ),
//                           // Avatar
//                           Positioned(
//                             right: 0,
//                             top: 48,
//                             child: Opacity(
//                               opacity: _avatarOpacity.value,
//                               child: Image.asset(
//                                 'assets/avatar.png',
//                                 scale: 3.5,
//                               ),
//                             ),
//                           ),
//                           Positioned(
//                             bottom: 0,
//                             left: 0,
//                             right: 0,
//                             top: 320, // position below avatar & bubble
//                             child: Opacity(
//                               opacity: _skillsOpacity.value,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 16, vertical: 12),
//                                 child: BlocBuilder<UserCubit, UserState>(
//                                   bloc: userCubit,
//                                   builder: (context, state) {
//                                     if (state is UserLoading ||
//                                         state is UserInitial) {
//                                       return const Center(
//                                           child: CircularProgressIndicator());
//                                     }

//                                     if (state is UserError) {
//                                       return Center(child: Text(state.message));
//                                     }
//                                     if (state is UserLoaded) {
//                                       final user = state.user;
//                                       final dbSkills = Map<String, double>.from(
//                                           user.selectedSkills);

//                                       return ListView(
//                                         children: [
//                                           for (final skill in _skillsList)
//                                             _SoftSkillTile(
//                                               text: skill,

//                                               // ✅ Blue if selected this session
//                                               isSelected: tempSelectedSkills
//                                                   .containsKey(skill),

//                                               // ✅ Grey only for skills already in Firestore when screen loaded
//                                               isDisabled:
//                                                   dbSkills.containsKey(skill),

//                                               onTap: () async {
//                                                 if (!dbSkills
//                                                     .containsKey(skill)) {
//                                                   setState(() {
//                                                     if (tempSelectedSkills
//                                                         .containsKey(skill)) {
//                                                       tempSelectedSkills
//                                                           .remove(skill);
//                                                     } else {
//                                                       tempSelectedSkills[
//                                                           skill] = 0.0;
//                                                     }
//                                                   });

//                                                   // ✅ Update Firestore
//                                                   await userCubit
//                                                       .toggleSkill(skill);
//                                                 }
//                                               },
//                                             ),
//                                         ],
//                                       );
//                                     }

//                                     return const SizedBox.shrink();
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),

//               Positioned(
//                 bottom: 24,
//                 child: Opacity(
//                   opacity: _buttonOpacity.value,
//                   child: SizedBox(
//                     width: 180,
//                     height: 44,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         final state = userCubit.state;
//                         if (state is UserLoaded) {
//                           final selectedSkills = state.user.selectedSkills;
//                           final user = state.user;
//                           if (selectedSkills.isEmpty) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                   content:
//                                       Text("Please select at least one skill")),
//                             );
//                             return;
//                           }
//                           Navigator.of(context).push(
//                             MaterialPageRoute(
//                               builder: (context) => SkillDetailScreen(
//                                 user: user,
//                                 skills: tempSelectedSkills,
//                               ),
//                             ),
//                           );
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blue,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(22),
//                         ),
//                         elevation: 0,
//                       ),
//                       child: const Text(
//                         'Continue',
//                         style: TextStyle(
//                           fontFamily: 'Montserrat',
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// const List<String> _skillsList = [
//   "Communication",
//   "Leadership",
//   "Teamwork",
//   "Problem-Solving",
//   "Time Management",
//   "Adaptability",
//   "Emotional Intelligence",
//   "Conflict Resolution",
//   "Creativity",
//   "Decision Making",
//   "Critical Thinking",
//   "Negotiation",
//   "Active Listening",
//   "Work Ethic",
//   "Interpersonal Skills",
//   "Stress Management",
//   "Networking",
//   "Coaching & Mentoring",
//   "Persuasion",
//   "Self-Motivation",
// ];

// class _SoftSkillTile extends StatelessWidget {
//   final String text;
//   final bool isSelected;
//   final bool isDisabled;
//   final VoidCallback onTap;

//   const _SoftSkillTile({
//     required this.text,
//     required this.isSelected,
//     this.isDisabled = false,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bgColor = isDisabled
//         ? Colors.grey.shade300
//         : (isSelected ? Colors.blue : Colors.white);
//     final textColor =
//         isDisabled ? Colors.grey : (isSelected ? Colors.white : Colors.blue);

//     return GestureDetector(
//       onTap: isDisabled ? null : onTap,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         decoration: BoxDecoration(
//           color: bgColor,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Text(
//           text,
//           style: TextStyle(
//             color: textColor,
//             fontWeight: FontWeight.w600,
//             fontSize: 16,
//             fontFamily: 'Montserrat',
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softai/cubit/user_cubit.dart';
import 'package:softai/di/di.dart';
import 'package:softai/model/user.dart';

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

  /// Tracks what the user selects in this session (blue)
  final Map<String, double> sessionSkills = {};

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
      child: const Text(
        "Time to learn new skill!",
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
                            top: 320,
                            child: Opacity(
                              opacity: _skillsOpacity.value,
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child:
                                      //  BlocBuilder<UserCubit, UserState>(
                                      //   bloc: userCubit,
                                      //   builder: (context, state) {
                                      //     if (state is UserLoading ||
                                      //         state is UserInitial) {
                                      //       return const Center(
                                      //         child: SizedBox(
                                      //           height: 32,
                                      //           width: 32,
                                      //           child: CircularProgressIndicator(),
                                      //         ),
                                      //       );
                                      //     }

                                      //     if (state is UserError) {
                                      //       return Center(child: Text(state.message));
                                      //     }
                                      //     if (state is UserLoaded) {
                                      //       final user = state.user;
                                      //       final dbSkills = Map<String, double>.from(
                                      //           user.selectedSkills);

                                      //       return ListView(
                                      //         children: [
                                      //           for (final skill in _skillsList)
                                      //             _SoftSkillTile(
                                      //               text: skill,
                                      //               // ✅ Blue if selected in this session
                                      //               isSelected: sessionSkills
                                      //                   .containsKey(skill),
                                      //               // ✅ Grey only for DB skills that are NOT newly selected
                                      //               isDisabled:
                                      //                   dbSkills.containsKey(skill) &&
                                      //                       !sessionSkills
                                      //                           .containsKey(skill),
                                      //               onTap: () async {
                                      //                 if (!dbSkills
                                      //                     .containsKey(skill)) {
                                      //                   setState(() {
                                      //                     if (sessionSkills
                                      //                         .containsKey(skill)) {
                                      //                       sessionSkills
                                      //                           .remove(skill);
                                      //                     } else {
                                      //                       sessionSkills[skill] =
                                      //                           0.0;
                                      //                     }
                                      //                   });
                                      //                   await userCubit
                                      //                       .toggleSkill(skill);
                                      //                 }
                                      //               },
                                      //             ),
                                      //         ],
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
                                          child: SizedBox(
                                            height: 32,
                                            width: 32,
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      }

                                      if (state is UserError) {
                                        return Center(
                                            child: Text(state.message));
                                      }

                                      if (state is UserLoaded) {
                                        final user = state.user;
                                        final dbSkills =
                                            Map<String, double>.from(
                                                user.selectedSkills);

                                        return ListView(
                                          children: [
                                            for (final skill in _skillsList)
                                              _SoftSkillTile(
                                                text: skill,
                                                // Blue if selected in THIS session
                                                isSelected: sessionSkills
                                                    .containsKey(skill),
                                                // Grey only for DB skills that are NOT newly selected
                                                isDisabled: dbSkills
                                                        .containsKey(skill) &&
                                                    !sessionSkills
                                                        .containsKey(skill),
                                                onTap: () async {
                                                  // Block taps for skills already saved in DB (unless they’re also in the session set)
                                                  if (!dbSkills
                                                      .containsKey(skill)) {
                                                    final wasSelectedInSession =
                                                        sessionSkills
                                                            .containsKey(skill);
                                                    final newDone =
                                                        !wasSelectedInSession; // true = select/add, false = unselect/remove

                                                    // Local UI state toggle
                                                    setState(() {
                                                      if (wasSelectedInSession) {
                                                        sessionSkills
                                                            .remove(skill);
                                                      } else {
                                                        sessionSkills[skill] =
                                                            0.0;
                                                      }
                                                    });

                                                    // Call the new signature
                                                    await userCubit.toggleSkill(
                                                      goalId:
                                                          skill, // treat skill name as the identifier
                                                      done:
                                                          newDone, // add/remove
                                                      // index omitted on purpose
                                                    );
                                                  }
                                                },
                                              ),
                                          ],
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
                        if (sessionSkills.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Please select at least one skill")),
                          );
                          return;
                        }
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
