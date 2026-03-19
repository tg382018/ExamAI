import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_tr.dart';

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
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('tr')
  ];

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Push Your Limits with AI'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'ExamAI analyzes your learning style and creates a personalized study plan. Pinpoint your weaknesses.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Design Your Future Today'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Thousands of questions, instant analysis, and peer comparisons. The shortest path to success is now in your pocket.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Sign Up for Free'**
  String get onboardingStart;

  /// No description provided for @onboardingLoginLink.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log In'**
  String get onboardingLoginLink;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your exams instantly with AI.'**
  String get loginTitle;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginButton;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get loginNoAccount;

  /// No description provided for @loginErrorEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email and password.'**
  String get loginErrorEmpty;

  /// No description provided for @loginErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get loginErrorInvalid;

  /// No description provided for @loginErrorUnverified.
  ///
  /// In en, this message translates to:
  /// **'Email not verified'**
  String get loginErrorUnverified;

  /// No description provided for @loginVerifyAction.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get loginVerifyAction;

  /// No description provided for @loginGenericError.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get loginGenericError;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start discovering your potential with ExamAI.'**
  String get registerSubtitle;

  /// No description provided for @registerName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get registerName;

  /// No description provided for @registerEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get registerEmail;

  /// No description provided for @registerPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPassword;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerConfirmPassword;

  /// No description provided for @registerTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the '**
  String get registerTermsPrefix;

  /// No description provided for @registerTermsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get registerTermsLink;

  /// No description provided for @registerAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get registerAnd;

  /// No description provided for @registerPrivacyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get registerPrivacyLink;

  /// No description provided for @registerTermsSuffix.
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get registerTermsSuffix;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsTitle;

  /// No description provided for @termsContent.
  ///
  /// In en, this message translates to:
  /// **'Welcome to ExamAI! By using our platform, you agree to these terms.\n\n1. Acceptance of Terms: By accessing or using ExamAI, you agree to be bound by these terms.\n2. User Accounts: You are responsible for maintaining the confidentiality of your account information.\n3. Content Accuracy: AI-generated content is for educational purposes. Users should verify critical information.\n4. Prohibited Conduct: You agree not to misuse the platform or engage in any illegal activities.\n5. Modifications: We reserve the right to update these terms at any time.'**
  String get termsContent;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyTitle;

  /// No description provided for @privacyContent.
  ///
  /// In en, this message translates to:
  /// **'At ExamAI, we take your privacy seriously.\n\n1. Information Collection: We collect your name and email to provide and improve our services.\n2. Data Usage: Your data is used for authentication and personalizing your exam experience.\n3. Data Security: We implement advanced security measures to protect your information.\n4. Third Parties: We do not sell or share your personal data with third parties for marketing purposes.\n5. Your Rights: You can request access to or deletion of your data at any time.'**
  String get privacyContent;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get registerButton;

  /// No description provided for @registerHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log In'**
  String get registerHaveAccount;

  /// No description provided for @registerErrorName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get registerErrorName;

  /// No description provided for @registerErrorEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get registerErrorEmail;

  /// No description provided for @registerErrorPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get registerErrorPassword;

  /// No description provided for @registerErrorMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get registerErrorMatch;

  /// No description provided for @registerErrorTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms of use.'**
  String get registerErrorTerms;

  /// No description provided for @registerErrorConflict.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get registerErrorConflict;

  /// No description provided for @registerGenericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during registration.'**
  String get registerGenericError;

  /// No description provided for @verifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get verifyTitle;

  /// No description provided for @verifyDesc.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to {email}. Please enter the code below.'**
  String verifyDesc(String email);

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyButton;

  /// No description provided for @verifyResend.
  ///
  /// In en, this message translates to:
  /// **'Send New Code'**
  String get verifyResend;

  /// No description provided for @verifyWait.
  ///
  /// In en, this message translates to:
  /// **'Wait {seconds} seconds'**
  String verifyWait(int seconds);

  /// No description provided for @verifyErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'Incorrect code'**
  String get verifyErrorInvalid;

  /// No description provided for @verifySuccess.
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully'**
  String get verifySuccess;

  /// No description provided for @verifyGenericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during verification.'**
  String get verifyGenericError;

  /// No description provided for @myExamsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Exams'**
  String get myExamsTitle;

  /// No description provided for @myExamsCreate.
  ///
  /// In en, this message translates to:
  /// **'New Exam'**
  String get myExamsCreate;

  /// No description provided for @myExamsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any exams yet.'**
  String get myExamsEmpty;

  /// No description provided for @statusQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get statusQueued;

  /// No description provided for @statusGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating'**
  String get statusGenerating;

  /// No description provided for @statusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get statusReady;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @examQuestionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Questions'**
  String examQuestionCount(int count);

  /// No description provided for @examLastScore.
  ///
  /// In en, this message translates to:
  /// **'Last Score: '**
  String get examLastScore;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @dashboardGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back,'**
  String get dashboardGreeting;

  /// No description provided for @dashboardCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Exam'**
  String get dashboardCreateTitle;

  /// No description provided for @dashboardTabPrompt.
  ///
  /// In en, this message translates to:
  /// **'AI Prompt'**
  String get dashboardTabPrompt;

  /// No description provided for @dashboardTabFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter & Create'**
  String get dashboardTabFilter;

  /// No description provided for @dashboardPromptHint.
  ///
  /// In en, this message translates to:
  /// **'✨ e.g.: Prepare a 5-question, thought-provoking test on Quantum Physics...'**
  String get dashboardPromptHint;

  /// No description provided for @dashboardFilterLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get dashboardFilterLevel;

  /// No description provided for @dashboardFilterTopic.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get dashboardFilterTopic;

  /// No description provided for @dashboardFilterCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get dashboardFilterCount;

  /// No description provided for @dashboardFilterType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get dashboardFilterType;

  /// No description provided for @dashboardFilterSubtopicHint.
  ///
  /// In en, this message translates to:
  /// **'Add subtopic...'**
  String get dashboardFilterSubtopicHint;

  /// No description provided for @dashboardFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get dashboardFilterAll;

  /// No description provided for @levelElementary.
  ///
  /// In en, this message translates to:
  /// **'Elementary'**
  String get levelElementary;

  /// No description provided for @levelMiddle.
  ///
  /// In en, this message translates to:
  /// **'Middle School'**
  String get levelMiddle;

  /// No description provided for @levelHigh.
  ///
  /// In en, this message translates to:
  /// **'High School'**
  String get levelHigh;

  /// No description provided for @levelUniversity.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get levelUniversity;

  /// No description provided for @levelCollege.
  ///
  /// In en, this message translates to:
  /// **'College'**
  String get levelCollege;

  /// No description provided for @levelProfessional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get levelProfessional;

  /// No description provided for @typeMCQ.
  ///
  /// In en, this message translates to:
  /// **'Multiple Choice'**
  String get typeMCQ;

  /// No description provided for @typeOpen.
  ///
  /// In en, this message translates to:
  /// **'Open Ended'**
  String get typeOpen;

  /// No description provided for @typeTF.
  ///
  /// In en, this message translates to:
  /// **'True/False'**
  String get typeTF;

  /// No description provided for @typeMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get typeMixed;

  /// No description provided for @dashboardFilterSubtopic.
  ///
  /// In en, this message translates to:
  /// **'Sub-topic'**
  String get dashboardFilterSubtopic;

  /// No description provided for @dashboardFilterSubtopicSelect.
  ///
  /// In en, this message translates to:
  /// **'Select Sub-topic'**
  String get dashboardFilterSubtopicSelect;

  /// No description provided for @dashboardFilterSubtopicOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get dashboardFilterSubtopicOther;

  /// No description provided for @dashboardFilterTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Add Title (e.g.: Exponentials)'**
  String get dashboardFilterTitleHint;

  /// No description provided for @dashboardFilterExamTemplate.
  ///
  /// In en, this message translates to:
  /// **'Exam Template'**
  String get dashboardFilterExamTemplate;

  /// No description provided for @dashboardGenerateBtn.
  ///
  /// In en, this message translates to:
  /// **'Create Exam'**
  String get dashboardGenerateBtn;

  /// No description provided for @dashboardAutoTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto Pilot'**
  String get dashboardAutoTitle;

  /// No description provided for @dashboardAutoDesc.
  ///
  /// In en, this message translates to:
  /// **'How often should AI test you?'**
  String get dashboardAutoDesc;

  /// No description provided for @dashboardFreqDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get dashboardFreqDaily;

  /// No description provided for @dashboardFreqWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get dashboardFreqWeekly;

  /// No description provided for @dashboardFreqMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get dashboardFreqMonthly;

  /// No description provided for @dashboardFreqPassive.
  ///
  /// In en, this message translates to:
  /// **'Passive'**
  String get dashboardFreqPassive;

  /// No description provided for @dashboardAutoDayMonthly.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String dashboardAutoDayMonthly(int day);

  /// No description provided for @dayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySat;

  /// No description provided for @daySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySun;

  /// No description provided for @dashboardAutoDay.
  ///
  /// In en, this message translates to:
  /// **'Select Day'**
  String get dashboardAutoDay;

  /// No description provided for @dashboardAutoTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get dashboardAutoTime;

  /// No description provided for @dashboardAutoSave.
  ///
  /// In en, this message translates to:
  /// **'Update Auto-Pilot'**
  String get dashboardAutoSave;

  /// No description provided for @dashboardAutoActive.
  ///
  /// In en, this message translates to:
  /// **'Automation Active'**
  String get dashboardAutoActive;

  /// No description provided for @dashboardScheduleTime.
  ///
  /// In en, this message translates to:
  /// **'Schedule Time'**
  String get dashboardScheduleTime;

  /// No description provided for @dashboardArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Normal Exams'**
  String get dashboardArchiveTitle;

  /// No description provided for @dashboardAutoExamsTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic Exams'**
  String get dashboardAutoExamsTitle;

  /// No description provided for @dashboardViewAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get dashboardViewAll;

  /// No description provided for @attachmentSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Attachment'**
  String get attachmentSelectTitle;

  /// No description provided for @attachmentSourceGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get attachmentSourceGallery;

  /// No description provided for @attachmentSourceFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get attachmentSourceFiles;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'de',
        'en',
        'es',
        'fr',
        'tr'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
