import 'package:flutter_test/flutter_test.dart';

import 'package:senseriduvarkagidi/features/premium/domain/entities/premium_status.dart';

void main() {
  test('pro kullanici 3 gunluk hak ile baslar', () {
    final status = PremiumStatus.pro();

    expect(status.isPro, isTrue);
    expect(status.dailyAiLimit, 3);
    expect(status.dailyAiUsed, 0);
    expect(status.remainingAiGenerations, 3);
  });

  test('free kullanici limit 0 iken uretim yapamaz', () {
    const status = PremiumStatus(
      tier: PremiumTier.free,
      dailyAiLimit: 0,
      dailyAiUsed: 0,
      canUseProStyles: false,
      adFree: false,
    );

    expect(status.isPro, isFalse);
    expect(status.canGenerate, isFalse);
    expect(status.remainingAiGenerations, 0);
  });
}
