// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get navExplore => '둘러보기';

  @override
  String get navCategories => '카테고리';

  @override
  String get navFavorites => '즐겨찾기';

  @override
  String get navSettings => '설정';

  @override
  String get settingsTitle => '설정';

  @override
  String get premiumSection => '프리미엄';

  @override
  String get themeSection => '화면 테마';

  @override
  String get aboutSection => '정보';

  @override
  String get themeLight => '밝은 테마';

  @override
  String get themeDark => '어두운 테마';

  @override
  String get themeAmoled => 'AMOLED (완전 검정)';

  @override
  String themeActivated(String name) {
    return '$name 적용됨';
  }

  @override
  String get appVersion => '앱 버전';

  @override
  String get proUserTitle => 'Pro 사용자';

  @override
  String get proUserSubtitle => '모든 기능 사용 가능';

  @override
  String get freePlanTitle => '무료 플랜';

  @override
  String dailyAiQuota(int remaining, int limit) {
    return '하루 AI 생성 $remaining/$limit';
  }

  @override
  String get upgradeToPro => 'Pro로 업그레이드';

  @override
  String get proTitle => '4K-HD Pro';

  @override
  String get paywallSubtitle => 'AI 배경화면 생성 잠금 해제';

  @override
  String get featureNvidiaTitle => 'NVIDIA로 AI 생성';

  @override
  String get featureNvidiaDesc => 'NVIDIA AI로 원하는 배경화면을 몇 초 만에 만드세요';

  @override
  String get featureStylesTitle => '모든 아트 스타일';

  @override
  String get featureStylesDesc => '10가지 이상 스타일: 사실적, 애니메, 사이버펑크, 판타지 등';

  @override
  String get featureAdFreeTitle => '광고 없는 경험';

  @override
  String get featureAdFreeDesc => '배너와 모든 광고가 제거되어 끊김 없이 사용할 수 있습니다';

  @override
  String get featureApplyTitle => '한 번에 적용';

  @override
  String get featureApplyDesc => '만든 이미지를 홈/잠금 화면으로 설정하거나 다운로드·공유하세요';

  @override
  String get aiLockedNotice => 'AI 배경화면 생성이 현재 잠겨 있습니다. Pro로 잠금을 해제하세요.';

  @override
  String get monthlyPro => '월간 Pro';

  @override
  String get monthlyProSubtitle => '매월 1회 결제';

  @override
  String get yearlyPro => '연간 Pro';

  @override
  String get yearlyProSubtitle => '최고의 가치 - 40% 절약';

  @override
  String get restorePurchase => '구매 복원';

  @override
  String get subscriptionAutoRenew => '구독은 자동으로 갱신됩니다. 언제든지 취소할 수 있습니다.';

  @override
  String get productsLoadError => '상품을 불러오지 못했습니다. 인터넷 연결을 확인하세요.';

  @override
  String get retry => '다시 시도';

  @override
  String get purchaseInProgress => '구매 진행 중...';

  @override
  String get upgradedToProMessage => 'Pro로 업그레이드되었습니다! 감사합니다.';

  @override
  String get restoringPurchases => '구매 복원 중...';
}
