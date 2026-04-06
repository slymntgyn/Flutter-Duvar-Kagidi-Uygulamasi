import 'package:flutter/material.dart';

/// Islem sirasinda gosterilen loading overlay widget'i.
class LoadingOverlay extends StatelessWidget {
  final String message;
  final double? progress;
  final String? stepLabel;

  const LoadingOverlay({
    super.key,
    this.message = 'İşlem yapılıyor...',
    this.progress,
    this.stepLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              if (stepLabel != null) ...[
                const SizedBox(height: 8),
                Text(
                  stepLabel!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (progress != null) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: 220,
                  child: Builder(
                    builder: (context) {
                      final double safeProgress =
                          progress!.clamp(0.0, 1.0).toDouble();
                      return LinearProgressIndicator(
                        value: safeProgress,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(8),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '%${(progress!.clamp(0.0, 1.0) * 100).toInt()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
