// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get onboardingTitle1 => 'Yapay Zeka ile Limitlerini Aş';

  @override
  String get onboardingDesc1 =>
      'ExamAI, öğrenme stilini analiz eder ve sana özel çalışma programı oluşturur. Eksiklerini nokta atışı tespit et.';

  @override
  String get onboardingTitle2 => 'Geleceğini Bugünden Tasarla';

  @override
  String get onboardingDesc2 =>
      'Binlerce soru, anlık analiz ve rakip karşılaştırmaları. Başarıya giden en kısa yol artık cebinde.';

  @override
  String get onboardingNext => 'Devam Et';

  @override
  String get onboardingStart => 'Ücretsiz Kayıt Ol';

  @override
  String get onboardingLoginLink => 'Zaten hesabın var mı? Giriş Yap';

  @override
  String get loginTitle => 'Yapay Zeka ile sınavlarını anında oluştur.';

  @override
  String get loginEmail => 'E-posta Adresi';

  @override
  String get loginPassword => 'Şifre';

  @override
  String get loginButton => 'Giriş Yap';

  @override
  String get loginNoAccount => 'Hesabın yok mu? Kayıt Ol';

  @override
  String get loginErrorEmpty => 'Lütfen e-posta ve şifrenizi girin.';

  @override
  String get loginErrorInvalid => 'E-posta veya şifre hatalı';

  @override
  String get loginErrorUnverified => 'E-posta doğrulanmamış';

  @override
  String get loginVerifyAction => 'Doğrula';

  @override
  String get loginGenericError => 'Giriş yapılamadı. Lütfen tekrar deneyin.';

  @override
  String get registerTitle => 'Kayıt Ol';

  @override
  String get registerSubtitle => 'ExamAI ile potansiyelini keşfetmeye başla.';

  @override
  String get registerName => 'Ad Soyad';

  @override
  String get registerEmail => 'E-posta Adresi';

  @override
  String get registerPassword => 'Şifre';

  @override
  String get registerConfirmPassword => 'Şifreyi Onayla';

  @override
  String get registerTermsPrefix => '';

  @override
  String get registerTermsLink => 'Kullanım Koşulları';

  @override
  String get registerAnd => ' ve ';

  @override
  String get registerPrivacyLink => 'Gizlilik Politikası';

  @override
  String get registerTermsSuffix => '\'nı okudum, kabul ediyorum.';

  @override
  String get termsTitle => 'Kullanım Koşulları';

  @override
  String get termsContent =>
      'ExamAI\'ya hoş geldiniz! Platformumuzu kullanarak bu şartları kabul etmiş sayılırsınız.\n\n1. Şartların Kabulü: ExamAI\'ya erişerek bu şartlara bağlı kalmayı kabul edersiniz.\n2. Kullanıcı Hesapları: Hesap bilgilerinizin gizliliğini korumaktan siz sorumlusunuz.\n3. İçerik Doğruluğu: Yapay zeka tarafından üretilen içerikler eğitim amaçlıdır. Kullanıcılar kritik bilgileri doğrulamalıdır.\n4. Yasaklanmış Davranışlar: Platformu kötüye kullanmamayı veya yasa dışı faaliyetlerde bulunmamayı kabul edersiniz.\n5. Değişiklikler: Bu şartları istediğimiz zaman güncelleme hakkını saklı tutarız.';

  @override
  String get privacyTitle => 'Gizlilik Politikası';

  @override
  String get privacyContent =>
      'ExamAI\'da gizliliğinizi ciddiye alıyoruz.\n\n1. Bilgi Toplama: Hizmetlerimizi sunmak ve iyileştirmek için adınızı ve e-postanızı topluyoruz.\n2. Veri Kullanımı: Verileriniz kimlik doğrulama ve sınav deneyiminizi kişiselleştirmek için kullanılır.\n3. Veri Güvenliği: Bilgilerinizi korumak için gelişmiş güvenlik önlemleri uyguluyoruz.\n4. Üçüncü Taraflar: Kişisel verilerinizi pazarlama amacıyla üçüncü taraflarla satmıyoruz veya paylaşmıyoruz.\n5. Haklarınız: İstediğiniz zaman verilerinize erişim veya silinme talebinde bulunabilirsiniz.';

  @override
  String get registerButton => 'Kayıt Ol';

  @override
  String get registerHaveAccount => 'Zaten hesabın var mı? Giriş Yap';

  @override
  String get registerErrorName => 'Lütfen adınızı girin.';

  @override
  String get registerErrorEmail => 'Geçerli bir e-posta adresi girin.';

  @override
  String get registerErrorPassword => 'Şifre en az 6 karakter olmalıdır.';

  @override
  String get registerErrorMatch => 'Şifreler uyuşmuyor.';

  @override
  String get registerErrorTerms => 'Lütfen kullanım koşullarını kabul edin.';

  @override
  String get registerErrorConflict => 'Bu email zaten kayıtlı';

  @override
  String get registerGenericError => 'Kayıt sırasında bir hata oluştu.';

  @override
  String get verifyTitle => 'E-posta Doğrulama';

  @override
  String verifyDesc(String email) {
    return '$email adresine bir doğrulama kodu gönderdik. Lütfen kodu aşağıya girin.';
  }

  @override
  String get verifyButton => 'Doğrula';

  @override
  String get verifyResend => 'Yeni Kod Gönder';

  @override
  String verifyWait(int seconds) {
    return '$seconds saniye bekleyin';
  }

  @override
  String get verifyErrorInvalid => 'Kod yanlış';

  @override
  String get verifySuccess => 'E-posta başarıyla doğrulandı';

  @override
  String get verifyGenericError => 'Doğrulama sırasında bir hata oluştu.';

  @override
  String get myExamsTitle => 'Sınavlarım';

  @override
  String get myExamsCreate => 'Yeni Sınav';

  @override
  String get myExamsEmpty => 'Henüz sınavın yok.';

  @override
  String get statusQueued => 'Sırada';

  @override
  String get statusGenerating => 'Hazırlanıyor';

  @override
  String get statusReady => 'Hazır';

  @override
  String get statusFailed => 'Hata';

  @override
  String examQuestionCount(int count) {
    return '$count Soru';
  }

  @override
  String get examLastScore => 'Son Skor: ';

  @override
  String get commonClose => 'Kapat';
}
