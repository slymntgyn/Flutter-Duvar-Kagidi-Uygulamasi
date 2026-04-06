import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senseriduvarkagidi/core/di/providers.dart';
import 'package:senseriduvarkagidi/core/theme/app_theme.dart';
import 'package:senseriduvarkagidi/features/premium/domain/entities/premium_status.dart';
import 'package:senseriduvarkagidi/features/premium/presentation/providers/premium_provider.dart';
import 'package:senseriduvarkagidi/features/premium/presentation/screens/premium_paywall_screen.dart';

/// Uygulama ayarlari ekrani.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _applyTheme(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode mode,
    String label,
  ) {
    ref.read(themeProvider.notifier).setTheme(mode);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label aktif edildi'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentTheme = ref.watch(themeProvider);
    final premium = ref.watch(premiumProvider);
    final items = <Widget>[
      // ---- PREMIUM ----
      const _SectionHeader(title: 'Premium'),
      const SizedBox(height: 8),
      _PremiumCard(premium: premium),
      const SizedBox(height: 24),

      // ---- TEMA ----
      const _SectionHeader(title: 'Gorsel Tema'),
      const SizedBox(height: 8),
      _ThemeOptionTile(
        label: 'Acik Tema',
        icon: Icons.light_mode_rounded,
        isSelected: currentTheme == AppThemeMode.light,
        onTap: () => _applyTheme(context, ref, AppThemeMode.light, 'Acik tema'),
      ),
      const SizedBox(height: 8),
      _ThemeOptionTile(
        label: 'Koyu Tema',
        icon: Icons.dark_mode_rounded,
        isSelected: currentTheme == AppThemeMode.dark,
        onTap: () => _applyTheme(context, ref, AppThemeMode.dark, 'Koyu tema'),
      ),
      const SizedBox(height: 8),
      _ThemeOptionTile(
        label: 'AMOLED (Saf Siyah)',
        icon: Icons.phone_android_rounded,
        isSelected: currentTheme == AppThemeMode.amoled,
        onTap: () =>
            _applyTheme(context, ref, AppThemeMode.amoled, 'AMOLED tema'),
      ),
      const SizedBox(height: 24),

      // ---- HAKKINDA ----
      const _SectionHeader(title: 'Hakkinda'),
      const SizedBox(height: 8),
      ListTile(
        leading: const Icon(Icons.info_rounded),
        title: const Text('Uygulama Surumu'),
        subtitle: const Text('1.0.25'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      const SizedBox(height: 32),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) => items[index],
      ),
    );
  }
}

// ---- Yardimci Widgetler ----

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
    );
  }
}

// ---------------------------------------------------------------------------
// Premium Card
// ---------------------------------------------------------------------------

class _PremiumCard extends StatelessWidget {
  final PremiumStatus premium;
  const _PremiumCard({required this.premium});

  @override
  Widget build(BuildContext context) {
    if (premium.isPro) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pro Kullanicisi',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  Text(
                    'Tum ozellikler aktif',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 28),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ucretsiz Plan',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    Text(
                      'Gunluk ${premium.remainingAiGenerations}/${premium.dailyAiLimit} AI uretim hakki',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PremiumPaywallScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF764ba2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_upward_rounded, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Pro'ya Yuksel",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  color: theme.colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
