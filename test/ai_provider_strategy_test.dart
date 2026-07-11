import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:senseriduvarkagidi/core/di/providers.dart';
import 'package:senseriduvarkagidi/features/settings/domain/entities/app_settings.dart';

void main() {
  test('API anahtari varsa NVIDIA servisi secilir', () async {
    final container = ProviderContainer(
      overrides: [
        appSettingsProvider.overrideWith(
          (ref) async => const AppSettings(
            imageServerUrl: '',
            isMaintenanceMode: false,
            isRewardedAdEnabled: false,
            rewardedAdId: '',
            bannerAdId: '',
            isBannerAdEnabled: false,
            telegramLink: '',
            aiApiKey: 'nvapi-test-key',
            aiDailyLimit: 3,
            aiModel: 'black-forest-labs/flux.1-schnell',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appSettingsProvider.future);

    final service = container.read(aiImageServiceProvider);
    expect(service.serviceId, 'nvidia');
  });

  test('API anahtari yoksa bos servis secilir', () async {
    final container = ProviderContainer(
      overrides: [
        appSettingsProvider.overrideWith(
          (ref) async => const AppSettings(
            imageServerUrl: '',
            isMaintenanceMode: false,
            isRewardedAdEnabled: false,
            rewardedAdId: '',
            bannerAdId: '',
            isBannerAdEnabled: false,
            telegramLink: '',
            aiApiKey: '',
            aiDailyLimit: 3,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appSettingsProvider.future);

    final service = container.read(aiImageServiceProvider);
    expect(service.serviceId, 'none');
  });
}
