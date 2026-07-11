// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get navExplore => 'استكشاف';

  @override
  String get navCategories => 'الفئات';

  @override
  String get navFavorites => 'المفضلة';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get premiumSection => 'بريميوم';

  @override
  String get themeSection => 'المظهر';

  @override
  String get aboutSection => 'حول';

  @override
  String get themeLight => 'الوضع الفاتح';

  @override
  String get themeDark => 'الوضع الداكن';

  @override
  String get themeAmoled => 'AMOLED (أسود نقي)';

  @override
  String themeActivated(String name) {
    return 'تم تفعيل $name';
  }

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String get proUserTitle => 'مستخدم برو';

  @override
  String get proUserSubtitle => 'جميع الميزات مفعّلة';

  @override
  String get freePlanTitle => 'الخطة المجانية';

  @override
  String dailyAiQuota(int remaining, int limit) {
    return '$remaining/$limit إنشاءات بالذكاء الاصطناعي يوميًا';
  }

  @override
  String get upgradeToPro => 'الترقية إلى برو';

  @override
  String get proTitle => '4K-HD Pro';

  @override
  String get paywallSubtitle => 'افتح إنشاء الخلفيات بالذكاء الاصطناعي';

  @override
  String get featureNvidiaTitle => 'الإنشاء بذكاء NVIDIA';

  @override
  String get featureNvidiaDesc =>
      'أنشئ خلفية أحلامك في ثوانٍ باستخدام ذكاء NVIDIA الاصطناعي';

  @override
  String get featureStylesTitle => 'جميع الأنماط الفنية';

  @override
  String get featureStylesDesc =>
      'أكثر من 10 أنماط: واقعي، أنمي، سايبربانك، خيالي والمزيد';

  @override
  String get featureAdFreeTitle => 'تجربة بدون إعلانات';

  @override
  String get featureAdFreeDesc =>
      'تُزال البانرات وجميع الإعلانات لاستخدام دون انقطاع';

  @override
  String get featureApplyTitle => 'طبّق بلمسة واحدة';

  @override
  String get featureApplyDesc =>
      'اجعل صورتك خلفية للشاشة الرئيسية/القفل، حمّلها أو شاركها';

  @override
  String get aiLockedNotice =>
      'إنشاء الخلفيات بالذكاء الاصطناعي مقفل حاليًا. افتحه مع برو.';

  @override
  String get monthlyPro => 'برو شهري';

  @override
  String get monthlyProSubtitle => 'الدفع مرة كل شهر';

  @override
  String get yearlyPro => 'برو سنوي';

  @override
  String get yearlyProSubtitle => 'أفضل قيمة - وفّر 40%';

  @override
  String get restorePurchase => 'استعادة الشراء';

  @override
  String get subscriptionAutoRenew =>
      'يتجدد الاشتراك تلقائيًا. يمكنك الإلغاء في أي وقت.';

  @override
  String get productsLoadError =>
      'تعذّر تحميل المنتجات. يرجى التحقق من اتصالك بالإنترنت.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get purchaseInProgress => 'جارٍ إتمام الشراء...';

  @override
  String get upgradedToProMessage => 'لقد ترقّيت إلى برو! شكرًا لك.';

  @override
  String get restoringPurchases => 'جارٍ استعادة المشتريات...';
}
