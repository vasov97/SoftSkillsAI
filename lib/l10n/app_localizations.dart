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

  /// No description provided for @goalAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'Goal \"{goalTitle}\" added under \"{skill}\"'**
  String goalAddedMessage(String goalTitle, String skill);

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'Build skills that help you grow and succeed!'**
  String get subtitle;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get hello;

  /// No description provided for @pleaseLoginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Login to continue your progress.'**
  String get pleaseLoginToContinue;

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

  /// No description provided for @addNewGoal.
  ///
  /// In en, this message translates to:
  /// **'Add New Goal'**
  String get addNewGoal;

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

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save lesson'**
  String get save;

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
  /// **'Your soft skills AI coach'**
  String get tagline;

  /// No description provided for @subtitleStart.
  ///
  /// In en, this message translates to:
  /// **'Chat. Practice. Grow.'**
  String get subtitleStart;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get\nStarted'**
  String get getStarted;

  /// No description provided for @onboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose skill or ask your question.'**
  String get onboardSubtitle;

  /// No description provided for @helloSkillPrompt.
  ///
  /// In en, this message translates to:
  /// **'Which soft skill\nwould you like to work on?'**
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

  /// No description provided for @buttonStart.
  ///
  /// In en, this message translates to:
  /// **'Start chatting'**
  String get buttonStart;

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

  /// No description provided for @timeToLearnNewSkill.
  ///
  /// In en, this message translates to:
  /// **'Time to learn new skill!'**
  String get timeToLearnNewSkill;

  /// No description provided for @readyForProgress.
  ///
  /// In en, this message translates to:
  /// **'Ready for progress today?'**
  String get readyForProgress;

  /// No description provided for @chatWithSkillena.
  ///
  /// In en, this message translates to:
  /// **'Chat with\nSkillena AI'**
  String get chatWithSkillena;

  /// No description provided for @askAndGetAdvice.
  ///
  /// In en, this message translates to:
  /// **'Ask a question and get personalized advice.'**
  String get askAndGetAdvice;

  /// No description provided for @startChat.
  ///
  /// In en, this message translates to:
  /// **'Start chatting'**
  String get startChat;

  /// No description provided for @continueLastChat.
  ///
  /// In en, this message translates to:
  /// **'Continue last conversation'**
  String get continueLastChat;

  /// No description provided for @lastChatPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'No previous conversation yet.'**
  String get lastChatPlaceholder;

  /// No description provided for @askAboutSoftSkills.
  ///
  /// In en, this message translates to:
  /// **'Ask about soft skills'**
  String get askAboutSoftSkills;

  /// No description provided for @saveAnswer.
  ///
  /// In en, this message translates to:
  /// **'Save answer'**
  String get saveAnswer;

  /// No description provided for @createGoal.
  ///
  /// In en, this message translates to:
  /// **'Create goal'**
  String get createGoal;

  /// No description provided for @practiceWithMe.
  ///
  /// In en, this message translates to:
  /// **'Practice with me'**
  String get practiceWithMe;

  /// No description provided for @continueChat.
  ///
  /// In en, this message translates to:
  /// **'Continue conversation'**
  String get continueChat;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @saveThisConversation.
  ///
  /// In en, this message translates to:
  /// **'Save this conversation'**
  String get saveThisConversation;

  /// No description provided for @addTitle.
  ///
  /// In en, this message translates to:
  /// **'Add title'**
  String get addTitle;

  /// No description provided for @addTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Conversation title...'**
  String get addTitleHint;

  /// No description provided for @summaryAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Summary (automatic)'**
  String get summaryAutomatic;

  /// No description provided for @addTo.
  ///
  /// In en, this message translates to:
  /// **'Add to'**
  String get addTo;

  /// No description provided for @myLibrary.
  ///
  /// In en, this message translates to:
  /// **'My library'**
  String get myLibrary;

  /// No description provided for @myGoals.
  ///
  /// In en, this message translates to:
  /// **'My goals'**
  String get myGoals;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @createNewGoal.
  ///
  /// In en, this message translates to:
  /// **'Create new goal'**
  String get createNewGoal;

  /// No description provided for @createGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a goal and AI will create steps for you.'**
  String get createGoalSubtitle;

  /// No description provided for @goalTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal title'**
  String get goalTitle;

  /// No description provided for @selectSkill.
  ///
  /// In en, this message translates to:
  /// **'Select related skill'**
  String get selectSkill;

  /// No description provided for @aiWillGenerateSubtasks.
  ///
  /// In en, this message translates to:
  /// **'AI will automatically generate 5 actionable subtasks for your goal.'**
  String get aiWillGenerateSubtasks;

  /// No description provided for @pleaseFillGoalFields.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title and select a skill.'**
  String get pleaseFillGoalFields;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @addGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Add goal title'**
  String get addGoalTitle;

  /// No description provided for @practiceWithSkillena.
  ///
  /// In en, this message translates to:
  /// **'Practice with Skillena AI'**
  String get practiceWithSkillena;

  /// No description provided for @chooseScenario.
  ///
  /// In en, this message translates to:
  /// **'Choose a situation you want to practice.'**
  String get chooseScenario;

  /// No description provided for @scenarioDifficultConversation.
  ///
  /// In en, this message translates to:
  /// **'Difficult conversation with a colleague'**
  String get scenarioDifficultConversation;

  /// No description provided for @scenarioPresentation.
  ///
  /// In en, this message translates to:
  /// **'Presentation in front of a team'**
  String get scenarioPresentation;

  /// No description provided for @scenarioFeedback.
  ///
  /// In en, this message translates to:
  /// **'Giving feedback'**
  String get scenarioFeedback;

  /// No description provided for @scenarioClientMeeting.
  ///
  /// In en, this message translates to:
  /// **'Meeting with a client'**
  String get scenarioClientMeeting;

  /// No description provided for @scenarioNegotiation.
  ///
  /// In en, this message translates to:
  /// **'Negotiation'**
  String get scenarioNegotiation;

  /// No description provided for @scenarioOther.
  ///
  /// In en, this message translates to:
  /// **'Other situation'**
  String get scenarioOther;

  /// No description provided for @describeYourSituation.
  ///
  /// In en, this message translates to:
  /// **'Describe your situation'**
  String get describeYourSituation;

  /// No description provided for @describeScenarioHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Asking for a raise from my manager...'**
  String get describeScenarioHint;

  /// No description provided for @startPractice.
  ///
  /// In en, this message translates to:
  /// **'Start practice'**
  String get startPractice;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your progress'**
  String get yourProgress;

  /// No description provided for @totalProgress.
  ///
  /// In en, this message translates to:
  /// **'Total progress'**
  String get totalProgress;

  /// No description provided for @conversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversations;

  /// No description provided for @completedExercises.
  ///
  /// In en, this message translates to:
  /// **'Completed exercises'**
  String get completedExercises;

  /// No description provided for @daysInARow.
  ///
  /// In en, this message translates to:
  /// **'Days in a row'**
  String get daysInARow;

  /// No description provided for @activeGoals.
  ///
  /// In en, this message translates to:
  /// **'Active goals'**
  String get activeGoals;

  /// No description provided for @progressBySkills.
  ///
  /// In en, this message translates to:
  /// **'Progress by skills'**
  String get progressBySkills;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'steps'**
  String get steps;

  /// No description provided for @noGoalsYet.
  ///
  /// In en, this message translates to:
  /// **'No goals yet.\nCreate your first goal to get started!'**
  String get noGoalsYet;

  /// No description provided for @noSubtasksYet.
  ///
  /// In en, this message translates to:
  /// **'No subtasks yet.'**
  String get noSubtasksYet;

  /// No description provided for @tabConversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get tabConversations;

  /// No description provided for @tabLessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get tabLessons;

  /// No description provided for @tabTechniques.
  ///
  /// In en, this message translates to:
  /// **'Techniques'**
  String get tabTechniques;

  /// No description provided for @tagConversation.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get tagConversation;

  /// No description provided for @tagLesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get tagLesson;

  /// No description provided for @tagTechnique.
  ///
  /// In en, this message translates to:
  /// **'Technique'**
  String get tagTechnique;

  /// No description provided for @noConversationsSaved.
  ///
  /// In en, this message translates to:
  /// **'No conversations saved yet.'**
  String get noConversationsSaved;

  /// No description provided for @noTechniquesSaved.
  ///
  /// In en, this message translates to:
  /// **'No techniques saved yet.'**
  String get noTechniquesSaved;

  /// No description provided for @removeLesson.
  ///
  /// In en, this message translates to:
  /// **'Remove from library'**
  String get removeLesson;

  /// No description provided for @dailyAdvice.
  ///
  /// In en, this message translates to:
  /// **'Daily advice'**
  String get dailyAdvice;

  /// No description provided for @applyToday.
  ///
  /// In en, this message translates to:
  /// **'Apply today'**
  String get applyToday;

  /// No description provided for @applied.
  ///
  /// In en, this message translates to:
  /// **'Applied!'**
  String get applied;

  /// No description provided for @adviceHistory.
  ///
  /// In en, this message translates to:
  /// **'Advice history'**
  String get adviceHistory;

  /// No description provided for @noAdviceHistory.
  ///
  /// In en, this message translates to:
  /// **'No previous advice yet.'**
  String get noAdviceHistory;

  /// No description provided for @techniqueOfDay.
  ///
  /// In en, this message translates to:
  /// **'Technique of the day'**
  String get techniqueOfDay;

  /// No description provided for @practiceWithAI.
  ///
  /// In en, this message translates to:
  /// **'Practice with AI'**
  String get practiceWithAI;

  /// No description provided for @techniqueSteps.
  ///
  /// In en, this message translates to:
  /// **'Technique steps'**
  String get techniqueSteps;

  /// No description provided for @pleaseAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Please add a title'**
  String get pleaseAddTitle;

  /// No description provided for @conversationSaved.
  ///
  /// In en, this message translates to:
  /// **'Conversation saved successfully!'**
  String get conversationSaved;

  /// No description provided for @saveTechnique.
  ///
  /// In en, this message translates to:
  /// **'Save technique'**
  String get saveTechnique;

  /// No description provided for @techniqueSaved.
  ///
  /// In en, this message translates to:
  /// **'Technique saved!'**
  String get techniqueSaved;

  /// No description provided for @pleaseSelectOption.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one option'**
  String get pleaseSelectOption;

  /// No description provided for @fiveMoreTips.
  ///
  /// In en, this message translates to:
  /// **'5 more tips'**
  String get fiveMoreTips;

  /// No description provided for @teachMeMore.
  ///
  /// In en, this message translates to:
  /// **'Teach me more'**
  String get teachMeMore;
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
