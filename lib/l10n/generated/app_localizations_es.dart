// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get navExplore => 'Explorar';

  @override
  String get navCategories => 'Categorías';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get premiumSection => 'Premium';

  @override
  String get themeSection => 'Apariencia';

  @override
  String get aboutSection => 'Acerca de';

  @override
  String get themeLight => 'Tema claro';

  @override
  String get themeDark => 'Tema oscuro';

  @override
  String get themeAmoled => 'AMOLED (Negro puro)';

  @override
  String themeActivated(String name) {
    return '$name activado';
  }

  @override
  String get appVersion => 'Versión de la app';

  @override
  String get proUserTitle => 'Usuario Pro';

  @override
  String get proUserSubtitle => 'Todas las funciones desbloqueadas';

  @override
  String get freePlanTitle => 'Plan gratuito';

  @override
  String dailyAiQuota(int remaining, int limit) {
    return '$remaining/$limit generaciones de IA al día';
  }

  @override
  String get upgradeToPro => 'Pasar a Pro';

  @override
  String get proTitle => '4K-HD Pro';

  @override
  String get paywallSubtitle => 'Desbloquea la generación de fondos con IA';

  @override
  String get featureNvidiaTitle => 'Generación con IA de NVIDIA';

  @override
  String get featureNvidiaDesc =>
      'Crea el fondo de pantalla de tus sueños en segundos con la IA de NVIDIA';

  @override
  String get featureStylesTitle => 'Todos los estilos artísticos';

  @override
  String get featureStylesDesc =>
      'Más de 10 estilos desbloqueados: realista, anime, cyberpunk, fantasía y más';

  @override
  String get featureAdFreeTitle => 'Experiencia sin anuncios';

  @override
  String get featureAdFreeDesc =>
      'Se eliminan los banners y todos los anuncios para un uso sin interrupciones';

  @override
  String get featureApplyTitle => 'Aplica con un toque';

  @override
  String get featureApplyDesc =>
      'Usa tu creación como fondo de inicio/bloqueo, descárgala o compártela';

  @override
  String get aiLockedNotice =>
      'La generación con IA está bloqueada. Desbloquéala con Pro.';

  @override
  String get monthlyPro => 'Pro mensual';

  @override
  String get monthlyProSubtitle => 'Cobro una vez al mes';

  @override
  String get yearlyPro => 'Pro anual';

  @override
  String get yearlyProSubtitle => 'Mejor valor: ahorra 40%';

  @override
  String get restorePurchase => 'Restaurar compra';

  @override
  String get subscriptionAutoRenew =>
      'La suscripción se renueva automáticamente. Cancela cuando quieras.';

  @override
  String get productsLoadError =>
      'No se pudieron cargar los productos. Comprueba tu conexión a Internet.';

  @override
  String get retry => 'Reintentar';

  @override
  String get purchaseInProgress => 'Compra en proceso...';

  @override
  String get upgradedToProMessage => '¡Pasaste a Pro! Gracias.';

  @override
  String get restoringPurchases => 'Restaurando compras...';
}
