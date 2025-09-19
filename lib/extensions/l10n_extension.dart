import 'package:flutter/widgets.dart';
import 'package:softai/l10n/app_localizations.dart';

extension L10nExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  bool get isSerbian => Localizations.localeOf(this).languageCode == 'sr';
  bool get isEnglish => Localizations.localeOf(this).languageCode == 'en';

  String getSkillTranslation(String skill, AppLocalizations l10n) {
    switch (skill) {
      case 'Communication':
        return l10n.communication;
      case 'Leadership':
        return l10n.leadership;
      case 'Teamwork':
        return l10n.teamwork;
      case 'Problem-Solving':
        return l10n.problemSolving;
      case 'Time Management':
        return l10n.timeManagement;
      case 'Adaptability':
        return l10n.adaptability;
      case 'Emotional Intelligence':
        return l10n.emotionalIntelligence;
      case 'Conflict Resolution':
        return l10n.conflictResolution;
      case 'Creativity':
        return l10n.creativity;
      case 'Decision Making':
        return l10n.decisionMaking;
      case 'Critical Thinking':
        return l10n.criticalThinking;
      case 'Negotiation':
        return l10n.negotiation;
      case 'Active Listening':
        return l10n.activeListening;
      case 'Work Ethic':
        return l10n.workEthic;
      case 'Interpersonal Skills':
        return l10n.interpersonalSkills;
      case 'Stress Management':
        return l10n.stressManagement;
      case 'Networking':
        return l10n.networking;
      case 'Coaching & Mentoring':
        return l10n.coachingMentoring;
      case 'Persuasion':
        return l10n.persuasion;
      case 'Self-Motivation':
        return l10n.selfMotivation;
      default:
        return skill;
    }
  }
}
