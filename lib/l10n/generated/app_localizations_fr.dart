// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navExplore => 'Explorer';

  @override
  String get navCategories => 'Catégories';

  @override
  String get navFavorites => 'Favoris';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get premiumSection => 'Premium';

  @override
  String get themeSection => 'Apparence';

  @override
  String get aboutSection => 'À propos';

  @override
  String get themeLight => 'Thème clair';

  @override
  String get themeDark => 'Thème sombre';

  @override
  String get themeAmoled => 'AMOLED (Noir pur)';

  @override
  String themeActivated(String name) {
    return '$name activé';
  }

  @override
  String get appVersion => 'Version de l\'application';

  @override
  String get proUserTitle => 'Utilisateur Pro';

  @override
  String get proUserSubtitle => 'Toutes les fonctionnalités débloquées';

  @override
  String get freePlanTitle => 'Forfait gratuit';

  @override
  String dailyAiQuota(int remaining, int limit) {
    return '$remaining/$limit générations IA par jour';
  }

  @override
  String get upgradeToPro => 'Passer à Pro';

  @override
  String get proTitle => '4K-HD Pro';

  @override
  String get paywallSubtitle =>
      'Débloquez la génération de fonds d\'écran par IA';

  @override
  String get featureNvidiaTitle => 'Génération IA avec NVIDIA';

  @override
  String get featureNvidiaDesc =>
      'Créez le fond d\'écran de vos rêves en quelques secondes avec l\'IA NVIDIA';

  @override
  String get featureStylesTitle => 'Tous les styles artistiques';

  @override
  String get featureStylesDesc =>
      'Plus de 10 styles débloqués : réaliste, anime, cyberpunk, fantastique et plus';

  @override
  String get featureAdFreeTitle => 'Expérience sans publicité';

  @override
  String get featureAdFreeDesc =>
      'Les bannières et toutes les publicités sont supprimées pour une utilisation ininterrompue';

  @override
  String get featureApplyTitle => 'Appliquer en un geste';

  @override
  String get featureApplyDesc =>
      'Définissez votre création comme fond d\'écran d\'accueil/verrouillage, téléchargez ou partagez';

  @override
  String get aiLockedNotice =>
      'La génération IA est actuellement verrouillée. Débloquez-la avec Pro.';

  @override
  String get monthlyPro => 'Pro mensuel';

  @override
  String get monthlyProSubtitle => 'Facturé une fois par mois';

  @override
  String get yearlyPro => 'Pro annuel';

  @override
  String get yearlyProSubtitle => 'Meilleure offre - 40% d\'économie';

  @override
  String get restorePurchase => 'Restaurer l\'achat';

  @override
  String get subscriptionAutoRenew =>
      'L\'abonnement se renouvelle automatiquement. Annulez à tout moment.';

  @override
  String get productsLoadError =>
      'Impossible de charger les produits. Veuillez vérifier votre connexion Internet.';

  @override
  String get retry => 'Réessayer';

  @override
  String get purchaseInProgress => 'Achat en cours...';

  @override
  String get upgradedToProMessage => 'Vous êtes passé à Pro ! Merci.';

  @override
  String get restoringPurchases => 'Restauration des achats...';
}
