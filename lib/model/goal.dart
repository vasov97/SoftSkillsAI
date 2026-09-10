import 'package:cloud_firestore/cloud_firestore.dart';

class Goal {
  final String id;
  final String title;
  final String skill;

  /// If you previously used this as "can be toggled", keep it;
  /// else consider renaming to `isCompleted`.
  final bool isActive;
  final DateTime createdAt;

  /// Exactly 5 concise subtasks (strings).
  final List<String> subtasks;

  /// Same length as [subtasks]; true = done.
  final List<bool> subtasksDone;

  // ---------- Optional tracking / reminder fields (all NOT required) ----------
  /// Updated whenever any subtask flips true/false.
  final DateTime? lastProgressAt;

  /// Set when all 5 are done; null otherwise.
  final DateTime? completedAt;

  /// When the scheduler should next consider this goal.
  final DateTime? nextReminderAt;

  /// When we last sent a reminder for this goal.
  final DateTime? lastNotifiedAt;

  /// Escalation stage (0,1,2…).
  final int? reminderLevel;

  /// Per-goal mute window (user-level opt-out can exist separately).
  final DateTime? goalMutedUntil;

  /// Optional per-subtask timestamps, same length as [subtasks].
  final List<DateTime?>? subtaskTouchedAt;

  /// Optional timezone override (otherwise read from user profile).
  final String? tz;

  /// Optional per-goal opt-out (user-wide opt-out likely lives on the user doc).
  final bool? pushOptOutForGoal;

  Goal({
    required this.id,
    required this.title,
    required this.skill,
    required this.isActive,
    required this.createdAt,
    required this.subtasks,
    required this.subtasksDone,
    this.lastProgressAt,
    this.completedAt,
    this.nextReminderAt,
    this.lastNotifiedAt,
    this.reminderLevel, // default logic handled in fromMap/draft
    this.goalMutedUntil,
    this.subtaskTouchedAt, // normalized in fromMap/draft
    this.tz,
    this.pushOptOutForGoal,
  }) : assert(subtasks.length == subtasksDone.length,
            'subtasks and subtasksDone must be same length');

  // -------------------- Derived helpers --------------------
  double get progress {
    if (subtasks.isEmpty) return 0.0;
    final done = subtasksDone.where((e) => e).length;
    return done / subtasks.length;
  }

  bool get allDone => subtasksDone.isNotEmpty && subtasksDone.every((e) => e);

  // -------------------- Factory parsing helpers --------------------
  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    // ignore string parsing to avoid locale issues; add if you store ISO strings
    return null;
  }

  static List<DateTime?> _normalizeTouched(List? raw, int len) {
    final out = <DateTime?>[];
    final src = raw ?? const [];
    for (var i = 0; i < len; i++) {
      final v = i < src.length ? src[i] : null;
      out.add(_toDate(v));
    }
    return out;
  }

  // -------------------- Firestore <-> Model --------------------
  factory Goal.fromMap(String id, Map<String, dynamic> map) {
    // Base fields
    final createdAtTs = map['createdAt'];
    final created = createdAtTs is Timestamp
        ? createdAtTs.toDate()
        : (createdAtTs is DateTime ? createdAtTs : DateTime.now());

    // Subtasks (List<String>)
    final rawSubtasks = (map['subtasks'] as List?) ?? const [];
    final subtasks = rawSubtasks.map((e) => e?.toString() ?? '').toList();

    // Subtasks done (List<bool>)
    final rawDone = (map['subtasksDone'] as List?) ?? const [];
    final subtasksDone = rawDone.map((e) {
      if (e is bool) return e;
      if (e is num) return e != 0;
      if (e is String) return e.toLowerCase() == 'true';
      return false;
    }).toList();

    // Use actual length from Firestore, don't cap
    List<String> normSubtasks = List<String>.from(subtasks);
    List<bool> normDone = List<bool>.from(subtasksDone);

    if (normSubtasks.isEmpty) {
      normSubtasks = List<String>.filled(5, '');
    }

    // Align done array to subtasks length
    while (normDone.length < normSubtasks.length) {
      normDone.add(false);
    }
    if (normDone.length > normSubtasks.length) {
      normDone.removeRange(normSubtasks.length, normDone.length);
    }

    // Optional tracking fields
    final lastProgressAt = _toDate(map['lastProgressAt']);
    final completedAt = _toDate(map['completedAt']);
    final nextReminderAt = _toDate(map['nextReminderAt']);
    final lastReminderAt = _toDate(map['lastReminderAt']);
    final reminderLevel = map['reminderLevel'] is num
        ? (map['reminderLevel'] as num).toInt()
        : null;
    final goalMutedUntil = _toDate(map['goalMutedUntil']);
    final tz = (map['tz'] is String) ? map['tz'] as String : null;
    final pushOptOutForGoal = (map['pushOptOutForGoal'] is bool)
        ? map['pushOptOutForGoal'] as bool
        : null;

    // subtaskTouchedAt normalized to same length as subtasks
    final subtaskTouchedAt = _normalizeTouched(
        map['subtaskTouchedAt'] as List?, normSubtasks.length);

    return Goal(
      id: id,
      title: (map['title'] ?? '').toString(),
      skill: (map['skill'] ?? '').toString(),
      isActive: (map['isActive'] is bool) ? map['isActive'] as bool : true,
      createdAt: created,
      subtasks: normSubtasks,
      subtasksDone: normDone,
      lastProgressAt: lastProgressAt,
      completedAt: completedAt,
      nextReminderAt: nextReminderAt,
      lastNotifiedAt: lastReminderAt,
      reminderLevel: reminderLevel,
      goalMutedUntil: goalMutedUntil,
      subtaskTouchedAt: subtaskTouchedAt,
      tz: tz,
      pushOptOutForGoal: pushOptOutForGoal,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'skill': skill,
      'isActive': isActive,
      'createdAt': createdAt, // Firestore SDK converts
      'subtasks': subtasks,
      'subtasksDone': subtasksDone,
      // Optional fields (only include if not null to keep docs clean)
      'lastProgressAt': lastProgressAt,
      'completedAt': completedAt,
      'nextReminderAt': nextReminderAt,
      'lastReminderAt': lastNotifiedAt,
      'reminderLevel': reminderLevel,
      'goalMutedUntil': goalMutedUntil,
      'subtaskTouchedAt': subtaskTouchedAt,
      'tz': tz,
      'pushOptOutForGoal': pushOptOutForGoal,
    };

    map.removeWhere((_, v) => v == null);
    return map;
  }

  Goal copyWith({
    String? id,
    String? title,
    String? skill,
    bool? isActive,
    DateTime? createdAt,
    List<String>? subtasks,
    List<bool>? subtasksDone,
    DateTime? lastProgressAt,
    DateTime? completedAt,
    DateTime? nextReminderAt,
    DateTime? lastReminderAt,
    int? reminderLevel,
    DateTime? goalMutedUntil,
    List<DateTime?>? subtaskTouchedAt,
    String? tz,
    bool? pushOptOutForGoal,
  }) {
    final newSubtasks = subtasks ?? this.subtasks;
    final newDone = subtasksDone ?? this.subtasksDone;
    assert(newSubtasks.length == newDone.length,
        'subtasks and subtasksDone must be same length');

    // Normalize touched list length if provided
    List<DateTime?>? touched = subtaskTouchedAt ?? this.subtaskTouchedAt;
    if (touched != null && touched.length != newSubtasks.length) {
      final tmp = List<DateTime?>.from(touched.take(newSubtasks.length));
      while (tmp.length < newSubtasks.length) {
        tmp.add(null);
      }
      touched = tmp;
    }

    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      skill: skill ?? this.skill,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      subtasks: newSubtasks,
      subtasksDone: newDone,
      lastProgressAt: lastProgressAt ?? this.lastProgressAt,
      completedAt: completedAt ?? this.completedAt,
      nextReminderAt: nextReminderAt ?? this.nextReminderAt,
      lastNotifiedAt: lastReminderAt ?? lastNotifiedAt,
      reminderLevel: reminderLevel ?? this.reminderLevel,
      goalMutedUntil: goalMutedUntil ?? this.goalMutedUntil,
      subtaskTouchedAt: touched,
      tz: tz ?? this.tz,
      pushOptOutForGoal: pushOptOutForGoal ?? this.pushOptOutForGoal,
    );
  }

  /// Toggle a single subtask; updates lastProgressAt and (optionally) completedAt.
  Goal toggleSubtask(int index, bool value) {
    if (index < 0 || index >= subtasksDone.length) return this;

    final updatedDone = List<bool>.from(subtasksDone);
    updatedDone[index] = value;

    // Update touched timestamps list
    final updatedTouched = List<DateTime?>.from(
        (subtaskTouchedAt ?? List<DateTime?>.filled(subtasks.length, null)));
    if (updatedTouched.length != subtasks.length) {
      // normalize length if needed
      while (updatedTouched.length < subtasks.length) {
        updatedTouched.add(null);
      }
      if (updatedTouched.length > subtasks.length) {
        updatedTouched.removeRange(subtasks.length, updatedTouched.length);
      }
    }
    updatedTouched[index] = DateTime.now();

    final now = DateTime.now();
    final allDoneNow =
        updatedDone.isNotEmpty && updatedDone.every((e) => e == true);

    return copyWith(
      subtasksDone: updatedDone,
      subtaskTouchedAt: updatedTouched,
      lastProgressAt: now,
      completedAt: allDoneNow ? (completedAt ?? now) : null,
    );
  }

  /// Helper for creating a new Goal draft with 5 subtasks.
  factory Goal.draft({
    required String id,
    required String title,
    required String skill,
    required List<String> subtasks, // can be <5; will be padded to 5
    DateTime? createdAt,
  }) {
    const targetLen = 5;
    final trimmed = subtasks.take(targetLen).toList();
    while (trimmed.length < targetLen) {
      trimmed.add('');
    }
    final now = createdAt ?? DateTime.now();
    return Goal(
      id: id,
      title: title,
      skill: skill,
      isActive: true,
      createdAt: now,
      subtasks: trimmed,
      subtasksDone: List<bool>.filled(trimmed.length, false),
      lastProgressAt: now, // start equal to creation time
      completedAt: null,
      nextReminderAt: null,
      lastNotifiedAt: null,
      reminderLevel: 0,
      goalMutedUntil: null,
      subtaskTouchedAt: List<DateTime?>.filled(trimmed.length, null),
      tz: null,
      pushOptOutForGoal: null,
    );
  }
}
