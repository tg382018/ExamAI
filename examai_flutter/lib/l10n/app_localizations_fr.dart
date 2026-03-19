// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get onboardingTitle1 => 'Repoussez vos limites avec l\'IA';

  @override
  String get onboardingDesc1 =>
      'ExamAI analyse votre style d\'apprentissage et crée un plan d\'étude personnalisé. Identifiez vos faiblesses.';

  @override
  String get onboardingTitle2 => 'Concevez votre avenir dès aujourd\'hui';

  @override
  String get onboardingDesc2 =>
      'Des milliers de questions, des analyses instantanées et des comparaisons avec vos pairs. Le chemin le plus court vers le succès est désormais dans votre poche.';

  @override
  String get onboardingNext => 'Continuer';

  @override
  String get onboardingStart => 'S\'inscrire gratuitement';

  @override
  String get onboardingLoginLink => 'Vous avez déjà un compte ? Se connecter';

  @override
  String get loginTitle => 'Créez vos examens instantanément avec l\'IA.';

  @override
  String get loginEmail => 'Adresse e-mail';

  @override
  String get loginPassword => 'Mot de passe';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get loginNoAccount => 'Vous n\'avez pas de compte ? S\'inscrire';

  @override
  String get loginErrorEmpty =>
      'Veuillez entrer votre e-mail et votre mot de passe.';

  @override
  String get loginErrorInvalid => 'E-mail ou mot de passe invalide';

  @override
  String get loginErrorUnverified => 'E-mail non vérifié';

  @override
  String get loginVerifyAction => 'Vérifier';

  @override
  String get loginGenericError => 'Échec de la connexion. Veuillez réessayer.';

  @override
  String get registerTitle => 'S\'inscrire';

  @override
  String get registerSubtitle =>
      'Commencez à découvrir votre potentiel avec ExamAI.';

  @override
  String get registerName => 'Nom complet';

  @override
  String get registerEmail => 'Adresse e-mail';

  @override
  String get registerPassword => 'Mot de passe';

  @override
  String get registerConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get registerTermsPrefix => 'J\'ai lu et j\'accepte les ';

  @override
  String get registerTermsLink => 'Conditions d\'utilisation';

  @override
  String get registerAnd => ' et la ';

  @override
  String get registerPrivacyLink => 'Politique de confidentialité';

  @override
  String get registerTermsSuffix => '.';

  @override
  String get termsTitle => 'Conditions d\'utilisation';

  @override
  String get termsContent =>
      'Bienvenue sur ExamAI ! En utilisant notre plateforme, vous acceptez ces conditions.\n\n1. Acceptation des conditions : En accédant à ExamAI, vous acceptez d\'être lié par ces conditions.\n2. Comptes d\'utilisateurs : Vous êtes responsable du maintien de la confidentialité de vos informations de compte.\n3. Exactitude du contenu : Le contenu généré par l\'IA est à des fins éducatives. Les utilisateurs doivent vérifier les informations critiques.\n4. Conduite interdite : Vous acceptez de ne pas abuser de la plateforme.\n5. Modifications : Nous nous réservons le droit de mettre à jour ces conditions.';

  @override
  String get privacyTitle => 'Politique de confidentialité';

  @override
  String get privacyContent =>
      'Chez ExamAI, nous prenons votre vie privée au sérieux.\n\n1. Collecte d\'informations : Nous collectons votre nom et votre adresse e-mail.\n2. Utilisation des données : Vos données sont utilisées pour l\'authentification.\n3. Sécurité des données : Nous mettons en œuvre des mesures de sécurité avancées.\n4. Tiers : Nous ne vendons pas vos données personnelles.\n5. Vos droits : Vous pouvez demander la suppression de vos données.';

  @override
  String get registerButton => 'S\'inscrire';

  @override
  String get registerHaveAccount => 'Vous avez déjà un compte ? Se connecter';

  @override
  String get registerErrorName => 'Veuillez entrer votre nom.';

  @override
  String get registerErrorEmail => 'Entrez une adresse e-mail valide.';

  @override
  String get registerErrorPassword =>
      'Le mot de passe doit comporter au moins 6 caractères.';

  @override
  String get registerErrorMatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get registerErrorTerms =>
      'Veuillez accepter les conditions d\'utilisation.';

  @override
  String get registerErrorConflict => 'Cet e-mail est déjà enregistré';

  @override
  String get registerGenericError =>
      'Une erreur s\'est produite lors de l\'inscription.';

  @override
  String get verifyTitle => 'Vérification de l\'e-mail';

  @override
  String verifyDesc(String email) {
    return 'Nous avons envoyé un code de vérification à $email. Veuillez entrer le code ci-dessous.';
  }

  @override
  String get verifyButton => 'Vérifier';

  @override
  String get verifyResend => 'Envoyer un nouveau code';

  @override
  String verifyWait(int seconds) {
    return 'Attendez $seconds secondes';
  }

  @override
  String get verifyErrorInvalid => 'Code incorrect';

  @override
  String get verifySuccess => 'E-mail vérifié avec succès';

  @override
  String get verifyGenericError =>
      'Une erreur s\'est produite lors de la vérification.';

  @override
  String get myExamsTitle => 'Mes Examens';

  @override
  String get myExamsCreate => 'Nouvel Examen';

  @override
  String get myExamsEmpty => 'Vous n\'avez pas encore d\'examens.';

  @override
  String get statusQueued => 'En attente';

  @override
  String get statusGenerating => 'Génération';

  @override
  String get statusReady => 'Prêt';

  @override
  String get statusFailed => 'Échoué';

  @override
  String examQuestionCount(int count) {
    return '$count Questions';
  }

  @override
  String get examLastScore => 'Dernier score: ';

  @override
  String get commonClose => 'Fermer';

  @override
  String get dashboardGreeting => 'Bon retour,';

  @override
  String get dashboardCreateTitle => 'Créer un examen';

  @override
  String get dashboardTabPrompt => 'Prompt IA';

  @override
  String get dashboardTabFilter => 'Filtrer & Créer';

  @override
  String get dashboardPromptHint =>
      '✨ ex.: Prépare un test stimulant de 5 questions sur la Physique Quantique...';

  @override
  String get dashboardFilterLevel => 'Niveau';

  @override
  String get dashboardFilterTopic => 'Sujet';

  @override
  String get dashboardFilterCount => 'Nombre';

  @override
  String get dashboardFilterType => 'Type';

  @override
  String get dashboardFilterSubtopicHint => 'Ajouter un sous-sujet...';

  @override
  String get dashboardFilterAll => 'Tout';

  @override
  String get levelElementary => 'Élémentaire';

  @override
  String get levelMiddle => 'Collège';

  @override
  String get levelHigh => 'Lycée';

  @override
  String get levelUniversity => 'Université';

  @override
  String get levelCollege => 'École';

  @override
  String get levelProfessional => 'Professionnel';

  @override
  String get typeMCQ => 'QCM';

  @override
  String get typeOpen => 'Questions Ouvertes';

  @override
  String get typeTF => 'Vrai/Faux';

  @override
  String get typeMixed => 'Mixte';

  @override
  String get dashboardFilterSubtopic => 'Sous-sujet';

  @override
  String get dashboardFilterSubtopicSelect => 'Choisir un sous-sujet';

  @override
  String get dashboardFilterSubtopicOther => 'Autre';

  @override
  String get dashboardFilterTitleHint =>
      'Ajouter un titre (ex.: Exponentielles)';

  @override
  String get dashboardFilterExamTemplate => 'Modèle d\'examen';

  @override
  String get dashboardGenerateBtn => 'Créer l\'examen';

  @override
  String get dashboardAutoTitle => 'Pilote automatique';

  @override
  String get dashboardAutoDesc =>
      'À quelle fréquence l\'IA doit-elle vous tester ?';

  @override
  String get dashboardFreqDaily => 'Quotidien';

  @override
  String get dashboardFreqWeekly => 'Hebdomadaire';

  @override
  String get dashboardFreqMonthly => 'Mensuel';

  @override
  String get dashboardFreqPassive => 'Passif';

  @override
  String dashboardAutoDayMonthly(int day) {
    return 'Jour $day';
  }

  @override
  String get dayMon => 'Lun';

  @override
  String get dayTue => 'Mar';

  @override
  String get dayWed => 'Mer';

  @override
  String get dayThu => 'Jeu';

  @override
  String get dayFri => 'Ven';

  @override
  String get daySat => 'Sam';

  @override
  String get daySun => 'Dim';

  @override
  String get dashboardAutoDay => 'Choisir le jour';

  @override
  String get dashboardAutoTime => 'Choisir l\'heure';

  @override
  String get dashboardAutoSave => 'Mettre à jour le pilote auto';

  @override
  String get dashboardAutoActive => 'Automatisation active';

  @override
  String get dashboardScheduleTime => 'Heure planifiée';

  @override
  String get dashboardArchiveTitle => 'Examens Normaux';

  @override
  String get dashboardAutoExamsTitle => 'Examens Automatiques';

  @override
  String get dashboardViewAll => 'Tout';

  @override
  String get attachmentSelectTitle => 'Sélectionner une pièce jointe';

  @override
  String get attachmentSourceGallery => 'Galerie';

  @override
  String get attachmentSourceFiles => 'Fichiers';
}
