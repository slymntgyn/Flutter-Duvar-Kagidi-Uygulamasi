import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:senseriduvarkagidi/core/di/providers.dart';
import 'package:senseriduvarkagidi/features/settings/domain/entities/app_settings.dart';

void main() {
  test('AI_PROVIDER=openrouter ise OpenRouter servisi secilir', () async {
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
            aiApiKey: 'test-key',
            aiDailyLimit: 3,
            aiModel: 'openai/gpt-image-1',
            aiProvider: 'openrouter',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appSettingsProvider.future);

    final service = container.read(aiImageServiceProvider);
    expect(service.serviceId, 'openrouter');
  });

  test('AI_PROVIDER=openai ise OpenAI servisi secilir', () async {
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
            aiApiKey: 'test-key',
            aiDailyLimit: 3,
            aiModel: 'gpt-image-1',
            aiProvider: 'openai',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(appSettingsProvider.future);

    final service = container.read(aiImageServiceProvider);
    expect(service.serviceId, 'openai');
  });
}
