import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:softai/cubit/user_cubit.dart';
import 'package:softai/di/di.dart';

class TrackProgressScreen extends StatefulWidget {
  const TrackProgressScreen({super.key});

  @override
  State<TrackProgressScreen> createState() => _TrackProgressScreenState();
}

class _TrackProgressScreenState extends State<TrackProgressScreen> {
  late final userCubit;

  List<String> assetNames = [
    'communication.png',
    'leadership.png',
    'problem_solving.png',
    'teamwork.png',
    'time_management.png',
    'emotion.png',
    'leadership.png',
    'problem_solving.png',
    'teamwork.png',
    'time_management.png',
    'communication.png',
    'leadership.png',
    'problem_solving.png',
    'teamwork.png',
    'time_management.png',
    'communication.png',
    'leadership.png',
    'problem_solving.png',
    'teamwork.png',
    'time_management.png',
  ];

  @override
  void initState() {
    super.initState();
    userCubit = locator<UserCubit>();
    userCubit.loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          "Track Progress",
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF007BFF),
        centerTitle: true,
      ),
      body: Stack(
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

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BlocBuilder<UserCubit, UserState>(
                bloc: userCubit,
                builder: (context, state) {
                  if (state is UserLoading || state is UserInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  }

                  if (state is UserError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  if (state is UserLoaded) {
                    final user = state.user;
                    final selectedSkills = user.selectedSkills;

                    if (selectedSkills.isEmpty) {
                      return const Center(
                        child: Text(
                          "No skills tracked yet.\nSelect skills to start tracking progress.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontSize: 18,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: selectedSkills.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final entry = selectedSkills.entries.elementAt(index);
                        final skillName = entry.key;
                        final progressFraction = entry.value; // e.g. 0.02
                        final progressPercent = (progressFraction * 100)
                            .clamp(0.0, 100.0); // Convert to % safely

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                skillName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Progress bar and image in a Row
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: progressFraction.clamp(
                                            0.0, 1.0), // 0.0 - 1.0 for bar
                                        minHeight: 14,
                                        backgroundColor:
                                            Colors.blue.withOpacity(0.2),
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                      width:
                                          8), // Space between progress bar and image
                                  Image.asset(
                                    'assets/${assetNames[index]}',
                                    height: 40,
                                    width: 40,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${progressPercent.toStringAsFixed(1)}%",
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
