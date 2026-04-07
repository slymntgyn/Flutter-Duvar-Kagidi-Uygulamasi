/// Kullanicinin premium durumunu temsil eden entity.
enum PremiumTier {
  free,
  pro,
}

class PremiumStatus {
  final PremiumTier tier;
  final int dailyAiLimit;
  final int dailyAiUsed;
  final bool canUseProStyles;
  final bool adFree;

  const PremiumStatus({
    this.tier = PremiumTier.free,
    this.dailyAiLimit = 3,
    this.dailyAiUsed = 0,
    this.canUseProStyles = false,
    this.adFree = false,
  });

  bool get isPro => tier == PremiumTier.pro;
  int get remainingAiGenerations => (dailyAiLimit - dailyAiUsed).clamp(0, dailyAiLimit);
  bool get canGenerate => remainingAiGenerations > 0;

  PremiumStatus copyWith({
    PremiumTier? tier,
    int? dailyAiLimit,
    int? dailyAiUsed,
    bool? canUseProStyles,
    bool? adFree,
  }) {
    return PremiumStatus(
      tier: tier ?? this.tier,
      dailyAiLimit: dailyAiLimit ?? this.dailyAiLimit,
      dailyAiUsed: dailyAiUsed ?? this.dailyAiUsed,
      canUseProStyles: canUseProStyles ?? this.canUseProStyles,
      adFree: adFree ?? this.adFree,
    );
  }

  /// Free kullanici icin fabrika.
  factory PremiumStatus.free({int dailyLimit = 3}) {
    return PremiumStatus(
      tier: PremiumTier.free,
      dailyAiLimit: dailyLimit,
      canUseProStyles: false,
      adFree: false,
    );
  }

  /// Pro kullanici icin fabrika.
  factory PremiumStatus.pro() {
    return const PremiumStatus(
      tier: PremiumTier.pro,
      dailyAiLimit: 999,
      canUseProStyles: true,
      adFree: true,
    );
  }
}

