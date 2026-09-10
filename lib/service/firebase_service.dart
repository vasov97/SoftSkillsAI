import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:softai/model/goal.dart';
import 'package:softai/model/user.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  StreamSubscription<String>? _tokenRefreshSub;

  Future<void> saveTokenForUid(String uid) async {
    final t = await FirebaseMessaging.instance.getToken();
    if (t == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('deviceTokens')
        .doc(t)
        .set({
      'token': t, // <-- your Cloud Function expects this exact key
      'platform': Platform.isAndroid ? 'android' : 'ios',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateGoalSubtasksReset({
    required String uid,
    required String goalId,
    required List<String> subtasks,
    required List<bool> subtasksDone,
  }) async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goalId);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) {
        throw Exception("Goal not found");
      }

      tx.update(docRef, {
        'subtasks': subtasks,
        'subtasksDone': subtasksDone,
        'subtaskNotified': List<bool>.filled(subtasks.length, false),
        'lastSubtaskToggledAt': FieldValue.serverTimestamp(),
      });
    });

    debugPrint(
        '✅ updateGoalSubtasksReset: wrote ${subtasks.length} subtasks to goal $goalId');
  }

  void startTokenRefreshListener(String uid) {
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((t) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('deviceTokens')
          .doc(t)
          .set({
        'token': t,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

// (Optional) call this if you ever want to stop listening on sign-out:
  void stopTokenRefreshListener() {
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
  }

  Future<UserModel?> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = userCredential.user;
    if (firebaseUser != null) {
      UserModel user = UserModel(
        uid: firebaseUser.uid,
        fullName: fullName,
        email: email,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
      return user;
    }
    return null;
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) return null;

      // Check if user document exists in Firestore
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
        // ✅ New user - create document same as regular signup
        UserModel user = UserModel(
          uid: firebaseUser.uid,
          fullName: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(user.toMap());

        // ✅ Save FCM token
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('deviceTokens')
              .doc(fcmToken)
              .set({
            'token': fcmToken,
            'fcmToken': fcmToken,
            'platform': Platform.isAndroid ? 'android' : 'ios',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        return user;
      } else {
        // ✅ Existing user - update last active and FCM token
        await _firestore.collection('users').doc(firebaseUser.uid).update({
          'lastActive': DateTime.now(),
        });

        // Save/update FCM token
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .collection('deviceTokens')
              .doc(fcmToken)
              .set({
            'token': fcmToken,
            'fcmToken': fcmToken,
            'platform': Platform.isAndroid ? 'android' : 'ios',
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        return UserModel.fromMap(userDoc.data()!);
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      throw Exception('Google Sign-In failed: $e');
    }
  }

  Future<void> updateGoalSubtask({
    required String uid,
    required String goalId,
    required int index,
    required bool done,
  }) async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goalId);

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) {
        throw Exception("Goal not found");
      }

      final data = snap.data() as Map<String, dynamic>;

      // Get the skill name from the goal
      final String skillName = data['skill'] as String? ?? '';
      if (skillName.isEmpty) {
        throw Exception("Goal has no skill associated");
      }

      // 1) Use 'subtasks' as the authoritative length
      final List<dynamic> subtasks =
          (data['subtasks'] as List<dynamic>?) ?? const [];
      final int intendedLen = subtasks.length;

      // 2) Normalize 'subtasksDone' -> List<bool> and align lengths
      final List<dynamic> rawDone =
          (data['subtasksDone'] as List<dynamic>?) ?? const [];
      final List<bool> subtasksDone = List<bool>.generate(
        intendedLen,
        (i) => i < rawDone.length
            ? (rawDone[i] is bool
                ? rawDone[i] as bool
                : rawDone[i] is num
                    ? (rawDone[i] as num) != 0
                    : rawDone[i] is String
                        ? (rawDone[i] as String).toLowerCase() == 'true'
                        : false)
            : false,
        growable: false,
      );

      // 3) Normalize 'subtaskNotified' -> List<bool> and align lengths
      final List<dynamic> rawNotified =
          (data['subtaskNotified'] as List<dynamic>?) ?? const [];
      final List<bool> subtaskNotified = List<bool>.generate(
        intendedLen,
        (i) => i < rawNotified.length
            ? (rawNotified[i] is bool ? rawNotified[i] as bool : false)
            : false,
        growable: false,
      );

      // 4) Bounds check (keep UI/model contract strict)
      if (index < 0 || index >= intendedLen) {
        throw Exception('Index $index out of range (len=$intendedLen)');
      }

      // 5) If no change, skip write (avoids redundant CF triggers & churn)
      if (subtasksDone[index] == done) {
        debugPrint('⏭️ Subtask $index already $done, skipping update');
        return;
      }

      // 6) Apply toggle
      subtasksDone[index] = done;

      // 7) CRITICAL: If unchecking, reset the notified flag
      //    This allows re-notification when checked again
      if (!done) {
        subtaskNotified[index] = false;
        debugPrint('🔄 Unchecking subtask $index - reset notified flag');
      }

      // 8) Preserve isActive as-is (don't auto-complete here)
      final bool currentIsActive =
          (data['isActive'] is bool) ? data['isActive'] as bool : true;

      debugPrint(
          '📝 Updating subtask $index: done=$done, notified=${subtaskNotified[index]}');

      // 9) Atomic write to goal document
      tx.set(
        docRef,
        <String, dynamic>{
          'subtasksDone': subtasksDone,
          'subtaskNotified': subtaskNotified,
          'isActive': currentIsActive,
          'lastProgressAt': FieldValue.serverTimestamp(),
          'lastSubtaskToggledAt': FieldValue.serverTimestamp(),
          'lastNotifiedAt': FieldValue.delete(),
          'userId': uid,
        },
        SetOptions(merge: true),
      );

      // 10) ✅ UPDATE SKILL PROGRESS in user document
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final progressDelta =
          done ? 0.004 : -0.004; // 5 subtasks × 0.004 = 0.02 per goal

      tx.set(
        userRef,
        {
          'selectedSkills': {
            skillName: FieldValue.increment(progressDelta),
          },
        },
        SetOptions(merge: true),
      );

      debugPrint('✅ Subtask update transaction complete');
      debugPrint('📊 Updated skill "$skillName" by $progressDelta');

      if (done) {
        debugPrint(
            '⏰ Notification should arrive at: ${DateTime.now().add(const Duration(minutes: 2))}');
      }
    });
  }

  /// Login
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception("Email and password cannot be empty.");
    }

    if (password.length < 6) {
      throw Exception("Password must be at least 6 characters long.");
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception("User not found.");
      }

      // ✅ Save FCM token to subcollection
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('deviceTokens')
            .doc(fcmToken)
            .set({
          'token': fcmToken,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return await getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception("No user found with this email.");
      } else if (e.code == 'wrong-password') {
        throw Exception("Incorrect password.");
      } else if (e.code == 'invalid-email') {
        throw Exception("The email address is invalid.");
      } else {
        throw Exception(e.message ?? "Login failed. Please try again.");
      }
    } catch (e) {
      throw Exception("An error occurred during login: $e");
    }
  }

  /// Forgot Password
  Future<void> forgotPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<UserModel?> getUser() async {
    final user = currentUser;
    if (user == null) {
      print("FirebaseAuth.currentUser is null. User not signed in.");
      return null;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        print("No Firestore document for UID: ${user.uid}");
        return null;
      }
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Update User Progress
  Future<void> updateUserProgress(
    String uid, {
    int? level,
    int? badges,
    int? dailyTipsSeen,
    int? aiInteractionsUsed,
  }) async {
    Map<String, dynamic> data = {
      'lastActive': DateTime.now(),
    };
    if (level != null) data['level'] = level;
    if (badges != null) data['badges'] = badges;
    if (dailyTipsSeen != null) data['dailyTipsSeen'] = dailyTipsSeen;
    if (aiInteractionsUsed != null)
      data['aiInteractionsUsed'] = aiInteractionsUsed;

    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<void> toggleSkill(String skill) async {
    final uid = currentUser?.uid;
    if (uid == null) throw Exception("No user logged in.");

    final docRef = _firestore.collection('users').doc(uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) return;

    final data = snapshot.data() as Map<String, dynamic>;
    final Map<String, dynamic> skills =
        Map<String, dynamic>.from(data['selectedSkills'] ?? {});

    if (skills.containsKey(skill)) {
      // Remove skill
      skills.remove(skill);
    } else {
      // Add skill with initial progress 0.0
      skills[skill] = 0.0;
    }

    await docRef.update({
      'selectedSkills': skills,
      'lastActive': DateTime.now(),
    });
  }

  Future<void> createSoftSkillGoal({
    required String skillName,
    required String title,
    required String description,
  }) async {
    final uid = currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final goalsRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('softSkills')
        .doc(skillName)
        .collection('goals');

    await goalsRef.add({
      'title': title,
      'description': description,
      'status': 'active',
      'createdAt': DateTime.now(),
    });

    // Increment active goals and initialize skill progress if needed
    final userDoc = _firestore.collection('users').doc(uid);
    await userDoc.update({
      'activeGoals': FieldValue.increment(1),
      'softSkillsProgress.$skillName': FieldValue.increment(0),
      'lastActive': DateTime.now(),
    });
  }

  /// Mark a goal as completed
  Future<void> completeSoftSkillGoal({
    required String skillName,
    required String goalId,
  }) async {
    final uid = currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final goalRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('softSkills')
        .doc(skillName)
        .collection('goals')
        .doc(goalId);

    await goalRef.update({
      'status': 'completed',
      'completedAt': DateTime.now(),
    });

    // Update user stats
    final userDoc = _firestore.collection('users').doc(uid);
    await userDoc.update({
      'activeGoals': FieldValue.increment(-1),
      'completedGoals': FieldValue.increment(1),
      'softSkillsProgress.$skillName': FieldValue.increment(10), // Example
      'lastActive': DateTime.now(),
    });
  }

  Future<void> updateSoftSkillProgress({
    required String skillName,
    required double progressDelta,
  }) async {
    final uid = currentUser?.uid;
    if (uid == null) throw Exception("User not logged in.");

    final userDoc = _firestore.collection('users').doc(uid);
    final snapshot = await userDoc.get();

    if (!snapshot.exists) throw Exception("User document not found.");

    // Get current skills map from Firestore
    final data = snapshot.data() as Map<String, dynamic>;
    final Map<String, dynamic> selectedSkills =
        Map<String, dynamic>.from(data['selectedSkills'] ?? {});

    if (!selectedSkills.containsKey(skillName)) {
      throw Exception("Skill $skillName does not exist in selectedSkills.");
    }

    // Increment progress
    final currentValue = (selectedSkills[skillName] as num).toDouble();
    final newValue = currentValue + progressDelta;

    // Update the skill in Firestore
    selectedSkills[skillName] = newValue;

    await userDoc.update({
      'selectedSkills': selectedSkills,
      'lastActive': DateTime.now(),
    });
  }

  Future<void> addGoal(String uid, Goal goal) async {
    final goalsRef =
        _firestore.collection('users').doc(uid).collection('goals');
    await goalsRef.add(goal.toMap());
  }

  Future<void> removeGoal(String uid, String goalId) async {
    final goalRef =
        _firestore.collection('users').doc(uid).collection('goals').doc(goalId);
    await goalRef.delete();
  }

  Future<List<Goal>> getGoals() async {
    final uid = currentUser?.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('goals')
        .get(const GetOptions(source: Source.server));

    return snapshot.docs
        .map((doc) => Goal.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Future<void> completeGoal(Goal goal) async {
  //   final uid = currentUser?.uid;
  //   final goalRef = FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(uid)
  //       .collection('goals')
  //       .doc(goal.id);

  //   // 1. Mark goal as completed
  //   await goalRef.update({'isCompleted': true});

  //   // 2. Add +0.02 to the skill in selectedSkills map
  //   final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
  //   await userRef.set({
  //     'selectedSkills': {
  //       goal.skill: FieldValue.increment(0.02),
  //     },
  //   }, SetOptions(merge: true));
  // }

  Future<void> completeGoal(Goal goal) async {
    final uid = currentUser?.uid;
    final goalRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goal.id);

    // Mark goal as completed and inactive
    await goalRef.update({
      'isCompleted': true,
      'isActive': false,
    });

    // Add +0.15 to the skill in selectedSkills map
    final userRef = _firestore.collection('users').doc(uid);
    await userRef.set({
      'selectedSkills': {
        goal.skill: FieldValue.increment(0.15),
      },
    }, SetOptions(merge: true));
  }

  /// Current User
  User? get currentUser => _auth.currentUser;
}
