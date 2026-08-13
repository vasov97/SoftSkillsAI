// goal_progress_writer.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class GoalProgressWriter {
  static final _db = FirebaseFirestore.instance;

  /// Bump goal progress timestamp
  /// Used when completing/toggling entire goals
  static Future<void> bumpGoalProgress(String goalId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      debugPrint('⚠️ Cannot bump goal progress: No user logged in');
      return;
    }

    final goalRef =
        _db.collection('users').doc(uid).collection('goals').doc(goalId);

    await goalRef.set({
      'userId': uid,
      'lastProgressAt': FieldValue.serverTimestamp(),
      'lastNotifiedAt': FieldValue.delete(), // Clear to allow new notifications
    }, SetOptions(merge: true));

    debugPrint('✅ Bumped progress for goal: $goalId');
  }

  /// Update a subtask's done state
  /// This triggers the Cloud Function that schedules the notification
  static Future<void> updateSubtask({
    required String goalId,
    required int index,
    required bool done,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      debugPrint('⚠️ Cannot update subtask: No user logged in');
      return;
    }

    debugPrint('📝 Updating subtask: goalId=$goalId, index=$index, done=$done');

    final goalRef =
        _db.collection('users').doc(uid).collection('goals').doc(goalId);

    // Get current goal data
    final doc = await goalRef.get();
    if (!doc.exists) {
      debugPrint('❌ Goal not found: $goalId');
      throw Exception('Goal not found: $goalId');
    }

    final data = doc.data()!;

    // Get current subtasksDone array
    List<bool> subtasksDone = [];
    if (data['subtasksDone'] != null) {
      subtasksDone = List<bool>.from(data['subtasksDone']);
    }

    // Extend array if needed
    while (subtasksDone.length <= index) {
      subtasksDone.add(false);
    }

    // Update the specific index
    subtasksDone[index] = done;

    // Write to Firestore - THIS TRIGGERS THE CLOUD FUNCTION!
    await goalRef.update({
      'subtasksDone': subtasksDone,
      'userId': uid, // Ensure userId is set for Cloud Function
      'lastProgressAt': FieldValue.serverTimestamp(),
      'isActive': true, // Ensure goal is active
    });

    debugPrint('✅ Subtask updated successfully');
    debugPrint('   This should trigger Cloud Function onGoalUpdated');
    debugPrint('   Array length: ${subtasksDone.length}');
    debugPrint('   Value at index $index: ${subtasksDone[index]}');
  }

  /// Alternative: Direct field path update (only if array already exists)
  /// Not recommended - use updateSubtask() instead
  static Future<void> updateSubtaskDirect({
    required String goalId,
    required int index,
    required bool done,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final goalRef =
        _db.collection('users').doc(uid).collection('goals').doc(goalId);

    // This requires the array to already exist at the right length
    await goalRef.update({
      'subtasksDone.$index': done,
      'userId': uid,
      'lastProgressAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });
  }
}
