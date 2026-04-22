import 'package:flutter/material.dart';

/// Bilingual (Arabic / English) string provider.
///
/// Defaults to Arabic (RTL). Switch locale via [LocaleCubit.toggleLocale].
/// Add new keys by appending a getter that calls [_t].
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isArabic => locale.languageCode == 'ar';

  String _t(String ar, String en) => isArabic ? ar : en;

  // ── App ─────────────────────────────────────────────────────────────────
  String get appName => _t('فاني', 'Fanny');
  String get appTagline => _t('خدمات المنزل في متناول يدك', 'Home services at your fingertips');

  // ── Auth ─────────────────────────────────────────────────────────────────
  String get login => _t('تسجيل الدخول', 'Login');
  String get register => _t('إنشاء حساب', 'Register');
  String get email => _t('البريد الإلكتروني', 'Email');
  String get password => _t('كلمة المرور', 'Password');
  String get confirmPassword => _t('تأكيد كلمة المرور', 'Confirm Password');
  String get fullName => _t('الاسم الكامل', 'Full Name');
  String get phone => _t('رقم الهاتف', 'Phone Number');
  String get selectRole => _t('اختر دورك', 'Select Your Role');
  String get customer => _t('عميل', 'Customer');
  String get technician => _t('فني', 'Technician');
  String get admin => _t('مشرف', 'Admin');
  String get specialty => _t('التخصص', 'Specialty');
  String get dontHaveAccount => _t('ليس لديك حساب؟', "Don't have an account?");
  String get alreadyHaveAccount => _t('لديك حساب بالفعل؟', 'Already have an account?');
  String get loginNow => _t('سجل دخولك', 'Login');
  String get registerNow => _t('أنشئ حساباً', 'Register');
  String get logout => _t('تسجيل الخروج', 'Logout');
  String get loginFailed => _t('فشل تسجيل الدخول. تحقق من بياناتك وحاول مرة أخرى.', 'Login failed. Check your credentials and try again.');
  String get welcomeBack => _t('مرحباً بك مجدداً', 'Welcome Back!');
  String get loginSubtitle => _t('سجل دخولك برقم موبايلك لبدء', 'Enter your mobile number to get started');
  String get registerSubtitle => _t('أنشئ حسابك الآن وابدأ رحلتك', 'Create your account and start your journey');
  String get phoneHint => _t('XXXXXXXXXX', 'XXXXXXXXXX');
  String get otpLabel => _t('كود التحقق (OTP)', 'OTP Code');
  String get otpHint => _t('سيصلك كود التحقق في رسالة SMS', 'You will receive a verification code via SMS');
  String get sendOtp => _t('إرسال الكود', 'Send Code');
  String get createNewAccount => _t('إنشاء حساب جديد', 'Create New Account');
  String get orLoginWith => _t('أو تسجيل الدخول بواسطة', 'Or login with');
  String get orRegisterWith => _t('أو إنشاء حساب بواسطة', 'Or register with');
  String get termsNotice => _t('باستمرارك أنت توافق على شروط الخدمة وسياسة الخصوصية', 'By continuing you agree to our Terms of Service and Privacy Policy');

  // ── Navigation ────────────────────────────────────────────────────────────
  String get home => _t('الرئيسية', 'Home');
  String get requests => _t('طلباتي', 'My Requests');
  String get profile => _t('الملف الشخصي', 'Profile');
  String get dashboard => _t('لوحة التحكم', 'Dashboard');
  String get availableJobs => _t('الوظائف المتاحة', 'Available Jobs');

  // ── Home ─────────────────────────────────────────────────────────────────
  String get hello => _t('مرحباً، ', 'Hello, ');
  String get whatDoYouNeed => _t('ماذا تحتاج اليوم؟', 'What do you need today?');
  String get searchHint => _t('ابحث عن خدمة...', 'Search for a service...');
  String get categories => _t('الفئات', 'Categories');
  String get recentRequests => _t('الطلبات الأخيرة', 'Recent Requests');
  String get seeAll => _t('عرض الكل', 'See All');
  String get noRequestsYet => _t('لا توجد طلبات بعد', 'No requests yet');
  String get createFirstRequest => _t('أنشئ طلبك الأول الآن', 'Create your first request now');

  // ── Service Categories ────────────────────────────────────────────────────
  String get plumbing => _t('سباكة', 'Plumbing');
  String get electrical => _t('كهرباء', 'Electrical');
  String get carpentry => _t('نجارة', 'Carpentry');
  String get painting => _t('دهانات', 'Painting');
  String get acRepair => _t('تكييف', 'AC Repair');
  String get cleaning => _t('تنظيف', 'Cleaning');
  String get generalRepair => _t('إصلاح عام', 'General Repair');
  String get masonry => _t('بناء', 'Masonry');

  // ── Requests ──────────────────────────────────────────────────────────────
  String get createRequest => _t('إنشاء طلب', 'Create Request');
  String get requestTitle => _t('عنوان الطلب', 'Request Title');
  String get description => _t('الوصف', 'Description');
  String get location => _t('الموقع', 'Location');
  String get photos => _t('الصور', 'Photos');
  String get addPhoto => _t('إضافة صورة', 'Add Photo');
  String get category => _t('الفئة', 'Category');
  String get selectCategory => _t('اختر الفئة', 'Select Category');
  String get budget => _t('الميزانية المتوقعة (اختياري)', 'Expected Budget (optional)');
  String get egp => _t('ج.م', 'EGP');
  String get next => _t('التالي', 'Next');
  String get prev => _t('السابق', 'Previous');
  String get submitRequest => _t('إرسال الطلب', 'Submit Request');
  String get requestSent => _t('تم إرسال طلبك!', 'Request Sent!');
  String get requestSentDesc => _t(
    'سيتلقى الفنيون القريبون طلبك ويرسلون عروضهم قريباً',
    'Nearby technicians will receive your request and send their offers shortly',
  );
  String get all => _t('الكل', 'All');
  String get pending => _t('قيد الانتظار', 'Pending');
  String get inProgress => _t('جاري التنفيذ', 'In Progress');
  String get completed => _t('مكتمل', 'Completed');
  String get cancelled => _t('ملغي', 'Cancelled');
  String get viewOffers => _t('عرض العروض', 'View Offers');
  String get offersCount => _t('عروض', 'offers');
  String get step1Category => _t('اختر الفئة', 'Choose Category');
  String get step2Details => _t('التفاصيل', 'Details');
  String get step3Location => _t('الموقع والميزانية', 'Location & Budget');

  // ── Offers ────────────────────────────────────────────────────────────────
  String get offers => _t('العروض', 'Offers');
  String get offersFor => _t('عروض لـ', 'Offers for');
  String get price => _t('السعر', 'Price');
  String get estimatedTime => _t('الوقت المقدر', 'Estimated Time');
  String get accept => _t('قبول العرض', 'Accept Offer');
  String get accepted => _t('تم القبول ✓', 'Accepted ✓');
  String get note => _t('ملاحظة', 'Note');
  String get noOffers => _t('لا توجد عروض بعد', 'No offers yet');
  String get noOffersDesc => _t(
    'سيرى الفنيون القريبون طلبك ويتواصلون معك قريباً',
    'Nearby technicians will see your request and reach out soon',
  );

  // ── Technician ────────────────────────────────────────────────────────────
  String get technicianDashboard => _t('لوحة تحكم الفني', 'Technician Dashboard');
  String get availableRequests => _t('الطلبات المتاحة', 'Available Requests');
  String get myActiveJobs => _t('وظائفي النشطة', 'My Active Jobs');
  String get submitOffer => _t('تقديم عرض', 'Submit Offer');
  String get yourPrice => _t('سعرك (ج.م)', 'Your Price (EGP)');
  String get estimatedDuration => _t('المدة المقدرة', 'Estimated Duration');
  String get additionalNotes => _t('ملاحظات إضافية', 'Additional Notes');
  String get sendOffer => _t('إرسال العرض', 'Send Offer');
  String get totalJobs => _t('إجمالي الوظائف', 'Total Jobs');
  String get completedJobs => _t('مكتملة', 'Completed');
  String get earnings => _t('الأرباح', 'Earnings');
  String get rating => _t('التقييم', 'Rating');
  String get offerSent => _t('تم إرسال عرضك!', 'Offer sent!');
  String get hrs => _t('ساعة', 'hrs');

  // ── Admin ─────────────────────────────────────────────────────────────────
  String get adminDashboard => _t('لوحة تحكم المشرف', 'Admin Dashboard');
  String get totalUsers => _t('المستخدمون', 'Total Users');
  String get totalRequests => _t('الطلبات', 'Total Requests');
  String get totalTechnicians => _t('الفنيون', 'Technicians');
  String get revenueThisMonth => _t('إيرادات الشهر', "This Month's Revenue");
  String get recentActivity => _t('النشاط الأخير', 'Recent Activity');
  String get users => _t('المستخدمون', 'Users');
  String get allRequests => _t('جميع الطلبات', 'All Requests');

  // ── Profile ───────────────────────────────────────────────────────────────
  String get editProfile => _t('تعديل الملف', 'Edit Profile');
  String get language => _t('اللغة', 'Language');
  String get arabic => _t('العربية 🇪🇬', 'Arabic 🇪🇬');
  String get english => _t('English 🇬🇧', 'English 🇬🇧');
  String get notifications => _t('الإشعارات', 'Notifications');
  String get settings => _t('الإعدادات', 'Settings');
  String get help => _t('المساعدة والدعم', 'Help & Support');
  String get about => _t('حول التطبيق', 'About App');
  String get version => _t('الإصدار', 'Version');

  // ── General ───────────────────────────────────────────────────────────────
  String get save => _t('حفظ', 'Save');
  String get cancel => _t('إلغاء', 'Cancel');
  String get confirm => _t('تأكيد', 'Confirm');
  String get delete => _t('حذف', 'Delete');
  String get edit => _t('تعديل', 'Edit');
  String get loading => _t('جاري التحميل...', 'Loading...');
  String get errorOccurred => _t('حدث خطأ', 'An error occurred');
  String get retry => _t('إعادة المحاولة', 'Retry');
  String get success => _t('تم بنجاح!', 'Success!');
  String get noData => _t('لا توجد بيانات', 'No data available');
  String get by => _t('بواسطة', 'by');
  String get justNow => _t('الآن', 'Just now');
  String get ago => _t('منذ', 'ago');
  String get minutes => _t('دقائق', 'min');
  String get hours => _t('ساعات', 'hrs');
  String get days => _t('أيام', 'days');

  // ── Validation ─────────────────────────────────────────────────────────
  String get fieldRequired => _t('هذا الحقل مطلوب', 'This field is required');
  String get invalidEmail => _t('البريد الإلكتروني غير صحيح', 'Invalid email address');
  String get passwordTooShort => _t('كلمة المرور قصيرة جداً (6 أحرف على الأقل)', 'Password too short (min 6 chars)');
  String get passwordsNotMatch => _t('كلمتا المرور غير متطابقتين', 'Passwords do not match');
  String get invalidPhone => _t('رقم الهاتف غير صحيح', 'Invalid phone number');
  String get titleTooShort => _t('العنوان قصير جداً', 'Title is too short');
  String get descriptionTooShort => _t('الوصف قصير جداً', 'Description is too short');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
