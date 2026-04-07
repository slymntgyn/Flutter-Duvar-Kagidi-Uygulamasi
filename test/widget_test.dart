import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:senseriduvarkagidi/core/di/providers.dart';
import 'package:senseriduvarkagidi/core/theme/app_theme.dart';

void main() {
  test('Theme provider varsayilan degerle acilir', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(themeProvider), AppThemeMode.light);
  });
}

