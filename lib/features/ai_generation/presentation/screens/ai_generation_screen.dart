import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:quickalert/quickalert.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';

// New architecture providers
import 'package:senseriduvarkagidi/features/ai_generation/presentation/providers/ai_generation_provider.dart';
import 'package:senseriduvarkagidi/features/ai_generation/presentation/providers/daily_limit_provider.dart';
import 'package:senseriduvarkagidi/features/ai_generation/presentation/providers/generation_history_provider.dart';
import 'package:senseriduvarkagidi/features/ai_generation/domain/entities/generation_request.dart';
import 'package:senseriduvarkagidi/features/ai_generation/domain/entities/generation_history_entry.dart';

// Backward compatibility imports
import 'package:senseriduvarkagidi/ek/ayarlar.dart';
import 'package:senseriduvarkagidi/features/premium/presentation/providers/premium_provider.dart';
import 'package:senseriduvarkagidi/features/premium/presentation/screens/premium_paywall_screen.dart';
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:senseriduvarkagidi/model/kullanici_model.dart';

// ---------------------------------------------------------------------------
// Style data model
// ---------------------------------------------------------------------------

class _StyleOption {
  final String name;
  final IconData icon;
  final Color color;

  const _StyleOption({
    required this.name,
    required this.icon,
    required this.color,
  });
}

// ---------------------------------------------------------------------------
// AIGenerationScreen
// ---------------------------------------------------------------------------

class AIGenerationScreen extends ConsumerStatefulWidget {
  const AIGenerationScreen({super.key});

  @override
  ConsumerState<AIGenerationScreen> createState() => _AIGenerationScreenState();
}

class _AIGenerationScreenState extends ConsumerState<AIGenerationScreen>
    with TickerProviderStateMixin {
  // -------------------------------------------------------------------------
  // Controllers
  // -------------------------------------------------------------------------

  late final TextEditingController _promptController;
  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnimation;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // -------------------------------------------------------------------------
  // Banner Ad
  // -------------------------------------------------------------------------

  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  // -------------------------------------------------------------------------
  // Local UI state
  // -------------------------------------------------------------------------

  String _selectedStyle = 'Gercekci';
  bool _promptIsNotEmpty = false;
  bool _isGenerateLocked = false;
  String _generationStepText = '';

  // -------------------------------------------------------------------------
  // Style options
  // -------------------------------------------------------------------------

  static const List<_StyleOption> _styleOptions = [
    _StyleOption(
        name: 'Gercekci', icon: Icons.photo_camera, color: Colors.blue),
    _StyleOption(name: 'Anime', icon: Icons.animation, color: Colors.purple),
    _StyleOption(
        name: 'Dijital Sanat', icon: Icons.palette, color: Colors.teal),
    _StyleOption(
        name: 'Fantastik', icon: Icons.auto_awesome, color: Colors.amber),
    _StyleOption(
        name: 'Minimalist', icon: Icons.crop_square, color: Colors.grey),
    _StyleOption(name: 'Soyut', icon: Icons.blur_on, color: Colors.red),
    _StyleOption(name: 'Dogal', icon: Icons.landscape, color: Colors.green),
    _StyleOption(name: 'Uzay', icon: Icons.rocket, color: Colors.indigo),
    _StyleOption(
        name: 'Retro', icon: Icons.filter_vintage, color: Colors.orange),
    _StyleOption(name: 'Suluboya', icon: Icons.water_drop, color: Colors.cyan),
  ];

  // -------------------------------------------------------------------------
  // Prompt suggestions
  // -------------------------------------------------------------------------

  static const List<String> _promptSuggestions = [
    'Daglarin uzerinde muhtesem gun batimi',
    'Neon isikli futuristik sehir manzarasi',
    'Sabah sisinin sarmaladigi huzurlu orman',
    'Soyut geometrik desenler ve renkli sekiller',
    'Yildizli gece altinda okyanus dalgalari',
    'Kiraz cicekleri altinda anime karakter',
    'Yagmurlu siberpunk sokak sahnesi',
    'Ucan ada uzerinde fantastik kale',
    'Istanbul Bogaz koprusu gece manzarasi',
    'Kapadokya balon turu manzarasi',
    'Pamukkale travertenleri ve havuzlar',
    'Osmanlica motifli modern sanat',
  ];

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController();
    _promptController.addListener(_onPromptChanged);

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initBannerAd();
  }

  @override
  void dispose() {
    _promptController.removeListener(_onPromptChanged);
    _promptController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  void _onPromptChanged() {
    final isNotEmpty = _promptController.text.trim().isNotEmpty;
    if (isNotEmpty != _promptIsNotEmpty) {
      setState(() => _promptIsNotEmpty = isNotEmpty);
    }
  }

  void _initBannerAd() {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    _bannerAd = BannerAd(
      adUnitId: LegacyAyarlar.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isBannerAdReady = true);
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('Banner ad failed: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
  }

  // -------------------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------------------

  Future<void> _onGenerate() async {
    if (_isGenerateLocked) return;
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;
    setState(() {
      _isGenerateLocked = true;
      _generationStepText = 'Hazirlaniyor...';
    });

    try {
      // Premium limit kontrolu
      final premiumStatus = ref.read(premiumProvider);
      if (!premiumStatus.canGenerate) {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()),
        );
        return;
      }
      final limitNotifier = ref.read(dailyLimitProvider.notifier);

      HapticFeedback.mediumImpact();
      if (mounted) {
        setState(() => _generationStepText = 'AI modeli calistiriliyor...');
      }

      final request = GenerationRequest(
        prompt: prompt,
        style: _selectedStyle,
        width: Genel.width,
        height: Genel.height,
      );

      await ref.read(aiGenerationProvider.notifier).generate(request);

      final state = ref.read(aiGenerationProvider);

      if (state.generatedImageBytes != null) {
        if (mounted) {
          setState(() => _generationStepText = 'Gorsel kaydediliyor...');
        }
        // Successful generation
        await limitNotifier.increment();
        await ref.read(premiumProvider.notifier).incrementUsage();
        await ref
            .read(generationHistoryProvider.notifier)
            .addEntry(state.generatedImageBytes!);

        HapticFeedback.heavyImpact();
        _showSuccess('Duvar kagidiniz basariyla olusturuldu!');
      } else if (state.error != null) {
        HapticFeedback.lightImpact();
        final err = state.error ?? '';
        String mesaj;
        if (err.contains('API anahtari') ||
            err.contains('api key') ||
            err.contains('401') ||
            err.contains('Unauthorized')) {
          mesaj =
              'OpenAI API anahtarı geçersiz veya tanımlı değil. Lütfen yönetici ile iletişime geçin.';
        } else if (err.contains('bağlantı') ||
            err.contains('baglanti') ||
            err.contains('internet') ||
            err.contains('ConnectionError') ||
            err.contains('SocketException')) {
          mesaj = 'İnternet bağlantısı yok. Lütfen bağlantınızı kontrol edin.';
        } else if (err.contains('429') ||
            err.contains('quota') ||
            err.contains('Rate limit')) {
          mesaj =
              'OpenAI istek limiti aşıldı. Lütfen daha sonra tekrar deneyin.';
        } else {
          mesaj = 'Görsel oluşturulamadı. Lütfen tekrar deneyin.';
        }
        _showError(mesaj);
      }
    } catch (e) {
      _showError('Gorsel olusturma sirasinda bir hata olustu: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isGenerateLocked = false;
          _generationStepText = '';
        });
      }
    }
  }

  Future<void> _onSetWallpaper() async {
    final imageBytes = ref.read(aiGenerationProvider).generatedImageBytes;
    if (imageBytes == null) return;

    final limitState = ref.read(dailyLimitProvider);
    if (limitState.isExhausted) {
      _showError('Gunluk duvar kagidi ayarlama limitiniz doldu.');
      return;
    }

    HapticFeedback.lightImpact();
    _showWallpaperLocationDialog(imageBytes);
  }

  void _showWallpaperLocationDialog(Uint8List imageBytes) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.wallpaper_rounded,
                    color: Colors.teal, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Duvar Kagidi',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Duvar kagidini nereye uygulamak istiyorsunuz?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withValues(alpha: 0.8),
                    ),
              ),
              const SizedBox(height: 16),
              _buildWallpaperOption(
                icon: Icons.lock_outline_rounded,
                title: 'Kilit Ekrani',
                subtitle: 'Sadece kilit ekraninda gorunur',
                onTap: () {
                  Navigator.of(ctx).pop();
                  _performSetWallpaper(
                      imageBytes, WallpaperManagerPlus.lockScreen);
                },
              ),
              const SizedBox(height: 8),
              _buildWallpaperOption(
                icon: Icons.home_outlined,
                title: 'Ana Ekran',
                subtitle: 'Sadece ana ekranda gorunur',
                onTap: () {
                  Navigator.of(ctx).pop();
                  _performSetWallpaper(
                      imageBytes, WallpaperManagerPlus.homeScreen);
                },
              ),
              const SizedBox(height: 8),
              _buildWallpaperOption(
                icon: Icons.phone_android_rounded,
                title: 'Her Iki Ekran',
                subtitle: 'Hem kilit hem ana ekranda gorunur',
                onTap: () {
                  Navigator.of(ctx).pop();
                  _performSetWallpaper(
                      imageBytes, WallpaperManagerPlus.bothScreens);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Iptal',
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performSetWallpaper(
      Uint8List imageBytes, int wallpaperLocation) async {
    try {
      final tempDir = Directory.systemTemp;
      final file = File(
          '${tempDir.path}/ai_wallpaper_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(imageBytes);

      final result =
          await WallpaperManagerPlus().setWallpaper(file, wallpaperLocation);
      if (!mounted) return;

      if (result != null && result.isEmpty) {
        await Kullanici.logAction(
            context, Genel.deviceId, 'AI Duvar Kagidi Yapma', 0);

        final locationText = switch (wallpaperLocation) {
          1 => 'ana ekrana',
          2 => 'kilit ekranina',
          3 => 'her iki ekrana',
          _ => '',
        };

        _showSuccess('AI duvar kagidi $locationText basariyla ayarlandi!');
      } else {
        _showError('Duvar kagidi ayarlanamadi. Lutfen tekrar deneyin.');
      }

      if (await file.exists()) await file.delete();
    } catch (e) {
      _showError('Duvar kagidi ayarlanirken bir hata olustu: $e');
    }
  }

  Future<void> _onDownload() async {
    final imageBytes = ref.read(aiGenerationProvider).generatedImageBytes;
    if (imageBytes == null) return;

    HapticFeedback.lightImpact();

    try {
      final ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth && ps != PermissionState.limited) {
        _showError('Galeriye kaydetmek icin izin verilmedi.');
        return;
      }

      final now = DateTime.now();
      final asset = await PhotoManager.editor.saveImage(
        imageBytes,
        filename: 'ai_wallpaper_${now.millisecondsSinceEpoch}',
        title: 'ai_wallpaper_${now.millisecondsSinceEpoch}',
      );
      if (!mounted) return;

      if (asset.id.isNotEmpty) {
        await Kullanici.logAction(context, Genel.deviceId, 'AI Download', 0);
        _showSuccess('AI duvar kagidi galeriye kaydedildi!');
      } else {
        _showError('Resim indirilemedi.');
      }
    } catch (e) {
      _showError('Indirme sirasinda bir hata olustu: $e');
    }
  }

  Future<void> _onShare() async {
    final imageBytes = ref.read(aiGenerationProvider).generatedImageBytes;
    if (imageBytes == null) return;

    HapticFeedback.lightImpact();

    try {
      final tempDir = Directory.systemTemp;
      final file = File(
          '${tempDir.path}/ai_share_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'AI ile olusturulmus duvar kagidi',
      );

      if (await file.exists()) await file.delete();
    } catch (e) {
      _showError('Paylasim sirasinda bir hata olustu: $e');
    }
  }

  void _onHistoryTap(GenerationHistoryEntry entry) {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) {
        final file = File(entry.filePath);
        if (!file.existsSync()) {
          return AlertDialog(
            content: const Text('Gorsel bulunamadi.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Tamam')),
            ],
          );
        }
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(file, fit: BoxFit.contain),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Alerts
  // -------------------------------------------------------------------------

  void _showSuccess(String message) {
    if (!mounted) return;
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Basarili!',
      text: message,
      confirmBtnText: 'Tamam',
      confirmBtnColor: Colors.teal,
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Hata!',
      text: message,
      confirmBtnText: 'Tamam',
      confirmBtnColor: Colors.red,
    );
  }

  // =========================================================================
  // BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final genState = ref.watch(aiGenerationProvider);
    final limitState = ref.watch(dailyLimitProvider);
    final history = ref.watch(generationHistoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body: SafeArea(
        child: Column(
          children: [
            // Banner Ad
            if (_isBannerAdReady && _bannerAd != null)
              Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                margin: const EdgeInsets.only(bottom: 4),
                child: AdWidget(ad: _bannerAd!),
              ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(theme),
                    const SizedBox(height: 16),
                    _buildDailyLimitCard(theme, limitState),
                    const SizedBox(height: 16),
                    _buildStyleSelector(theme),
                    const SizedBox(height: 16),
                    _buildPromptInput(theme),
                    const SizedBox(height: 16),
                    _buildPromptSuggestions(theme),
                    const SizedBox(height: 20),
                    _buildGenerateButton(theme, genState),
                    const SizedBox(height: 20),
                    _buildResultSection(theme, genState),
                    if (history.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildHistorySection(theme, history),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // AppBar
  // -------------------------------------------------------------------------

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: theme.textTheme.titleLarge?.color,
            size: 18,
          ),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            'AI Duvar Kagidi',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Header card
  // -------------------------------------------------------------------------

  Widget _buildHeaderCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child:
                const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI ile Olustur',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hayalinizdeki duvar kagidini yapay zeka ile olusturun',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Daily limit card
  // -------------------------------------------------------------------------

  Widget _buildDailyLimitCard(ThemeData theme, DailyLimitState limitState) {
    final remaining = limitState.remaining;
    final limit = limitState.limit;
    final isExhausted = limitState.isExhausted;
    final statusColor = isExhausted ? Colors.red : Colors.green;
    final progress =
        limit > 0 ? (limitState.used / limit).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isExhausted ? Icons.block : Icons.wallpaper_rounded,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gunluk Uretim Hakki',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isExhausted
                          ? 'Gunluk limitiniz doldu. Yarin tekrar deneyin.'
                          : 'Bugun $remaining uretim hakkiniz kaldi.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$remaining/$limit',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: statusColor.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Style selector
  // -------------------------------------------------------------------------

  Widget _buildStyleSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette_rounded, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Stil Secin',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _styleOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) =>
                  _buildStyleChip(_styleOptions[index], theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleChip(_StyleOption style, ThemeData theme) {
    final isSelected = _selectedStyle == style.name;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        // Pro stilleri kilitle (index >= 6)
        final styleIndex = _styleOptions.indexOf(style);
        if (styleIndex >= 6) {
          final premStatus = ref.read(premiumProvider);
          if (!premStatus.canUseProStyles) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()),
            );
            return;
          }
        }
        setState(() => _selectedStyle = style.name);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? style.color.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? style.color
                : theme.dividerColor.withValues(alpha: 0.4),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              style.icon,
              color: isSelected
                  ? style.color
                  : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.55),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              style.name,
              style: TextStyle(
                color: isSelected
                    ? style.color
                    : theme.textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Prompt input
  // -------------------------------------------------------------------------

  Widget _buildPromptInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_rounded, color: Colors.purple, size: 20),
              const SizedBox(width: 8),
              Text(
                'Ne Hayal Ediyorsunuz?',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _promptController,
            maxLines: 4,
            minLines: 2,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText:
                  'Ornek: Gunesin battigi daglar manzarasi, renkli gokyuzu...',
              hintStyle: TextStyle(
                color:
                    theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
                fontSize: 14,
              ),
              filled: true,
              fillColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF764ba2), width: 2),
              ),
              contentPadding: const EdgeInsets.all(14),
              suffixIcon: _promptIsNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear,
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.4),
                          size: 18),
                      onPressed: () {
                        _promptController.clear();
                      },
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Prompt suggestions
  // -------------------------------------------------------------------------

  Widget _buildPromptSuggestions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded,
                  color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Ilham Alin',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _promptSuggestions.map((s) => _buildSuggestionChip(s)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String suggestion) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _promptController.text = suggestion;
        _promptController.selection = TextSelection.fromPosition(
          TextPosition(offset: suggestion.length),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
        ),
        child: Text(
          suggestion,
          style: TextStyle(
            color: Colors.amber[800],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Generate button
  // -------------------------------------------------------------------------

  Widget _buildGenerateButton(ThemeData theme, AIGenerationState genState) {
    final isGenerating = genState.isGenerating;
    final canGenerate =
        _promptIsNotEmpty && !isGenerating && !_isGenerateLocked;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: canGenerate || isGenerating
              ? const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)])
              : null,
          color: (!canGenerate && !isGenerating)
              ? theme.disabledColor.withValues(alpha: 0.15)
              : null,
          borderRadius: BorderRadius.circular(28),
          boxShadow: canGenerate
              ? [
                  BoxShadow(
                    color: const Color(0xFF764ba2).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: canGenerate ? _onGenerate : null,
            borderRadius: BorderRadius.circular(28),
            child: Center(
              child: isGenerating
                  ? _buildGeneratingButtonContent()
                  : _buildIdleButtonContent(canGenerate, theme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratingButtonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.9)),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'AI Olusturuyor...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildIdleButtonContent(bool canGenerate, ThemeData theme) {
    final color = canGenerate
        ? Colors.white
        : theme.textTheme.bodySmall?.color?.withValues(alpha: 0.4) ??
            Colors.grey;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.auto_awesome, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          'Duvar Kagidi Olustur',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Result section
  // -------------------------------------------------------------------------

  Widget _buildResultSection(ThemeData theme, AIGenerationState genState) {
    if (!genState.isGenerating && genState.generatedImageBytes == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                genState.isGenerating
                    ? Icons.hourglass_top_rounded
                    : Icons.image_rounded,
                color: genState.isGenerating ? Colors.purple : Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                genState.isGenerating ? 'Olusturuluyor...' : 'Sonuc',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (genState.isGenerating)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerPlaceholder(theme),
                if (_generationStepText.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.timelapse_rounded,
                          size: 16, color: Color(0xFF764ba2)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _generationStepText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            )
          else if (genState.generatedImageBytes != null)
            _buildGeneratedImageSection(theme, genState.generatedImageBytes!),
        ],
      ),
    );
  }

  Widget _buildShimmerPlaceholder(ThemeData theme) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment(_shimmerAnimation.value - 1, 0),
              end: Alignment(_shimmerAnimation.value + 1, 0),
              colors: [
                theme.dividerColor.withValues(alpha: 0.08),
                theme.dividerColor.withValues(alpha: 0.2),
                theme.dividerColor.withValues(alpha: 0.08),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF764ba2).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF764ba2),
                          size: 36,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'AI duvar kagidinizi olusturuyor...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodyMedium?.color
                        ?.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bu islem birkac saniye surebilir',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGeneratedImageSection(ThemeData theme, Uint8List imageBytes) {
    return Column(
      children: [
        // Image display
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.memory(
            imageBytes,
            width: double.infinity,
            height: 340,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                width: double.infinity,
                height: 340,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image_outlined,
                        size: 48,
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.3)),
                    const SizedBox(height: 8),
                    Text(
                      'Gorsel yuklenemedi',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.wallpaper_rounded,
                label: 'Duvar Kagidi Yap',
                color: Colors.blue,
                onPressed: _onSetWallpaper,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                icon: Icons.download_rounded,
                label: 'Indir',
                color: Colors.green,
                onPressed: _onDownload,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                icon: Icons.share_rounded,
                label: 'Paylas',
                color: Colors.orange,
                onPressed: _onShare,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Wallpaper location option (for dialog)
  // -------------------------------------------------------------------------

  Widget _buildWallpaperOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.25),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.teal, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color:
                    theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // History section
  // -------------------------------------------------------------------------

  Widget _buildHistorySection(
      ThemeData theme, List<GenerationHistoryEntry> history) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, color: Colors.indigo, size: 20),
              const SizedBox(width: 8),
              Text(
                'Son Uretimler',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '${history.length} gorsel',
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) {
                final entry = history[index];
                final file = File(entry.filePath);

                return GestureDetector(
                  onTap: () => _onHistoryTap(entry),
                  child: Container(
                    width: 75,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: file.existsSync()
                          ? Image.file(
                              file,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildHistoryPlaceholder(theme),
                            )
                          : _buildHistoryPlaceholder(theme),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryPlaceholder(ThemeData theme) {
    return Container(
      color: theme.dividerColor.withValues(alpha: 0.08),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.25),
          size: 24,
        ),
      ),
    );
  }
}


