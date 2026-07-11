// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get navExplore => '見つける';

  @override
  String get navCategories => 'カテゴリー';

  @override
  String get navFavorites => 'お気に入り';

  @override
  String get navSettings => '設定';

  @override
  String get settingsTitle => '設定';

  @override
  String get premiumSection => 'プレミアム';

  @override
  String get themeSection => '外観';

  @override
  String get aboutSection => 'アプリについて';

  @override
  String get themeLight => 'ライトテーマ';

  @override
  String get themeDark => 'ダークテーマ';

  @override
  String get themeAmoled => 'AMOLED（真の黒）';

  @override
  String themeActivated(String name) {
    return '$nameを有効にしました';
  }

  @override
  String get appVersion => 'アプリのバージョン';

  @override
  String get proUserTitle => 'Proユーザー';

  @override
  String get proUserSubtitle => 'すべての機能が利用可能';

  @override
  String get freePlanTitle => '無料プラン';

  @override
  String dailyAiQuota(int remaining, int limit) {
    return '1日のAI生成 $remaining/$limit';
  }

  @override
  String get upgradeToPro => 'Proにアップグレード';

  @override
  String get proTitle => '4K-HD Pro';

  @override
  String get paywallSubtitle => 'AI壁紙生成のロックを解除';

  @override
  String get featureNvidiaTitle => 'NVIDIAによるAI生成';

  @override
  String get featureNvidiaDesc => 'NVIDIAのAIで理想の壁紙を数秒で作成';

  @override
  String get featureStylesTitle => 'すべてのアートスタイル';

  @override
  String get featureStylesDesc => '10種類以上のスタイル：リアル、アニメ、サイバーパンク、ファンタジーなど';

  @override
  String get featureAdFreeTitle => '広告なしの体験';

  @override
  String get featureAdFreeDesc => 'バナーとすべての広告が削除され、快適に使えます';

  @override
  String get featureApplyTitle => 'ワンタップで適用';

  @override
  String get featureApplyDesc => '作成した画像をホーム／ロック画面に設定、ダウンロード、共有できます';

  @override
  String get aiLockedNotice => 'AI壁紙生成は現在ロックされています。Proで解除しましょう。';

  @override
  String get monthlyPro => '月額Pro';

  @override
  String get monthlyProSubtitle => '毎月1回のお支払い';

  @override
  String get yearlyPro => '年額Pro';

  @override
  String get yearlyProSubtitle => '最もお得 - 40%割引';

  @override
  String get restorePurchase => '購入を復元';

  @override
  String get subscriptionAutoRenew => 'サブスクは自動更新されます。いつでも解約できます。';

  @override
  String get productsLoadError => '商品を読み込めませんでした。インターネット接続を確認してください。';

  @override
  String get retry => '再試行';

  @override
  String get purchaseInProgress => '購入処理中...';

  @override
  String get upgradedToProMessage => 'Proにアップグレードしました！ありがとうございます。';

  @override
  String get restoringPurchases => '購入を復元しています...';
}
