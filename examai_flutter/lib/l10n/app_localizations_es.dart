// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get onboardingTitle1 => 'Supera tus límites con IA';

  @override
  String get onboardingDesc1 =>
      'ExamAI analiza tu estilo de aprendizaje y crea un plan de estudio personalizado. Identifica tus debilidades.';

  @override
  String get onboardingTitle2 => 'Diseña tu futuro hoy';

  @override
  String get onboardingDesc2 =>
      'Miles de preguntas, análisis instantáneos y comparaciones con compañeros. El camino más corto al éxito está ahora en tu bolsillo.';

  @override
  String get onboardingNext => 'Continuar';

  @override
  String get onboardingStart => 'Regístrate gratis';

  @override
  String get onboardingLoginLink => '¿Ya tienes una cuenta? Iniciar sesión';

  @override
  String get loginTitle => 'Crea tus exámenes al instante con IA.';

  @override
  String get loginEmail => 'Correo electrónico';

  @override
  String get loginPassword => 'Contraseña';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get loginNoAccount => '¿No tienes una cuenta? Regístrate';

  @override
  String get loginErrorEmpty => 'Por favor ingresa tu correo y contraseña.';

  @override
  String get loginErrorInvalid => 'Correo o contraseña inválidos';

  @override
  String get loginErrorUnverified => 'Correo no verificado';

  @override
  String get loginVerifyAction => 'Verificar';

  @override
  String get loginGenericError =>
      'Error al iniciar sesión. Por favor intenta de nuevo.';

  @override
  String get registerTitle => 'Registrarse';

  @override
  String get registerSubtitle =>
      'Comienza a descubrir tu potencial con ExamAI.';

  @override
  String get registerName => 'Nombre completo';

  @override
  String get registerEmail => 'Correo electrónico';

  @override
  String get registerPassword => 'Contraseña';

  @override
  String get registerConfirmPassword => 'Confirmar contraseña';

  @override
  String get registerTermsPrefix => 'He leído y acepto los ';

  @override
  String get registerTermsLink => 'Términos de servicio';

  @override
  String get registerAnd => ' y la ';

  @override
  String get registerPrivacyLink => 'Política de privacidad';

  @override
  String get registerTermsSuffix => '.';

  @override
  String get termsTitle => 'Términos de servicio';

  @override
  String get termsContent =>
      '¡Bienvenido a ExamAI! Al utilizar nuestra plataforma, aceptas estos términos.\n\n1. Aceptación de los términos: Al acceder a ExamAI, aceptas estar sujeto a estos términos.\n2. Cuentas de usuario: Eres responsable de mantener la confidencialidad de tu cuenta.\n3. Precisión del contenido: El contenido generado por IA es para fines educativos.\n4. Conducta prohibida: Aceptas no hacer un mal uso de la plataforma.\n5. Modificaciones: Nos reservamos el derecho de actualizar estos términos.';

  @override
  String get privacyTitle => 'Política de privacidad';

  @override
  String get privacyContent =>
      'En ExamAI, nos tomamos en serio tu privacidad.\n\n1. Colección de información: Recopilamos tu nombre y correo electrónico.\n2. Uso de datos: Tus datos se utilizan para la autenticación.\n3. Seguridad de los datos: Implementamos medidas de seguridad avanzadas.\n4. Terceros: No vendemos tus datos personales.\n5. Tus derechos: Puedes solicitar la eliminación de tus datos.';

  @override
  String get registerButton => 'Registrarse';

  @override
  String get registerHaveAccount => '¿Ya tienes una cuenta? Iniciar sesión';

  @override
  String get registerErrorName => 'Por favor ingresa tu nombre.';

  @override
  String get registerErrorEmail => 'Ingresa un correo electrónico válido.';

  @override
  String get registerErrorPassword =>
      'La contraseña debe tener al menos 6 caracteres.';

  @override
  String get registerErrorMatch => 'Las contraseñas no coinciden.';

  @override
  String get registerErrorTerms => 'Por favor acepta los términos de uso.';

  @override
  String get registerErrorConflict => 'Este correo ya está registrado';

  @override
  String get registerGenericError => 'Ocurrió un error durante el registro.';

  @override
  String get verifyTitle => 'Verificación de correo';

  @override
  String verifyDesc(String email) {
    return 'Enviamos un código de verificación a $email. Ingresa el código a continuación.';
  }

  @override
  String get verifyButton => 'Verificar';

  @override
  String get verifyResend => 'Enviar nuevo código';

  @override
  String verifyWait(int seconds) {
    return 'Espera $seconds segundos';
  }

  @override
  String get verifyErrorInvalid => 'Código incorrecto';

  @override
  String get verifySuccess => 'Correo verificado con éxito';

  @override
  String get verifyGenericError => 'Ocurrió un error durante la verificación.';

  @override
  String get myExamsTitle => 'Mis Exámenes';

  @override
  String get myExamsCreate => 'Nuevo Examen';

  @override
  String get myExamsEmpty => 'Aún no tienes exámenes.';

  @override
  String get statusQueued => 'En cola';

  @override
  String get statusGenerating => 'Generando';

  @override
  String get statusReady => 'Listo';

  @override
  String get statusFailed => 'Fallido';

  @override
  String examQuestionCount(int count) {
    return '$count Preguntas';
  }

  @override
  String get examLastScore => 'Última puntuación: ';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get dashboardGreeting => 'Bienvenido de nuevo,';

  @override
  String get dashboardCreateTitle => 'Crear examen';

  @override
  String get dashboardTabPrompt => 'Prompt IA';

  @override
  String get dashboardTabFilter => 'Filtrar y crear';

  @override
  String get dashboardPromptHint =>
      '✨ ej.: Prepara un test estimulante de 5 preguntas sobre Física Cuántica...';

  @override
  String get dashboardFilterLevel => 'Nivel';

  @override
  String get dashboardFilterTopic => 'Tema';

  @override
  String get dashboardFilterCount => 'Cantidad';

  @override
  String get dashboardFilterType => 'Tipo';

  @override
  String get dashboardFilterSubtopicHint => 'Agregar subtema...';

  @override
  String get dashboardFilterAll => 'Todos';

  @override
  String get levelElementary => 'Primaria';

  @override
  String get levelMiddle => 'Secundaria';

  @override
  String get levelHigh => 'Bachillerato';

  @override
  String get levelUniversity => 'Universidad';

  @override
  String get levelCollege => 'Colegio';

  @override
  String get levelProfessional => 'Profesional';

  @override
  String get typeMCQ => 'Opción Múltiple';

  @override
  String get typeOpen => 'Preguntas Abiertas';

  @override
  String get typeTF => 'Verdadero/Falso';

  @override
  String get typeMixed => 'Mixto';

  @override
  String get dashboardFilterSubtopic => 'Subtema';

  @override
  String get dashboardFilterSubtopicSelect => 'Seleccionar subtema';

  @override
  String get dashboardFilterSubtopicOther => 'Otro';

  @override
  String get dashboardFilterTitleHint => 'Agregar título (ej.: Exponenciales)';

  @override
  String get dashboardFilterExamTemplate => 'Plantilla de examen';

  @override
  String get dashboardGenerateBtn => 'Crear examen';

  @override
  String get dashboardAutoTitle => 'Piloto automático';

  @override
  String get dashboardAutoDesc => '¿Con qué frecuencia debe evaluarte la IA?';

  @override
  String get dashboardFreqDaily => 'Diario';

  @override
  String get dashboardFreqWeekly => 'Semanal';

  @override
  String get dashboardFreqMonthly => 'Mensual';

  @override
  String get dashboardFreqPassive => 'Pasivo';

  @override
  String dashboardAutoDayMonthly(int day) {
    return 'Día $day';
  }

  @override
  String get dayMon => 'Lun';

  @override
  String get dayTue => 'Mar';

  @override
  String get dayWed => 'Mié';

  @override
  String get dayThu => 'Jue';

  @override
  String get dayFri => 'Vie';

  @override
  String get daySat => 'Sáb';

  @override
  String get daySun => 'Dom';

  @override
  String get dashboardAutoDay => 'Seleccionar día';

  @override
  String get dashboardAutoTime => 'Seleccionar hora';

  @override
  String get dashboardAutoSave => 'Actualizar piloto automático';

  @override
  String get dashboardAutoActive => 'Automatización activa';

  @override
  String get dashboardScheduleTime => 'Hora programada';

  @override
  String get dashboardArchiveTitle => 'Mi archivo';

  @override
  String get dashboardViewAll => 'Todo';
}
