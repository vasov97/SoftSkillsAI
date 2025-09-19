import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;

  final bool isPremium;
  final Map<String, double> selectedSkills; // Map<String, double>

  final int dailyTipsSeen;
  final int aiInteractionsUsed;
  final int level;
  final int badges;
  final DateTime lastActive;
  final DateTime createdAt;

  final int activeGoals;
  final int completedGoals;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.isPremium = false,
    this.selectedSkills = const {},
    this.dailyTipsSeen = 0,
    this.aiInteractionsUsed = 0,
    this.level = 1,
    this.badges = 0,
    required this.lastActive,
    required this.createdAt,
    this.activeGoals = 0,
    this.completedGoals = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    Map<String, double> parseDoubleMap(dynamic rawMap) {
      if (rawMap == null) return {};
      final castMap = Map<String, dynamic>.from(rawMap as Map);
      return castMap.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
    }

    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      isPremium: map['isPremium'] ?? false,
      selectedSkills: parseDoubleMap(map['selectedSkills']),
      dailyTipsSeen: map['dailyTipsSeen'] ?? 0,
      aiInteractionsUsed: map['aiInteractionsUsed'] ?? 0,
      level: map['level'] ?? 1,
      badges: map['badges'] ?? 0,
      lastActive: (map['lastActive'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      activeGoals: map['activeGoals'] ?? 0,
      completedGoals: map['completedGoals'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'isPremium': isPremium,
      // ✅ ensure Firestore always stores double values
      'selectedSkills': selectedSkills.map((k, v) => MapEntry(k, v.toDouble())),
      'dailyTipsSeen': dailyTipsSeen,
      'aiInteractionsUsed': aiInteractionsUsed,
      'level': level,
      'badges': badges,
      'lastActive': lastActive,
      'createdAt': createdAt,
      'activeGoals': activeGoals,
      'completedGoals': completedGoals,
    };
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    bool? isPremium,
    Map<String, double>? selectedSkills,
    int? dailyTipsSeen,
    int? aiInteractionsUsed,
    int? level,
    int? badges,
    DateTime? lastActive,
    DateTime? createdAt,
    int? activeGoals,
    int? completedGoals,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      isPremium: isPremium ?? this.isPremium,
      selectedSkills: selectedSkills ?? this.selectedSkills,
      dailyTipsSeen: dailyTipsSeen ?? this.dailyTipsSeen,
      aiInteractionsUsed: aiInteractionsUsed ?? this.aiInteractionsUsed,
      level: level ?? this.level,
      badges: badges ?? this.badges,
      lastActive: lastActive ?? this.lastActive,
      createdAt: createdAt ?? this.createdAt,
      activeGoals: activeGoals ?? this.activeGoals,
      completedGoals: completedGoals ?? this.completedGoals,
    );
  }
}
