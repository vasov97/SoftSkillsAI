import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:softai/model/goal.dart';
import 'package:softai/model/user.dart';
import 'package:softai/service/firebase_service.dart';
import 'package:softai/service/lessons_service.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final FirebaseService firebaseService;
  final LessonService lessonService;

  UserCubit(this.firebaseService, this.lessonService) : super(UserInitial());
  String? _pendingQuizGoalId;
  bool? _lastQuizPassed;

  String? get pendingQuizGoalId => _pendingQuizGoalId;
  bool? get lastQuizPassed => _lastQuizPassed;

  void setPendingQuiz(String goalId) {
    _pendingQuizGoalId = goalId;
    _lastQuizPassed = null;
  }

  void setQuizResult(bool passed) {
    _lastQuizPassed = passed;
  }

  void clearQuizResult() {
    _pendingQuizGoalId = null;
    _lastQuizPassed = null;
  }

  Future<void> loadUser() async {
    emit(UserLoading());
    try {
      final user = await firebaseService.getUser();
      if (user != null) {
        emit(UserLoaded(user));
      } else {
        emit(UserError("User not found"));
      }
    } catch (e) {
      emit(UserError("Error loading user: $e"));
    }
  }

  Future<void> saveLessonForSkill(String skill, List<String> tips) async {
    try {
      await lessonService.saveLesson(skill, tips);
    } catch (e) {
      emit(UserError("Error saving lesson: $e"));
    }
  }

  Future<Map<String, List<String>>> getSavedLessons() async {
    try {
      return await lessonService.loadLessons();
    } catch (e) {
      emit(UserError("Error loading saved lessons: $e"));
      return {};
    }
  }

  Future<void> removeLessonForSkill(String skill) async {
    try {
      await lessonService.removeLesson(skill);
    } catch (e) {
      emit(UserError("Error removing lesson: $e"));
    }
  }

  Future<void> completeGoalById(String goalId) async {
    try {
      final goals = await firebaseService.getGoals();
      final goal = goals.firstWhere((g) => g.id == goalId);
      await firebaseService.completeGoal(goal);
      await loadUser();
    } catch (e) {
      debugPrint('Failed to complete goal: $e');
    }
  }

  Future<void> updateSoftSkillProgress({
    required String skillName,
    required double progressDelta,
  }) async {
    try {
      final uid = firebaseService.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in.");

      // Update Firestore map field
      await firebaseService.updateSoftSkillProgress(
        skillName: skillName,
        progressDelta: progressDelta,
      );

      // Optionally refresh user locally
      await loadUser();
    } catch (e) {
      emit(UserError("Failed to update skill progress: $e"));
    }
  }

  Future<void> toggleSkill({
    required String skillName,
  }) async {
    if (state is! UserLoaded) return;

    try {
      // ✅ Call the correct FirebaseService method for skills
      await firebaseService.toggleSkill(skillName);

      // Refresh user data so UI updates
      await loadUser();
    } catch (e) {
      emit(UserError("Failed to toggle skill: $e"));
    }
  }

  Future<void> addGoal(
      String title, String skill, List<String> subtasks) async {
    try {
      final uid = firebaseService.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in.");

      final newGoal = Goal(
        id: "", // Firestore will auto-generate it
        title: title,
        skill: skill,
        isActive: true,
        createdAt: DateTime.now(),
        subtasks: subtasks, // 👈 pass subtasks here
        subtasksDone:
            List<bool>.filled(subtasks.length, false), // 👈 init done flags
      );

      await firebaseService.addGoal(uid, newGoal);
      await loadUser();
    } catch (e) {
      emit(UserError("Failed to add goal: $e"));
    }
  }

  Future<void> removeGoal(String goalId) async {
    try {
      final uid = firebaseService.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in.");

      await firebaseService.removeGoal(uid, goalId);
      await loadUser();
    } catch (e) {
      emit(UserError("Failed to remove goal: $e"));
    }
  }

  Future<List<Goal>> getGoals() async {
    return await firebaseService.getGoals();
  }

  Future<void> addSubtasksToGoal(String goalId, List<String> currentSubtasks,
      List<String> newSubtasks) async {
    try {
      final uid = firebaseService.currentUser?.uid;
      if (uid == null) return;

      final allSubtasks = [...currentSubtasks, ...newSubtasks];
      final allDone = List<bool>.filled(allSubtasks.length, false);

      await firebaseService.updateGoalSubtasksReset(
        uid: uid,
        goalId: goalId,
        subtasks: allSubtasks,
        subtasksDone: allDone,
      );
      await loadUser();
    } catch (e) {
      debugPrint('Failed to add subtasks: $e');
    }
  }
}
