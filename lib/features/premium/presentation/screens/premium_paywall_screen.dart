import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:senseriduvarkagidi/features/premium/presentation/providers/premium_provider.dart';

/// Premium paywall ekrani.
/// Kullanici gunluk limitini astiginda veya Pro ozelliklere
/// erismek istediginde gosterilir.
class PremiumPaywallScreen extends ConsumerWidget {
  const PremiumPaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premium = ref.watch(premiumProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1a1a2e),
              const Color(0xFF16213e),
              const Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // Kapat butonu
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ),

                const SizedBox(height: 8),

                // Pro rozeti
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.shade400,
                        Colors.orange.shade600,
                      ],
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

                // Baslik
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
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 32),

                // Ozellik listesi
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
                  description: 'Tum reklamlar kaldirilir, kesintisiz kullanim',
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

                // Mevcut durum gostergesi
                if (!premium.isPro)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline_rounded, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Bugun ${premium.remainingAiGenerations} AI uretim hakkiniz kaldi',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Satin al butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _handlePurchase(context, ref);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: Colors.amber.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.workspace_premium_rounded, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Pro\'ya Yukselt',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Geri yukle butonu
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _handleRestore(context, ref);
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

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
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
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
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
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handlePurchase(BuildContext context, WidgetRef ref) {
    // TODO: In-app purchase entegrasyonu.
    // Simdilik placeholder: dogrudan Pro'ya yukselt.
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pro\'ya Yukselt'),
        content: const Text(
          'In-app purchase entegrasyonu yakin zamanda eklenecek. '
          'Simdilik test modunda Pro\'ya yukseltilecek.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Iptal'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(premiumProvider.notifier).upgradeToPro();
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pro\'ya yukseltildiniz!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Test: Pro Yap'),
          ),
        ],
      ),
    );
  }

  void _handleRestore(BuildContext context, WidgetRef ref) {
    // TODO: Satin alim geri yukleme.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Satin alim geri yukleme yakin zamanda eklenecek.'),
      ),
    );
  }
}
