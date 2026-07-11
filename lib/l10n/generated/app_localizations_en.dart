// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navExplore => 'Explore';

  @override
  String get navCategories => 'Categories';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get premiumSection => 'Premium';

  @override
  String get themeSection => 'Appearance';

  @override
  String get aboutSection => 'About';

  @override
  String get themeLight => 'Light Theme';

  @override
  String get themeDark => 'Dark Theme';

  @override
  String get themeAmoled => 'AMOLED (Pure Black)';

  @override
  String themeActivated(String name) {
    return '$name enabled';
  }

  @override
  String get appVersion => 'App Version';

  @override
  String get proUserTitle => 'Pro User';

  @override
  String get proUserSubtitle => 'All features unlocked';

  @override
  String get freePlanTitle => 'Free Plan';

  @override
  String dailyAiQuota(int remaining, int limit) {
    return '$remaining/$limit daily AI generations';
  }

  @override
  String get upgradeToPro => 'Upgrade to Pro';

  @override
  String get proTitle => '4K-HD Pro';

  @override
  String get paywallSubtitle => 'Unlock AI wallpaper generation';

  @override
  String get featureNvidiaTitle => 'AI Generation with NVIDIA';

  @override
  String get featureNvidiaDesc =>
      'Create the wallpaper of your dreams in seconds with NVIDIA AI';

  @override
  String get featureStylesTitle => 'All Art Styles';

  @override
  String get featureStylesDesc =>
      '10+ styles unlocked: realistic, anime, cyberpunk, fantasy and more';

  @override
  String get featureAdFreeTitle => 'Ad-Free Experience';

  @override
  String get featureAdFreeDesc =>
      'Banners and all ads are removed for uninterrupted use';

  @override
  String get featureApplyTitle => 'Apply in One Tap';

  @override
  String get featureApplyDesc =>
      'Set your creation as home/lock wallpaper, download or share it';

  @override
  String get aiLockedNotice =>
      'AI wallpaper generation is currently locked. Unlock it with Pro.';

  @override
  String get monthlyPro => 'Monthly Pro';

  @override
  String get monthlyProSubtitle => 'Billed once a month';

  @override
  String get yearlyPro => 'Yearly Pro';

  @override
  String get yearlyProSubtitle => 'Best value - save 40%';

  @override
  String get restorePurchase => 'Restore Purchase';

  @override
  String get subscriptionAutoRenew =>
      'Subscription renews automatically. Cancel anytime.';

  @override
  String get productsLoadError =>
      'Could not load products. Please check your internet connection.';

  @override
  String get retry => 'Try Again';

  @override
  String get purchaseInProgress => 'Purchase in progress...';

  @override
  String get upgradedToProMessage => 'You\'ve upgraded to Pro! Thank you.';

  @override
  String get restoringPurchases => 'Restoring purchases...';
}
