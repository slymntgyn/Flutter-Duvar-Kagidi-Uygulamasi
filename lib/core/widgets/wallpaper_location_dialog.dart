import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:senseriduvarkagidi/features/wallpaper/domain/entities/wallpaper_location.dart';

/// Duvar kagidi uygulanacak ekrani secme dialog'u.
/// 4 ekranda duplicate edilen dialog tek yere toplanmistir.
class WallpaperLocationDialog extends StatelessWidget {
  final String? subtitle;
  final void Function(WallpaperLocation location) onLocationSelected;

  const WallpaperLocationDialog({
    super.key,
    this.subtitle,
    required this.onLocationSelected,
  });

  static Future<WallpaperLocation?> show(
    BuildContext context, {
    String? subtitle,
  }) {
    return showDialog<WallpaperLocation>(
      context: context,
      builder: (_) => WallpaperLocationDialog(
        subtitle: subtitle,
        onLocationSelected: (location) => Navigator.of(context).pop(location),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.wallpaper_rounded,
                color: Colors.teal, size: 24),
          ),
          const SizedBox(width: 12),
          Text(
            'Duvar Kağıdı',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Duvar kağıdını nereye uygulamak istiyorsunuz?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.8),
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(subtitle!,
                        style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildOption(
            context,
            icon: Icons.lock_outline_rounded,
            title: 'Kilit Ekranı',
            subtitle: 'Sadece kilit ekranında görünür',
            location: WallpaperLocation.lockScreen,
          ),
          const SizedBox(height: 8),
          _buildOption(
            context,
            icon: Icons.home_outlined,
            title: 'Ana Ekran',
            subtitle: 'Sadece ana ekranda görünür',
            location: WallpaperLocation.homeScreen,
          ),
          const SizedBox(height: 8),
          _buildOption(
            context,
            icon: Icons.phone_android_rounded,
            title: 'Her İki Ekran',
            subtitle: 'Hem kilit hem ana ekranda görünür',
            location: WallpaperLocation.bothScreens,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'İptal',
            style: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required WallpaperLocation location,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onLocationSelected(location);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.teal, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withOpacity(0.7),
                            )),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.4)),
            ],
          ),
        ),
      ),
    );
  }
}
