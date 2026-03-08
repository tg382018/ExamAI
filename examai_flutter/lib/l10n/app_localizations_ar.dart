// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get onboardingTitle1 => 'تجاوز حدودك مع الذكاء الاصطناعي';

  @override
  String get onboardingDesc1 =>
      'يقوم ExamAI بتحليل أسلوب التعلم الخاص بك وإنشاء خطة دراسية مخصصة لك. حدد نقاط ضعفك بدقة.';

  @override
  String get onboardingTitle2 => 'صمم مستقبلك اليوم';

  @override
  String get onboardingDesc2 =>
      'آلاف الأسئلة، تحليلات فورية ومقارنات مع زملائك. أقصر طريق للنجاح أصبح الآن في جيبك.';

  @override
  String get onboardingNext => 'متابعة';

  @override
  String get onboardingStart => 'سجل مجاناً';

  @override
  String get onboardingLoginLink => 'هل لديك حساب بالفعل؟ تسجيل الدخول';

  @override
  String get loginTitle => 'أنشئ امتحاناتك فوراً باستخدام الذكاء الاصطناعي.';

  @override
  String get loginEmail => 'البريد الإلكتروني';

  @override
  String get loginPassword => 'كلمة المرور';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get loginNoAccount => 'ليس لديك حساب؟ سجل الآن';

  @override
  String get loginErrorEmpty => 'يرجى إدخال البريد الإلكتروني وكلمة المرور.';

  @override
  String get loginErrorInvalid => 'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get loginErrorUnverified => 'البريد الإلكتروني غير مفعل';

  @override
  String get loginVerifyAction => 'تفعيل';

  @override
  String get loginGenericError => 'فشل تسجيل الدخول. يرجى المحاولة مرة أخرى.';

  @override
  String get registerTitle => 'إنشاء حساب';

  @override
  String get registerSubtitle => 'ابدأ في اكتشاف إمكانياتك مع ExamAI.';

  @override
  String get registerName => 'الاسم الكامل';

  @override
  String get registerEmail => 'البريد الإلكتروني';

  @override
  String get registerPassword => 'كلمة المرور';

  @override
  String get registerConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get registerTermsPrefix => 'لقد قرأت وأوافق على ';

  @override
  String get registerTermsLink => 'شروط الخدمة';

  @override
  String get registerAnd => ' و ';

  @override
  String get registerPrivacyLink => 'سياسة الخصوصية';

  @override
  String get registerTermsSuffix => '.';

  @override
  String get termsTitle => 'شروط الخدمة';

  @override
  String get termsContent =>
      'مرحبًا بك في ExamAI! باستخدام منصتنا، فإنك توافق على هذه الشروط.\n\n1. قبول الشروط: من خلال الوصول إلى ExamAI ، فإنك توافق على الالتزام بهذه الشروط.\n2. حسابات المستخدمين: أنت مسؤول عن الحفاظ على سرية معلومات حسابك.\n3. دقة المحتوى: المحتوى الذي يتم إنشاؤه بواسطة الذكاء الاصطناعي مخصص للأغراض التعليمية.\n4. السلوك المحظور: أنت توافق على عدم إساءة استخدام المنصة.\n5. التعديلات: نحتفظ بالحق في تحديث هذه الشروط في أي وقت.';

  @override
  String get privacyTitle => 'سياسة الخصوصية';

  @override
  String get privacyContent =>
      'في ExamAI ، نأخذ خصوصيتك على محمل الجد.\n\n1. جمع المعلومات: نجمع اسمك وبريدك الإلكتروني.\n2. استخدام البيانات: تُستخدم بياناتك للمصادقة.\n3. أمن البيانات: نطبق تدابير أمنية متقدمة.\n4. أطراف ثالثة: نحن لا نبيع بياناتك الشخصية.\n5. حقوقك: يمكنك طلب حذف بياناتك في أي وقت.';

  @override
  String get registerButton => 'إنشاء حساب';

  @override
  String get registerHaveAccount => 'هل لديك حساب بالفعل؟ تسجيل الدخول';

  @override
  String get registerErrorName => 'يرجى إدخال اسمك.';

  @override
  String get registerErrorEmail => 'أدخل بريداً إلكترونياً صحيحاً.';

  @override
  String get registerErrorPassword =>
      'كلمة المرور يجب أن تكون 6 أحرف على الأقل.';

  @override
  String get registerErrorMatch => 'كلمات المرور غير متطابقة.';

  @override
  String get registerErrorTerms => 'يرجى قبول شروط الاستخدام.';

  @override
  String get registerErrorConflict => 'هذا البريد الإلكتروني مسجل بالفعل';

  @override
  String get registerGenericError => 'حدث خطأ أثناء التسجيل.';

  @override
  String get verifyTitle => 'تفعيل البريد الإلكتروني';

  @override
  String verifyDesc(String email) {
    return 'لقد أرسلنا رمز تفعيل إلى $email. يرجى إدخال الرمز أدناه.';
  }

  @override
  String get verifyButton => 'تفعيل';

  @override
  String get verifyResend => 'إرسال رمز جديد';

  @override
  String verifyWait(int seconds) {
    return 'انتظر $seconds ثانية';
  }

  @override
  String get verifyErrorInvalid => 'الرمز غير صحيح';

  @override
  String get verifySuccess => 'تم تفعيل البريد الإلكتروني بنجاح';

  @override
  String get verifyGenericError => 'حدث خطأ أثناء التفعيل.';

  @override
  String get myExamsTitle => 'امتحاناتي';

  @override
  String get myExamsCreate => 'امتحان جديد';

  @override
  String get myExamsEmpty => 'لا يوجد لديك امتحانات بعد.';

  @override
  String get statusQueued => 'في الانتظار';

  @override
  String get statusGenerating => 'جاري الإنشاء';

  @override
  String get statusReady => 'جاهز';

  @override
  String get statusFailed => 'فشل';

  @override
  String examQuestionCount(int count) {
    return '$count سؤال';
  }

  @override
  String get examLastScore => 'آخر درجة: ';

  @override
  String get commonClose => 'إغلاق';
}
