import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senseriduvarkagidi/features/premium/presentation/providers/premium_provider.dart';
import 'package:senseriduvarkagidi/features/purchase/presentation/providers/purchase_provider.dart';

/// Premium paywall ekrani.
class PremiumPaywallScreen extends ConsumerStatefulWidget {
  const PremiumPaywallScreen({super.key});

  @override
  ConsumerState<PremiumPaywallScreen> createState() =>
      _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends ConsumerState<PremiumPaywallScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(purchaseProvider.notifier).loadProducts());
  }

  @override
  Widget build(BuildContext context) {
    final premium = ref.watch(premiumProvider);
    final purchase = ref.watch(purchaseProvider);
    final theme = Theme.of(context);

    ref.listen(purchaseProvider, (prev, next) {
      if (!mounted) return;
      if (next.purchaseSuccess && prev?.purchaseSuccess == false) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pro'ya yukseltildiniz! Tesekkurler."),
            backgroundColor: Colors.green,
          ),
        );
      }
      if (next.errorMessage != null && prev?.errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: purchase.isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.amber.shade400, Colors.orange.shade600],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '4K-HD Pro',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sinirlamalari kaldir, tam potansiyeli ac',
                      style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 32),
                    _buildFeatureCard(
                      context,
                      icon: Icons.all_inclusive_rounded,
                      title: 'Sinirsiz AI Uretim',
                      description: 'Gunluk limit olmadan istediginiz kadar duvar kagidi uretin',
                      iconColor: Colors.purpleAccent,
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      context,
                      icon: Icons.palette_rounded,
                      title: 'Pro Stil Presetleri',
                      description: 'Ozel stil secenekleriyle benzersiz tasarimlar olusturun',
                      iconColor: Colors.tealAccent,
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      context,
                      icon: Icons.block_rounded,
                      title: 'Reklamsiz Deneyim',
                      description: 'Tum rewardedAdlar kaldirilir, kesintisiz kullanim',
                      iconColor: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      context,
                      icon: Icons.hd_rounded,
                      title: 'Yuksek Cozunurluk',
                      description: '4K cozunurlukte AI ile olusturulmus duvar kagitlari',
                      iconColor: Colors.blueAccent,
                    ),
                    const SizedBox(height: 32),
                    if (!premium.isPro)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Bugun ${premium.remainingAiGenerations} AI uretim hakkiniz kaldi',
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    if (purchase.isLoading)
                      const CircularProgressIndicator(color: Colors.amber)
                    else if (!purchase.productsLoaded)
                      _buildFallbackButton(context, theme)
                    else ...[
                      if (purchase.proMonthly != null)
                        _buildPurchaseButton(
                          context,
                          theme,
                          title: 'Aylik Pro',
                          price: purchase.proMonthly!.price,
                          subtitle: 'Ayda bir kez odeme',
                          isLoading: purchase.isLoading,
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            ref.read(purchaseProvider.notifier).buyMonthly();
                          },
                        ),
                      if (purchase.proMonthly != null && purchase.proYearly != null)
                        const SizedBox(height: 12),
                      if (purchase.proYearly != null)
                        _buildPurchaseButton(
                          context,
                          theme,
                          title: 'Yillik Pro',
                          price: purchase.proYearly!.price,
                          subtitle: 'En iyi deger - %40 tasarruf',
                          isLoading: purchase.isLoading,
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            ref.read(purchaseProvider.notifier).buyYearly();
                          },
                          isHighlighted: true,
                        ),
                    ],
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: purchase.isLoading
                          ? null
                          : () {
                              HapticFeedback.lightImpact();
                              ref.read(purchaseProvider.notifier).restorePurchases();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Satin alimlar geri yukleniyor...'),
                                ),
                              );
                            },
                      child: Text(
                        'Satin Alimi Geri Yukle',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white54,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Abonelik otomatik yenilenir. Istediginiz zaman iptal edebilirsiniz.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white30),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          if (purchase.isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.35),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.amber),
                      SizedBox(height: 12),
                      Text(
                        'Satin alma islemi suruyor...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPurchaseButton(
    BuildContext context,
    ThemeData theme, {
    required String title,
    required String price,
    required String subtitle,
    required VoidCallback onTap,
    required bool isLoading,
    bool isHighlighted = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: isHighlighted
              ? Colors.amber.shade600
              : Colors.white.withValues(alpha: 0.15),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isHighlighted
                ? BorderSide.none
                : BorderSide(color: Colors.white.withValues(alpha: 0.3)),
          ),
          elevation: isHighlighted ? 4 : 0,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.workspace_premium_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$title - $price',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(subtitle,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackButton(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        const Icon(Icons.store_outlined, color: Colors.white30, size: 40),
        const SizedBox(height: 8),
        Text(
          'Urunler yuklenemedi.\nLutfen internet baglantinizi kontrol edin.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white54),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () =>
              ref.read(purchaseProvider.notifier).loadProducts(),
          child: const Text('Tekrar Dene',
              style: TextStyle(color: Colors.amber)),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(description,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white60)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded,
              size: 18, color: Colors.white70),
        ],
      ),
    );
  }
}

