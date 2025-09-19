import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:softai/model/goal.dart';
import 'package:softai/model/user.dart';
import 'package:softai/service/firebase_service.dart';
import 'package:softai/service/lessons_service.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final FirebaseService firebaseService;
  final LessonService lessonService;

  UserCubit(this.firebaseService, this.lessonService) : super(UserInitial());

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

  // Future<void> toggleSkill(String skill) async {
  //   if (state is! UserLoaded) return;

  //   final currentUser = (state as UserLoaded).user;
  //   final skillsMap = Map<String, double>.from(currentUser.selectedSkills);

  //   try {
  //     await firebaseService.toggleSkill(skill);

  //     if (skillsMap.containsKey(skill)) {
  //       // Remove skill
  //       skillsMap.remove(skill);
  //     } else {
  //       // Add skill with initial progress 0
  //       skillsMap[skill] = 0;
  //     }
  //     emit(UserLoaded(currentUser.copyWith(selectedSkills: skillsMap)));
  //   } catch (e) {
  //     emit(UserError("Error updating skills: $e"));
  //   }
  // }

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
    required String goalId,
    int? index,
    bool? done,
  }) async {
    if (state is! UserLoaded) return;

    try {
      final uid = firebaseService.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in.");

      await firebaseService.updateGoalSubtask(
        uid: uid,
        goalId: goalId,
        index: index!,
        done: done!,
      );

      // Refresh user data so UI updates
      await loadUser();
    } catch (e) {
      emit(UserError("Failed to toggle subtask: $e"));
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

  Future<void> completeGoal(Goal goal) async {
    await firebaseService.completeGoal(goal);
    await loadUser(); // refresh local state
  }
}
