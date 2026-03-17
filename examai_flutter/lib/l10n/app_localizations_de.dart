// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get onboardingTitle1 => 'Gehe an deine Grenzen mit KI';

  @override
  String get onboardingDesc1 =>
      'ExamAI analysiert deinen Lernstil und erstellt einen personalisierten Lernplan. Identifiziere deine Schwächen genau.';

  @override
  String get onboardingTitle2 => 'Gestalte deine Zukunft heute';

  @override
  String get onboardingDesc2 =>
      'Tausende von Fragen, sofortige Analysen und Vergleiche mit Gleichaltrigen. Der kürzeste Weg zum Erfolg liegt jetzt in deiner Tasche.';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get onboardingStart => 'Kostenlos registrieren';

  @override
  String get onboardingLoginLink => 'Hast du bereits ein Konto? Einloggen';

  @override
  String get loginTitle => 'Erstelle deine Prüfungen sofort mit KI.';

  @override
  String get loginEmail => 'E-Mail-Adresse';

  @override
  String get loginPassword => 'Passwort';

  @override
  String get loginButton => 'Einloggen';

  @override
  String get loginNoAccount => 'Hast du noch kein Konto? Registrieren';

  @override
  String get loginErrorEmpty => 'Bitte gib deine E-Mail und dein Passwort ein.';

  @override
  String get loginErrorInvalid => 'Ungültige E-Mail oder Passwort';

  @override
  String get loginErrorUnverified => 'E-Mail nicht verifiziert';

  @override
  String get loginVerifyAction => 'Verifizieren';

  @override
  String get loginGenericError =>
      'Login fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get registerTitle => 'Registrieren';

  @override
  String get registerSubtitle => 'Entdecken Sie Ihr Potenzial mit ExamAI.';

  @override
  String get registerName => 'Vollständiger Name';

  @override
  String get registerEmail => 'E-Mail-Adresse';

  @override
  String get registerPassword => 'Passwort';

  @override
  String get registerConfirmPassword => 'Passwort bestätigen';

  @override
  String get registerTermsPrefix => 'Ich habe die ';

  @override
  String get registerTermsLink => 'Nutzungsbedingungen';

  @override
  String get registerAnd => ' und die ';

  @override
  String get registerPrivacyLink => 'Datenschutzerklärung';

  @override
  String get registerTermsSuffix => ' gelesen und akzeptiere sie.';

  @override
  String get termsTitle => 'Nutzungsbedingungen';

  @override
  String get termsContent =>
      'Willkommen bei ExamAI! Durch die Nutzung unserer Plattform erklären Sie sich mit diesen Bedingungen einverstanden.\n\n1. Annahme der Bedingungen: Mit dem Zugriff auf ExamAI erklären Sie sich mit diesen Bedingungen einverstanden.\n2. Benutzerkonten: Sie sind für die Geheimhaltung Ihrer Kontoinformationen verantwortlich.\n3. Genauigkeit der Inhalte: KI-generierte Inhalte dienen Bildungszwecken.\n4. Verbotenes Verhalten: Sie erklären sich damit einverstanden, die Plattform nicht zu missbrauchen.\n5. Änderungen: Wir behalten uns das Recht vor, diese Bedingungen jederzeit zu aktualisieren.';

  @override
  String get privacyTitle => 'Datenschutzerklärung';

  @override
  String get privacyContent =>
      'Bei ExamAI nehmen wir Ihre Privatsphäre ernst.\n\n1. Datenerhebung: Wir erheben Ihren Namen und Ihre E-Mail-Adresse.\n2. Datennutzung: Ihre Daten werden zur Authentifizierung verwendet.\n3. Datensicherheit: Wir setzen fortschrittliche Sicherheitsmaßnahmen ein.\n4. Dritte: Wir verkaufen Ihre persönlichen Daten nicht.\n5. Ihre Rechte: Sie können jederzeit die Löschung Ihrer Daten beantragen.';

  @override
  String get registerButton => 'Registrieren';

  @override
  String get registerHaveAccount => 'Hast du bereits ein Konto? Einloggen';

  @override
  String get registerErrorName => 'Bitte gib deinen Namen ein.';

  @override
  String get registerErrorEmail => 'Gib eine gültige E-Mail-Adresse ein.';

  @override
  String get registerErrorPassword =>
      'Das Passwort muss mindestens 6 Zeichen lang sein.';

  @override
  String get registerErrorMatch => 'Passwörter stimmen nicht überein.';

  @override
  String get registerErrorTerms => 'Bitte akzeptiere die Nutzungsbedingungen.';

  @override
  String get registerErrorConflict => 'Diese E-Mail ist bereits registriert';

  @override
  String get registerGenericError =>
      'Bei der Registrierung ist ein Fehler aufgetreten.';

  @override
  String get verifyTitle => 'E-Mail-Verifizierung';

  @override
  String verifyDesc(String email) {
    return 'Wir haben einen Verifizierungscode an $email gesendet. Bitte gib den Code unten ein.';
  }

  @override
  String get verifyButton => 'Verifizieren';

  @override
  String get verifyResend => 'Neuen Code senden';

  @override
  String verifyWait(int seconds) {
    return 'Warte $seconds Sekunden';
  }

  @override
  String get verifyErrorInvalid => 'Falscher Code';

  @override
  String get verifySuccess => 'E-Mail erfolgreich verifiziert';

  @override
  String get verifyGenericError =>
      'Bei der Verifizierung ist ein Fehler aufgetreten.';

  @override
  String get myExamsTitle => 'Meine Prüfungen';

  @override
  String get myExamsCreate => 'Neue Prüfung';

  @override
  String get myExamsEmpty => 'Du hast noch keine Prüfungen.';

  @override
  String get statusQueued => 'Warteschlange';

  @override
  String get statusGenerating => 'Erstellung';

  @override
  String get statusReady => 'Bereit';

  @override
  String get statusFailed => 'Fehlgeschlagen';

  @override
  String examQuestionCount(int count) {
    return '$count Fragen';
  }

  @override
  String get examLastScore => 'Letztes Ergebnis: ';

  @override
  String get commonClose => 'Schließen';

  @override
  String get dashboardGreeting => 'Willkommen zurück,';

  @override
  String get dashboardCreateTitle => 'Prüfung erstellen';

  @override
  String get dashboardTabPrompt => 'KI Prompt';

  @override
  String get dashboardTabFilter => 'Filtern & Erstellen';

  @override
  String get dashboardPromptHint =>
      '✨ z.B.: Erstelle einen anspruchsvollen Test mit 5 Fragen über Quantenphysik...';

  @override
  String get dashboardFilterLevel => 'Stufe';

  @override
  String get dashboardFilterTopic => 'Thema';

  @override
  String get dashboardFilterCount => 'Anzahl';

  @override
  String get dashboardFilterType => 'Typ';

  @override
  String get dashboardFilterSubtopicHint => 'Unterthema hinzufügen...';

  @override
  String get dashboardFilterAll => 'Alle';

  @override
  String get levelElementary => 'Grundschule';

  @override
  String get levelMiddle => 'Realschule';

  @override
  String get levelHigh => 'Gymnasium';

  @override
  String get levelUniversity => 'Universität';

  @override
  String get levelCollege => 'Fachhochschule';

  @override
  String get levelProfessional => 'Beruflich';

  @override
  String get typeMCQ => 'Multiple Choice';

  @override
  String get typeOpen => 'Offene Fragen';

  @override
  String get typeTF => 'Richtig/Falsch';

  @override
  String get typeMixed => 'Gemischt';

  @override
  String get dashboardFilterSubtopic => 'Unterthema';

  @override
  String get dashboardFilterSubtopicSelect => 'Unterthema wählen';

  @override
  String get dashboardFilterSubtopicOther => 'Sonstiges';

  @override
  String get dashboardFilterTitleHint =>
      'Titel hinzufügen (z.B.: Exponentialrechnung)';

  @override
  String get dashboardFilterExamTemplate => 'Prüfungsvorlage';

  @override
  String get dashboardGenerateBtn => 'Prüfung erstellen';

  @override
  String get dashboardAutoTitle => 'Autopilot';

  @override
  String get dashboardAutoDesc => 'Wie oft soll die KI dich testen?';

  @override
  String get dashboardFreqDaily => 'Täglich';

  @override
  String get dashboardFreqWeekly => 'Wöchentlich';

  @override
  String get dashboardFreqMonthly => 'Monatlich';

  @override
  String get dashboardFreqPassive => 'Passiv';

  @override
  String dashboardAutoDayMonthly(int day) {
    return 'Tag $day';
  }

  @override
  String get dayMon => 'Mo';

  @override
  String get dayTue => 'Di';

  @override
  String get dayWed => 'Mi';

  @override
  String get dayThu => 'Do';

  @override
  String get dayFri => 'Fr';

  @override
  String get daySat => 'Sa';

  @override
  String get daySun => 'So';

  @override
  String get dashboardAutoDay => 'Tag wählen';

  @override
  String get dashboardAutoTime => 'Uhrzeit wählen';

  @override
  String get dashboardAutoSave => 'Autopilot aktualisieren';

  @override
  String get dashboardAutoActive => 'Automatisierung aktiv';

  @override
  String get dashboardScheduleTime => 'Geplante Zeit';

  @override
  String get dashboardArchiveTitle => 'Mein Archiv';

  @override
  String get dashboardViewAll => 'Alle';
}
