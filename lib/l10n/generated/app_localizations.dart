import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('th'),
    Locale('tr'),
    Locale('zh')
  ];

  /// No description provided for @navExplore.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet'**
  String get navExplore;

  /// No description provided for @navCategories.
  ///
  /// In tr, this message translates to:
  /// **'Kategoriler'**
  String get navCategories;

  /// No description provided for @navFavorites.
  ///
  /// In tr, this message translates to:
  /// **'Favoriler'**
  String get navFavorites;

  /// No description provided for @navSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get navSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @premiumSection.
  ///
  /// In tr, this message translates to:
  /// **'Premium'**
  String get premiumSection;

  /// No description provided for @themeSection.
  ///
  /// In tr, this message translates to:
  /// **'Görsel Tema'**
  String get themeSection;

  /// No description provided for @aboutSection.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get aboutSection;

  /// No description provided for @themeLight.
  ///
  /// In tr, this message translates to:
  /// **'Açık Tema'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In tr, this message translates to:
  /// **'Koyu Tema'**
  String get themeDark;

  /// No description provided for @themeAmoled.
  ///
  /// In tr, this message translates to:
  /// **'AMOLED (Saf Siyah)'**
  String get themeAmoled;

  /// No description provided for @themeActivated.
  ///
  /// In tr, this message translates to:
  /// **'{name} aktif edildi'**
  String themeActivated(String name);

  /// No description provided for @appVersion.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama Sürümü'**
  String get appVersion;

  /// No description provided for @proUserTitle.
  ///
  /// In tr, this message translates to:
  /// **'Pro Kullanıcısı'**
  String get proUserTitle;

  /// No description provided for @proUserSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Tüm özellikler aktif'**
  String get proUserSubtitle;

  /// No description provided for @freePlanTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ücretsiz Plan'**
  String get freePlanTitle;

  /// No description provided for @dailyAiQuota.
  ///
  /// In tr, this message translates to:
  /// **'Günlük {remaining}/{limit} AI üretim hakkı'**
  String dailyAiQuota(int remaining, int limit);

  /// No description provided for @upgradeToPro.
  ///
  /// In tr, this message translates to:
  /// **'Pro\'ya Yüksel'**
  String get upgradeToPro;

  /// No description provided for @proTitle.
  ///
  /// In tr, this message translates to:
  /// **'4K-HD Pro'**
  String get proTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Yapay zeka ile duvar kağıdı üretmenin kilidini aç'**
  String get paywallSubtitle;

  /// No description provided for @featureNvidiaTitle.
  ///
  /// In tr, this message translates to:
  /// **'NVIDIA AI ile Üretim'**
  String get featureNvidiaTitle;

  /// No description provided for @featureNvidiaDesc.
  ///
  /// In tr, this message translates to:
  /// **'Hayalindeki duvar kağıdını NVIDIA yapay zekasıyla saniyeler içinde oluştur'**
  String get featureNvidiaDesc;

  /// No description provided for @featureStylesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Sanat Stilleri'**
  String get featureStylesTitle;

  /// No description provided for @featureStylesDesc.
  ///
  /// In tr, this message translates to:
  /// **'10+ stil açılır: gerçekçi, anime, siberpunk, fantastik ve daha fazlası'**
  String get featureStylesDesc;

  /// No description provided for @featureAdFreeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Reklamsız Deneyim'**
  String get featureAdFreeTitle;

  /// No description provided for @featureAdFreeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Banner ve tüm reklamlar kalkar, kesintisiz kullanırsın'**
  String get featureAdFreeDesc;

  /// No description provided for @featureApplyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tek Dokunuşla Uygula'**
  String get featureApplyTitle;

  /// No description provided for @featureApplyDesc.
  ///
  /// In tr, this message translates to:
  /// **'Ürettiğin görseli ana/kilit ekranına uygula, indir veya paylaş'**
  String get featureApplyDesc;

  /// No description provided for @aiLockedNotice.
  ///
  /// In tr, this message translates to:
  /// **'AI duvar kağıdı üretimi şu an kilitli. Pro ile hemen aç.'**
  String get aiLockedNotice;

  /// No description provided for @monthlyPro.
  ///
  /// In tr, this message translates to:
  /// **'Aylık Pro'**
  String get monthlyPro;

  /// No description provided for @monthlyProSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayda bir kez ödeme'**
  String get monthlyProSubtitle;

  /// No description provided for @yearlyPro.
  ///
  /// In tr, this message translates to:
  /// **'Yıllık Pro'**
  String get yearlyPro;

  /// No description provided for @yearlyProSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'En iyi değer - %40 tasarruf'**
  String get yearlyProSubtitle;

  /// No description provided for @restorePurchase.
  ///
  /// In tr, this message translates to:
  /// **'Satın Alımı Geri Yükle'**
  String get restorePurchase;

  /// No description provided for @subscriptionAutoRenew.
  ///
  /// In tr, this message translates to:
  /// **'Abonelik otomatik yenilenir. İstediğiniz zaman iptal edebilirsiniz.'**
  String get subscriptionAutoRenew;

  /// No description provided for @productsLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Ürünler yüklenemedi. Lütfen internet bağlantınızı kontrol edin.'**
  String get productsLoadError;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get retry;

  /// No description provided for @purchaseInProgress.
  ///
  /// In tr, this message translates to:
  /// **'Satın alma işlemi sürüyor...'**
  String get purchaseInProgress;

  /// No description provided for @upgradedToProMessage.
  ///
  /// In tr, this message translates to:
  /// **'Pro\'ya yükseltildiniz! Teşekkürler.'**
  String get upgradedToProMessage;

  /// No description provided for @restoringPurchases.
  ///
  /// In tr, this message translates to:
  /// **'Satın alımlar geri yükleniyor...'**
  String get restoringPurchases;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'de',
        'en',
        'es',
        'fr',
        'ja',
        'ko',
        'th',
        'tr',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
