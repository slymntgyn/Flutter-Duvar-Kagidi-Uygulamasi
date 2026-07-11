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

  test('free kullanici gunde 1 deneme hakki ile baslar', () {
    final status = PremiumStatus.free();

    expect(status.isPro, isFalse);
    expect(status.dailyAiLimit, 1);
    expect(status.remainingAiGenerations, 1);
    expect(status.canGenerate, isTrue);
  });

  test('free kullanici tek hakkini kullaninca uretemez', () {
    final status = PremiumStatus.free().copyWith(dailyAiUsed: 1);

    expect(status.canGenerate, isFalse);
    expect(status.remainingAiGenerations, 0);
  });
}
