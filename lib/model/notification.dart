import 'package:cloud_firestore/cloud_firestore.dart';

class Notification {
  final String id; // Firestore doc ID
  final String userId; // Which user this notification belongs to
  final String title; // Short title or subject
  final String message; // Detailed message
  final String? skillName; // Optional: related soft skill

  final bool read; // Has the user opened/acknowledged it

  final DateTime? readAt; // When user viewed/cleared it
  final String? goalId; // Optional: if related to a goal
  final String? action; // Optional: e.g., "open_goals_page"

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.skillName,
    this.read = false,
    this.readAt,
    this.goalId,
    this.action,
  });

  /// Convert Firestore doc to model
  factory Notification.fromMap(Map<String, dynamic> map, String id) {
    return Notification(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      skillName: map['skillName'],
      read: map['read'] ?? false,
      readAt:
          map['readAt'] != null ? (map['readAt'] as Timestamp).toDate() : null,
      goalId: map['goalId'],
      action: map['action'],
    );
  }

  /// Convert model to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'skillName': skillName,
      'read': read,
      'readAt': readAt,
      'goalId': goalId,
      'action': action,
    };
  }

  Notification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? skillName,
    String? type,
    bool? read,
    DateTime? createdAt,
    DateTime? readAt,
    String? goalId,
    String? action,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      skillName: skillName ?? this.skillName,
      read: read ?? this.read,
      readAt: readAt ?? this.readAt,
      goalId: goalId ?? this.goalId,
      action: action ?? this.action,
    );
  }
}
