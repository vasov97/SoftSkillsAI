import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:softai/model/goal.dart';
import 'package:softai/model/user.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign Up
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

    final snap = await docRef.get();
    if (!snap.exists) {
      throw Exception("Goal not found");
    }

    final data = snap.data() as Map<String, dynamic>;

    // Load current subtasksDone; ensure it has length 5 (or at least index+1)
    final List<bool> subtasksDone = List<bool>.from(
      (data['subtasksDone'] as List?)?.map((e) {
            if (e is bool) return e;
            if (e is num) return e != 0;
            if (e is String) return e.toLowerCase() == 'true';
            return false;
          }) ??
          const [],
    );

    // Normalize length to at least 5 (or index+1)
    final targetLen = (index + 1) < 5 ? 5 : (index + 1);
    while (subtasksDone.length < targetLen) {
      subtasksDone.add(false);
    }

    // Set the new value
    subtasksDone[index] = done;

    // Optional: if you want to auto-complete a goal when all subtasks are done,
    // compute isActive = !allDone (or however you use isActive).
    final allDone = subtasksDone.isNotEmpty && subtasksDone.every((v) => v);
    final bool newIsActive =
        data['isActive'] is bool ? data['isActive'] as bool : true;
    // Example policy: when all 5 checked, set isActive=false
    final bool isActiveFinal = allDone ? false : newIsActive;

    await docRef.update({
      'subtasksDone': subtasksDone,
      'isActive':
          isActiveFinal, // remove this line if you don't want auto-complete
    });
  }

  /// Login
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    // Input checks
    if (email.isEmpty || password.isEmpty) {
      throw Exception("Email and password cannot be empty.");
    }

    if (password.length < 6) {
      throw Exception("Password must be at least 6 characters long.");
    }

    // Firebase login
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception("User not found.");
      }

      return await getUser();
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuth specific errors
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

  /// Get User
  // Future<UserModel?> getUser() async {
  //   DocumentSnapshot doc =
  //       await _firestore.collection('users').doc(currentUser!.uid).get();
  //   if (doc.exists) {
  //     return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  //   }
  //   return null;
  // }
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

  /// Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
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

  /// =========================
  /// SOFT SKILL GOALS METHODS
  /// =========================

  /// Create a goal for a soft skill
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
        .get();

    return snapshot.docs
        .map((doc) => Goal.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> completeGoal(Goal goal) async {
    final uid = currentUser?.uid;
    final goalRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goal.id);

    // 1. Mark goal as completed
    await goalRef.update({'isCompleted': true});

    // 2. Add +0.02 to the skill in selectedSkills map
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    await userRef.set({
      'selectedSkills': {
        goal.skill: FieldValue.increment(0.02),
      },
    }, SetOptions(merge: true));
  }

  /// Current User
  User? get currentUser => _auth.currentUser;
}
