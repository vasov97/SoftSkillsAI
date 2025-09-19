import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sr')
  ];

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @createOne.
  ///
  /// In en, this message translates to:
  /// **' Create one '**
  String get createOne;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **' Log in '**
  String get logIn;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @soft.
  ///
  /// In en, this message translates to:
  /// **'Soft'**
  String get soft;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @goalSkill.
  ///
  /// In en, this message translates to:
  /// **'Skill'**
  String get goalSkill;

  /// No description provided for @goalCompleted.
  ///
  /// In en, this message translates to:
  /// **'Goal completed'**
  String get goalCompleted;

  /// No description provided for @goalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Goals'**
  String get goalsTitle;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to SoftSkill.AI'**
  String get onboardingTitle;

  /// No description provided for @onboardingDescription.
  ///
  /// In en, this message translates to:
  /// **'Let’s help you grow your soft skills step-by-step.'**
  String get onboardingDescription;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get createAnAccount;

  /// No description provided for @bubbleMessage.
  ///
  /// In en, this message translates to:
  /// **'Time to learn new skill!'**
  String get bubbleMessage;

  /// No description provided for @pleaseSelectSkill.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one skill'**
  String get pleaseSelectSkill;

  /// No description provided for @continueForward.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueForward;

  /// No description provided for @communication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get communication;

  /// No description provided for @leadership.
  ///
  /// In en, this message translates to:
  /// **'Leadership'**
  String get leadership;

  /// No description provided for @teamwork.
  ///
  /// In en, this message translates to:
  /// **'Teamwork'**
  String get teamwork;

  /// No description provided for @problemSolving.
  ///
  /// In en, this message translates to:
  /// **'Problem-solving'**
  String get problemSolving;

  /// No description provided for @timeManagement.
  ///
  /// In en, this message translates to:
  /// **'Time management'**
  String get timeManagement;

  /// No description provided for @adaptability.
  ///
  /// In en, this message translates to:
  /// **'Adaptability'**
  String get adaptability;

  /// No description provided for @emotionalIntelligence.
  ///
  /// In en, this message translates to:
  /// **'Emotional intelligence'**
  String get emotionalIntelligence;

  /// No description provided for @conflictResolution.
  ///
  /// In en, this message translates to:
  /// **'Conflict resolution'**
  String get conflictResolution;

  /// No description provided for @creativity.
  ///
  /// In en, this message translates to:
  /// **'Creativity'**
  String get creativity;

  /// No description provided for @decisionMaking.
  ///
  /// In en, this message translates to:
  /// **'Decision making'**
  String get decisionMaking;

  /// No description provided for @criticalThinking.
  ///
  /// In en, this message translates to:
  /// **'Critical thinking'**
  String get criticalThinking;

  /// No description provided for @negotiation.
  ///
  /// In en, this message translates to:
  /// **'Negotiation'**
  String get negotiation;

  /// No description provided for @activeListening.
  ///
  /// In en, this message translates to:
  /// **'Active listening'**
  String get activeListening;

  /// No description provided for @workEthic.
  ///
  /// In en, this message translates to:
  /// **'Work ethic'**
  String get workEthic;

  /// No description provided for @interpersonalSkills.
  ///
  /// In en, this message translates to:
  /// **'Interpersonal skills'**
  String get interpersonalSkills;

  /// No description provided for @stressManagement.
  ///
  /// In en, this message translates to:
  /// **'Stress management'**
  String get stressManagement;

  /// No description provided for @networking.
  ///
  /// In en, this message translates to:
  /// **'Networking'**
  String get networking;

  /// No description provided for @coachingMentoring.
  ///
  /// In en, this message translates to:
  /// **'Coaching & mentoring'**
  String get coachingMentoring;

  /// No description provided for @persuasion.
  ///
  /// In en, this message translates to:
  /// **'Persuasion'**
  String get persuasion;

  /// No description provided for @selfMotivation.
  ///
  /// In en, this message translates to:
  /// **'Self-motivation'**
  String get selfMotivation;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @nextSkill.
  ///
  /// In en, this message translates to:
  /// **'Next Skill'**
  String get nextSkill;

  /// No description provided for @loadingTips.
  ///
  /// In en, this message translates to:
  /// **'Loading personalized tips...'**
  String get loadingTips;

  /// No description provided for @errorFetchingTips.
  ///
  /// In en, this message translates to:
  /// **'Error while fetching tips'**
  String get errorFetchingTips;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get saveSuccess;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save lesson'**
  String get saveFailed;

  /// No description provided for @motivationalQuotes.
  ///
  /// In en, this message translates to:
  /// **'motivationalQuotes'**
  String get motivationalQuotes;

  /// No description provided for @noSkillsTracked.
  ///
  /// In en, this message translates to:
  /// **'No skills tracked yet.\nSelect skills to start tracking progress'**
  String get noSkillsTracked;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Build skills that help you grow and succeed'**
  String get tagline;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get\nStarted'**
  String get getStarted;

  /// No description provided for @helloSkillPrompt.
  ///
  /// In en, this message translates to:
  /// **'Hello! Which soft skill\nwould you like to work on?'**
  String get helloSkillPrompt;

  /// No description provided for @dailyTip.
  ///
  /// In en, this message translates to:
  /// **'Daily Tip'**
  String get dailyTip;

  /// No description provided for @techinqueOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Technique of the Day'**
  String get techinqueOfTheDay;

  /// No description provided for @savedLessons.
  ///
  /// In en, this message translates to:
  /// **'Saved lessons'**
  String get savedLessons;

  /// No description provided for @trainNewSkill.
  ///
  /// In en, this message translates to:
  /// **'Train new skill'**
  String get trainNewSkill;

  /// No description provided for @trackProgress.
  ///
  /// In en, this message translates to:
  /// **'Track progress'**
  String get trackProgress;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @needHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help? Ask me!'**
  String get needHelp;

  /// No description provided for @noSavedLessons.
  ///
  /// In en, this message translates to:
  /// **'No saved lessons yet.'**
  String get noSavedLessons;

  /// No description provided for @lesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get lesson;

  /// No description provided for @removed.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get removed;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @continueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueGoogle;

  /// No description provided for @continueApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueApple;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sr':
      return AppLocalizationsSr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
