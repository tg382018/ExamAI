// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get onboardingTitle1 => 'Push Your Limits with AI';

  @override
  String get onboardingDesc1 =>
      'ExamAI analyzes your learning style and creates a personalized study plan. Pinpoint your weaknesses.';

  @override
  String get onboardingTitle2 => 'Design Your Future Today';

  @override
  String get onboardingDesc2 =>
      'Thousands of questions, instant analysis, and peer comparisons. The shortest path to success is now in your pocket.';

  @override
  String get onboardingNext => 'Continue';

  @override
  String get onboardingStart => 'Sign Up for Free';

  @override
  String get onboardingLoginLink => 'Already have an account? Log In';

  @override
  String get loginTitle => 'Create your exams instantly with AI.';

  @override
  String get loginEmail => 'Email Address';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginButton => 'Log In';

  @override
  String get loginNoAccount => 'Don\'t have an account? Sign Up';

  @override
  String get loginErrorEmpty => 'Please enter your email and password.';

  @override
  String get loginErrorInvalid => 'Invalid email or password';

  @override
  String get loginErrorUnverified => 'Email not verified';

  @override
  String get loginVerifyAction => 'Verify';

  @override
  String get loginGenericError => 'Login failed. Please try again.';

  @override
  String get registerTitle => 'Sign Up';

  @override
  String get registerSubtitle =>
      'Start discovering your potential with ExamAI.';

  @override
  String get registerName => 'Full Name';

  @override
  String get registerEmail => 'Email Address';

  @override
  String get registerPassword => 'Password';

  @override
  String get registerConfirmPassword => 'Confirm Password';

  @override
  String get registerTermsPrefix => 'I have read and agree to the ';

  @override
  String get registerTermsLink => 'Terms of Service';

  @override
  String get registerAnd => ' and ';

  @override
  String get registerPrivacyLink => 'Privacy Policy';

  @override
  String get registerTermsSuffix => '.';

  @override
  String get termsTitle => 'Terms of Service';

  @override
  String get termsContent =>
      'Welcome to ExamAI! By using our platform, you agree to these terms.\n\n1. Acceptance of Terms: By accessing or using ExamAI, you agree to be bound by these terms.\n2. User Accounts: You are responsible for maintaining the confidentiality of your account information.\n3. Content Accuracy: AI-generated content is for educational purposes. Users should verify critical information.\n4. Prohibited Conduct: You agree not to misuse the platform or engage in any illegal activities.\n5. Modifications: We reserve the right to update these terms at any time.';

  @override
  String get privacyTitle => 'Privacy Policy';

  @override
  String get privacyContent =>
      'At ExamAI, we take your privacy seriously.\n\n1. Information Collection: We collect your name and email to provide and improve our services.\n2. Data Usage: Your data is used for authentication and personalizing your exam experience.\n3. Data Security: We implement advanced security measures to protect your information.\n4. Third Parties: We do not sell or share your personal data with third parties for marketing purposes.\n5. Your Rights: You can request access to or deletion of your data at any time.';

  @override
  String get registerButton => 'Sign Up';

  @override
  String get registerHaveAccount => 'Already have an account? Log In';

  @override
  String get registerErrorName => 'Please enter your name.';

  @override
  String get registerErrorEmail => 'Enter a valid email address.';

  @override
  String get registerErrorPassword => 'Password must be at least 6 characters.';

  @override
  String get registerErrorMatch => 'Passwords do not match.';

  @override
  String get registerErrorTerms => 'Please accept the terms of use.';

  @override
  String get registerErrorConflict => 'This email is already registered';

  @override
  String get registerGenericError => 'An error occurred during registration.';

  @override
  String get verifyTitle => 'Email Verification';

  @override
  String verifyDesc(String email) {
    return 'We sent a verification code to $email. Please enter the code below.';
  }

  @override
  String get verifyButton => 'Verify';

  @override
  String get verifyResend => 'Send New Code';

  @override
  String verifyWait(int seconds) {
    return 'Wait $seconds seconds';
  }

  @override
  String get verifyErrorInvalid => 'Incorrect code';

  @override
  String get verifySuccess => 'Email verified successfully';

  @override
  String get verifyGenericError => 'An error occurred during verification.';

  @override
  String get myExamsTitle => 'My Exams';

  @override
  String get myExamsCreate => 'New Exam';

  @override
  String get myExamsEmpty => 'You don\'t have any exams yet.';

  @override
  String get statusQueued => 'Queued';

  @override
  String get statusGenerating => 'Generating';

  @override
  String get statusReady => 'Ready';

  @override
  String get statusFailed => 'Failed';

  @override
  String examQuestionCount(int count) {
    return '$count Questions';
  }

  @override
  String get examLastScore => 'Last Score: ';

  @override
  String get commonClose => 'Close';

  @override
  String get dashboardGreeting => 'Welcome Back,';

  @override
  String get dashboardCreateTitle => 'Create Exam';

  @override
  String get dashboardTabPrompt => 'AI Prompt';

  @override
  String get dashboardTabFilter => 'Filter & Create';

  @override
  String get dashboardPromptHint =>
      '✨ e.g.: Prepare a 5-question, thought-provoking test on Quantum Physics...';

  @override
  String get dashboardFilterLevel => 'Level';

  @override
  String get dashboardFilterTopic => 'Topic';

  @override
  String get dashboardFilterCount => 'Count';

  @override
  String get dashboardFilterType => 'Type';

  @override
  String get dashboardFilterSubtopicHint => 'Add subtopic...';

  @override
  String get dashboardFilterAll => 'All';

  @override
  String get levelElementary => 'Elementary';

  @override
  String get levelMiddle => 'Middle School';

  @override
  String get levelHigh => 'High School';

  @override
  String get levelUniversity => 'University';

  @override
  String get levelCollege => 'College';

  @override
  String get levelProfessional => 'Professional';

  @override
  String get typeMCQ => 'Multiple Choice';

  @override
  String get typeOpen => 'Open Ended';

  @override
  String get typeTF => 'True/False';

  @override
  String get typeMixed => 'Mixed';

  @override
  String get dashboardFilterSubtopic => 'Sub-topic';

  @override
  String get dashboardFilterSubtopicSelect => 'Select Sub-topic';

  @override
  String get dashboardFilterSubtopicOther => 'Other';

  @override
  String get dashboardFilterTitleHint => 'Add Title (e.g.: Exponentials)';

  @override
  String get dashboardFilterExamTemplate => 'Exam Template';

  @override
  String get dashboardGenerateBtn => 'Create Exam';

  @override
  String get dashboardAutoTitle => 'Auto Pilot';

  @override
  String get dashboardAutoDesc => 'How often should AI test you?';

  @override
  String get dashboardFreqDaily => 'Daily';

  @override
  String get dashboardFreqWeekly => 'Weekly';

  @override
  String get dashboardFreqMonthly => 'Monthly';

  @override
  String get dashboardFreqPassive => 'Passive';

  @override
  String dashboardAutoDayMonthly(int day) {
    return 'Day $day';
  }

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String get daySun => 'Sun';

  @override
  String get dashboardAutoDay => 'Select Day';

  @override
  String get dashboardAutoTime => 'Select Time';

  @override
  String get dashboardAutoSave => 'Update Auto-Pilot';

  @override
  String get dashboardAutoActive => 'Automation Active';

  @override
  String get dashboardScheduleTime => 'Schedule Time';

  @override
  String get dashboardArchiveTitle => 'My Archive';

  @override
  String get dashboardViewAll => 'All';
}
