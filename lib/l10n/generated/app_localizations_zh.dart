// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get navExplore => '发现';

  @override
  String get navCategories => '分类';

  @override
  String get navFavorites => '收藏';

  @override
  String get navSettings => '设置';

  @override
  String get settingsTitle => '设置';

  @override
  String get premiumSection => '高级会员';

  @override
  String get themeSection => '外观';

  @override
  String get aboutSection => '关于';

  @override
  String get themeLight => '浅色主题';

  @override
  String get themeDark => '深色主题';

  @override
  String get themeAmoled => 'AMOLED（纯黑）';

  @override
  String themeActivated(String name) {
    return '已启用$name';
  }

  @override
  String get appVersion => '应用版本';

  @override
  String get proUserTitle => 'Pro 用户';

  @override
  String get proUserSubtitle => '已解锁全部功能';

  @override
  String get freePlanTitle => '免费方案';

  @override
  String dailyAiQuota(int remaining, int limit) {
    return '每日 AI 生成 $remaining/$limit';
  }

  @override
  String get upgradeToPro => '升级到 Pro';

  @override
  String get proTitle => '4K-HD Pro';

  @override
  String get paywallSubtitle => '解锁 AI 壁纸生成';

  @override
  String get featureNvidiaTitle => '由 NVIDIA 驱动的 AI 生成';

  @override
  String get featureNvidiaDesc => '用 NVIDIA AI 数秒生成你梦想中的壁纸';

  @override
  String get featureStylesTitle => '全部艺术风格';

  @override
  String get featureStylesDesc => '解锁 10+ 种风格：写实、动漫、赛博朋克、奇幻等';

  @override
  String get featureAdFreeTitle => '无广告体验';

  @override
  String get featureAdFreeDesc => '移除横幅和所有广告，畅享不间断使用';

  @override
  String get featureApplyTitle => '一键应用';

  @override
  String get featureApplyDesc => '将作品设为主屏/锁屏壁纸，下载或分享';

  @override
  String get aiLockedNotice => 'AI 壁纸生成当前已锁定。升级 Pro 立即解锁。';

  @override
  String get monthlyPro => '包月 Pro';

  @override
  String get monthlyProSubtitle => '每月扣费一次';

  @override
  String get yearlyPro => '包年 Pro';

  @override
  String get yearlyProSubtitle => '超值之选 - 省 40%';

  @override
  String get restorePurchase => '恢复购买';

  @override
  String get subscriptionAutoRenew => '订阅将自动续费，可随时取消。';

  @override
  String get productsLoadError => '无法加载商品，请检查网络连接。';

  @override
  String get retry => '重试';

  @override
  String get purchaseInProgress => '购买处理中...';

  @override
  String get upgradedToProMessage => '您已升级到 Pro！谢谢。';

  @override
  String get restoringPurchases => '正在恢复购买...';
}
