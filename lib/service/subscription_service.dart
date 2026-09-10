import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService extends ChangeNotifier {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  bool _isPro = false;
  bool _isInitialized = false;

  static const String _entitlementId = 'pro';
  static const String _messagesCountKey = 'daily_messages_count';
  static const String _messagesDateKey = 'daily_messages_date';

  static const int freeMessagesPerDay = 3;
  static const int freeSkillsLimit = 2;
  static const int freeGoalsPerSkill = 1;

  bool get isPro => _isPro;
  bool get isFree => !_isPro;
  bool get isInitialized => _isInitialized;

  // ─── Initialize on app start ───

  Future<void> initialize() async {
    try {
      await refreshStatus();

      // Listen to changes
      Purchases.addCustomerInfoUpdateListener((info) {
        final wasPro = _isPro;
        _isPro = info.entitlements.active.containsKey(_entitlementId);
        if (wasPro != _isPro) {
          notifyListeners();
        }
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('SubscriptionService init failed: $e');
      _isInitialized = true;
    }
  }

  Future<void> refreshStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _isPro = customerInfo.entitlements.active.containsKey(_entitlementId);
      notifyListeners();
    } catch (e) {
      debugPrint('refreshStatus failed: $e');
    }
  }

  // ─── Message count limit ───

  Future<int> getTodayMessagesUsed() async {
    if (_isPro) return 0;
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final storedDate = prefs.getString(_messagesDateKey);

    if (storedDate != today) {
      await prefs.setString(_messagesDateKey, today);
      await prefs.setInt(_messagesCountKey, 0);
      return 0;
    }

    return prefs.getInt(_messagesCountKey) ?? 0;
  }

  Future<int> getRemainingMessages() async {
    if (_isPro) return 999;
    final used = await getTodayMessagesUsed();
    final remaining = freeMessagesPerDay - used;
    return remaining < 0 ? 0 : remaining;
  }

  Future<bool> canSendMessage() async {
    if (_isPro) return true;
    final remaining = await getRemainingMessages();
    return remaining > 0;
  }

  Future<void> incrementMessagesUsed() async {
    if (_isPro) return;
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    final storedDate = prefs.getString(_messagesDateKey);

    if (storedDate != today) {
      await prefs.setString(_messagesDateKey, today);
      await prefs.setInt(_messagesCountKey, 1);
    } else {
      final current = prefs.getInt(_messagesCountKey) ?? 0;
      await prefs.setInt(_messagesCountKey, current + 1);
    }
  }

  // ─── Skill limit ───

  bool canSelectMoreSkills(int currentCount) {
    if (_isPro) return true;
    return currentCount < freeSkillsLimit;
  }

  bool isSkillLocked(int skillIndex, int totalSelectedByUser) {
    if (_isPro) return false;
    return skillIndex >= freeSkillsLimit;
  }

  // ─── Goal limit ───

  bool canCreateGoalForSkill(int currentGoalsForThisSkill) {
    if (_isPro) return true;
    return currentGoalsForThisSkill < freeGoalsPerSkill;
  }

  // ─── Feature checks ───

  bool get canUsePractice => _isPro;
  bool get canUseVoiceInput => _isPro;
  bool get canUseVoiceOutput => _isPro;
  bool get canTakeQuiz => _isPro;
  bool get canSaveAnswer => _isPro;
  bool get canCreateGoalFromChat => true;

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
