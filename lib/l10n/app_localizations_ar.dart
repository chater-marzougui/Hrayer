// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get anUnexpectedErrorOccurred => 'حدث خطأ غير متوقع';

  @override
  String get applyChanges => 'تطبيق التغييرات';

  @override
  String get areYouSureYouWantToLogout => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get chooseAnImageSource => 'اختر مصدر الصورة';

  @override
  String get completeProfile => 'إكمال الملف الشخصي';

  @override
  String get completeYourProfile => 'أكمل ملفك الشخصي';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get contactInformation => 'معلومات الاتصال';

  @override
  String get contactSupport => 'الاتصال بالدعم';

  @override
  String get createAnAccount => 'إنشاء حساب';

  @override
  String currentSelectedThemeMode(Object mode) {
    return 'الحالي: $mode';
  }

  @override
  String get dartTemplate => 'قالب دارت';

  @override
  String get dontHaveAnAccountSignUp => 'ليس لديك حساب؟ سجل الآن';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get emailAddress => 'البريد الإلكتروني';

  @override
  String get enableNotifications => 'تفعيل الإشعارات';

  @override
  String get enterTheSubjectOfYourMessage => 'أدخل موضوع رسالتك';

  @override
  String get enterYourEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get enterYourEmailToRecoverYourPassword => 'أدخل بريدك الإلكتروني لاستعادة كلمة المرور';

  @override
  String get enterYourMessage => 'أدخل رسالتك';

  @override
  String get enterYourName => 'أدخل اسمك';

  @override
  String get enterYourPassword => 'أدخل كلمة المرور';

  @override
  String get errorOccurredDuringSignup => 'حدث خطأ أثناء التسجيل.';

  @override
  String errorOccurredWhileUploadingTheImage(Object e) {
    return 'حدث خطأ أثناء تحميل الصورة: $e';
  }

  @override
  String errorPostingComment(Object e) {
    return 'خطأ في نشر التعليق: $e';
  }

  @override
  String errorReauthenticatingUser(Object e) {
    return 'خطأ في إعادة مصادقة المستخدم: $e';
  }

  @override
  String errorSendingPasswordRecoveryEmail(Object e) {
    return 'خطأ في إرسال بريد استعادة كلمة المرور: $e';
  }

  @override
  String get errorSigningOut => 'خطأ في تسجيل الخروج';

  @override
  String get errorSubmittingSupportRequest => 'خطأ في إرسال طلب الدعم';

  @override
  String errorUpdatingPassword(Object e) {
    return 'خطأ في تحديث كلمة المرور: $e';
  }

  @override
  String errorUpdatingProfile(Object e) {
    return 'خطأ في تحديث الملف الشخصي: $e';
  }

  @override
  String errorSnapshotError(Object error) {
    return 'خطأ: $error';
  }

  @override
  String failedToCreateProfile(Object e) {
    return 'فشل في إنشاء الملف الشخصي: $e';
  }

  @override
  String get failedToUploadImage => 'فشل تحميل الصورة';

  @override
  String get firstName => 'الاسم';

  @override
  String get firstNameIsRequired => 'الاسم مطلوب';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get genderIsRequired => 'الجنس مطلوب';

  @override
  String get incorrectPassword => 'كلمة مرور غير صحيحة';

  @override
  String get invalidEmailAddress => 'عنوان بريد إلكتروني غير صالح';

  @override
  String get lastName => 'اللقب';

  @override
  String get lastNameIsRequired => 'اللقب مطلوب';

  @override
  String get loginFailed => 'فشل تسجيل الدخول';

  @override
  String loginFailedWithMessage(Object message) {
    return 'فشل تسجيل الدخول: $message';
  }

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get noAccountFoundWithThisEmail => 'لم يتم العثور على حساب بهذا البريد الإلكتروني';

  @override
  String get noCommentsYet => 'لا توجد تعليقات بعد';

  @override
  String get oldPassword => 'كلمة المرور القديمة';

  @override
  String get orContinueWith => 'أو المتابعة باستخدام';

  @override
  String get passwordRequirements => 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل وتحتوي على رقم';

  @override
  String get passwordUpdatedSuccessfully => 'تم تحديث كلمة المرور بنجاح';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get passwordsDoNotMatchExclamation => 'كلمات المرور غير متطابقة!';

  @override
  String get personalAccount => 'حساب شخصي';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get phoneNumberIsRequired => 'رقم الهاتف مطلوب';

  @override
  String get pleaseConfirmYourPassword => 'الرجاء تأكيد كلمة المرور';

  @override
  String pleaseEnterLabel(Object label) {
    return 'الرجاء إدخال $label';
  }

  @override
  String get pleaseEnterAPassword => 'الرجاء إدخال كلمة مرور';

  @override
  String get pleaseEnterAValidEmailAddress => 'الرجاء إدخال عنوان بريد إلكتروني صالح';

  @override
  String get pleaseEnterAValidPhoneNumber => 'الرجاء إدخال رقم هاتف صالح';

  @override
  String get pleaseEnterYourEmail => 'الرجاء إدخال بريدك الإلكتروني';

  @override
  String get pleaseEnterYourFirstName => 'الرجاء إدخال اسمك الأول';

  @override
  String get pleaseEnterYourLastName => 'الرجاء إدخال اسمك الأخير';

  @override
  String get pleaseFillInAllFields => 'الرجاء ملء جميع الحقول';

  @override
  String get pleaseSelectYourBirthdate => 'الرجاء تحديد تاريخ ميلادك';

  @override
  String get pleaseSelectYourGender => 'الرجاء تحديد جنسك';

  @override
  String get postedBy => 'نشر بواسطة';

  @override
  String get profileUpdatedSuccessfully => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get randomText => 'نص عشوائي';

  @override
  String get recoverPassword => 'استعادة كلمة المرور';

  @override
  String get selectYourBirthdate => 'حدد تاريخ ميلادك';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signInToContinueYourJourney => 'سجل الدخول لمتابعة رحلتك';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get signingIn => 'جارٍ تسجيل الدخول...';

  @override
  String get submitRequest => 'إرسال الطلب';

  @override
  String get supportRequestSubmittedSuccessfully => 'تم إرسال طلب الدعم بنجاح';

  @override
  String get tapAgainToExit => 'انقر مرة أخرى للخروج';

  @override
  String get textOnButton => 'نص على الزر';

  @override
  String get themeMode => 'وضع السمة';

  @override
  String get thisAccountHasBeenDisabled => 'تم تعطيل هذا الحساب';

  @override
  String get thisPageIsAPlaceHolder => 'هذه الصفحة هي عنصر نائب';

  @override
  String get tooManyFailedAttempts => 'محاولات فاشلة كثيرة. يرجى المحاولة مرة أخرى لاحقًا';

  @override
  String get typeYourOldPasswordAndTheNewOneToApplyChanges => 'اكتب كلمة مرورك القديمة والجديدة لتطبيق التغييرات';

  @override
  String get typeYourPasswordToApplyChanges => 'اكتب كلمة مرورك لتطبيق التغييرات';

  @override
  String get unknownUser => 'مستخدم غير معروف';

  @override
  String get userNotLoggedIn => 'المستخدم لم يسجل دخوله';

  @override
  String get weNeedAFewMoreDetails => 'نحتاج إلى بعض التفاصيل الإضافية لتبدأ';

  @override
  String get welcomeBack => 'مرحباً بعودتك!';

  @override
  String get wouldYouLikeToTakeAPictureOrChooseFromGallery => 'هل ترغب في التقاط صورة أو الاختيار من المعرض؟';

  @override
  String get writeAComment => 'اكتب تعليقًا...';

  @override
  String get wrongPassword => 'كلمة مرور خاطئة';

  @override
  String get youCanInteractWithMeInMultipleWays => 'يمكنك التفاعل معي بعدة طرق:';

  @override
  String get hiThereImBBot => '👋 مرحبًا! أنا بي-بوت';
}
