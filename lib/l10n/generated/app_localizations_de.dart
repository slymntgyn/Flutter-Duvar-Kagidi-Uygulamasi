// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get navExplore => 'Entdecken';

  @override
  String get navCategories => 'Kategorien';

  @override
  String get navFavorites => 'Favoriten';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get premiumSection => 'Premium';

  @override
  String get themeSection => 'Darstellung';

  @override
  String get aboutSection => 'Über';

  @override
  String get themeLight => 'Helles Design';

  @override
  String get themeDark => 'Dunkles Design';

  @override
  String get themeAmoled => 'AMOLED (Reines Schwarz)';

  @override
  String themeActivated(String name) {
    return '$name aktiviert';
  }

  @override
  String get appVersion => 'App-Version';

  @override
  String get proUserTitle => 'Pro-Nutzer';

  @override
  String get proUserSubtitle => 'Alle Funktionen freigeschaltet';

  @override
  String get freePlanTitle => 'Kostenloser Plan';

  @override
  String dailyAiQuota(int remaining, int limit) {
    return '$remaining/$limit tägliche KI-Erstellungen';
  }

  @override
  String get upgradeToPro => 'Auf Pro upgraden';

  @override
  String get proTitle => '4K-HD Pro';

  @override
  String get paywallSubtitle => 'KI-Hintergrundbilderstellung freischalten';

  @override
  String get featureNvidiaTitle => 'KI-Erstellung mit NVIDIA';

  @override
  String get featureNvidiaDesc =>
      'Erstelle in Sekunden dein Traum-Hintergrundbild mit NVIDIA-KI';

  @override
  String get featureStylesTitle => 'Alle Kunststile';

  @override
  String get featureStylesDesc =>
      '10+ Stile freigeschaltet: realistisch, Anime, Cyberpunk, Fantasy und mehr';

  @override
  String get featureAdFreeTitle => 'Werbefreies Erlebnis';

  @override
  String get featureAdFreeDesc =>
      'Banner und alle Anzeigen werden entfernt für ununterbrochene Nutzung';

  @override
  String get featureApplyTitle => 'Mit einem Tipp anwenden';

  @override
  String get featureApplyDesc =>
      'Setze dein Bild als Start-/Sperrbildschirm, lade es herunter oder teile es';

  @override
  String get aiLockedNotice =>
      'Die KI-Erstellung ist derzeit gesperrt. Schalte sie mit Pro frei.';

  @override
  String get monthlyPro => 'Monatlich Pro';

  @override
  String get monthlyProSubtitle => 'Einmal monatlich abgerechnet';

  @override
  String get yearlyPro => 'Jährlich Pro';

  @override
  String get yearlyProSubtitle => 'Bester Wert - 40% sparen';

  @override
  String get restorePurchase => 'Kauf wiederherstellen';

  @override
  String get subscriptionAutoRenew =>
      'Das Abo verlängert sich automatisch. Jederzeit kündbar.';

  @override
  String get productsLoadError =>
      'Produkte konnten nicht geladen werden. Bitte prüfe deine Internetverbindung.';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get purchaseInProgress => 'Kauf wird verarbeitet...';

  @override
  String get upgradedToProMessage => 'Du hast auf Pro upgegradet! Danke.';

  @override
  String get restoringPurchases => 'Käufe werden wiederhergestellt...';
}
