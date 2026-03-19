import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

// New architecture imports
import 'package:senseriduvarkagidi/core/di/providers.dart';
import 'package:senseriduvarkagidi/core/theme/app_theme.dart';

// Old architecture imports (backward compatibility during migration)
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';
import 'package:senseriduvarkagidi/ek/ayarlar.dart';
import 'package:senseriduvarkagidi/model/Ayarlar.dart';
import 'package:senseriduvarkagidi/model/KullaniciModel.dart';
import 'package:senseriduvarkagidi/model/image.dart';
import 'package:senseriduvarkagidi/model/kategoriler.dart';
import 'package:senseriduvarkagidi/features/home/presentation/screens/home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  String _currentStatus = 'Baslatiliyor...';
  bool _hasError = false;
  String _errorMessage = '';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSetup();
  }

  // ---------------------------------------------------------------------------
  // Animations
  // ---------------------------------------------------------------------------

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _scaleController.forward();
    });
  }

  // ---------------------------------------------------------------------------
  // Initialization pipeline
  // ---------------------------------------------------------------------------

  Future<void> _startSetup() async {
    try {
      await _stepCheckConnection();
      await _stepLoadSettings();
      await _stepGetDeviceId();
      await _stepLoadWallpapers();
      await _stepLoadCategories();
      await _stepFinalize();
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// Step 1 -- Check connection (lightweight, always succeeds for now)
  Future<void> _stepCheckConnection() async {
    _updateProgress(0.1, 'Baglanti kontrol ediliyor...');
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Step 2 -- Load settings via Riverpod appSettingsProvider *and* old path
  Future<void> _stepLoadSettings() async {
    _updateProgress(0.2, 'Ayarlar yukleniyor...');

    // -- Old dark-mode preference (backward compat) --------------------------
    String darkmode = await Yardimci.Veri_Getir_String('darkmode');
    if (darkmode.isEmpty) darkmode = 'false';
    Genel.darkbutton = bool.parse(darkmode);

    // Sync Riverpod theme state with legacy flag
    final currentTheme = ref.read(themeProvider);
    final isDarkInRiverpod =
        currentTheme == AppThemeMode.dark || currentTheme == AppThemeMode.amoled;
    if (Genel.darkbutton && !isDarkInRiverpod) {
      ref.read(themeProvider.notifier).setTheme(AppThemeMode.dark);
    } else if (!Genel.darkbutton && isDarkInRiverpod) {
      ref.read(themeProvider.notifier).setTheme(AppThemeMode.light);
    }

    // -- Old server-side settings --------------------------------------------
    _updateProgress(0.3, 'Sunucu ayarlari aliniyor...');
    if (!mounted) return;

    List<Ayarlar>? list = await Ayarlar.Ayarlari_Getir(context);
    if (list != null) {
      ayarlar.Ayarlari_Yukle(list);
    }

    Genel.adUnitId = ayarlar.odulluReklamId;

    if (ayarlar.bakimvarmi == '1') {
      throw Exception(
        'Sistemde bakim calismasi vardir.\nLutfen daha sonra tekrar deneyiniz.',
      );
    }
  }

  /// Step 3 -- Obtain device identifier
  Future<void> _stepGetDeviceId() async {
    _updateProgress(0.5, 'Cihaz bilgileri aliniyor...');

    // Old path -- populates Genel.CihazId
    await Yardimci.Cihaz_Bilgi_Getir();

    // Also load user info through old path
    _updateProgress(0.6, 'Kullanici bilgileri yukleniyor...');
    if (!mounted) return;
    await Kullanici.Kullanici_Getir(context);
  }

  /// Step 4 -- Load wallpapers (old path for now)
  Future<void> _stepLoadWallpapers() async {
    _updateProgress(0.7, 'Resimler yukleniyor...');
    if (!mounted) return;
    await ImageList.GetResimler(context);
  }

  /// Step 5 -- Load categories (old path for now)
  Future<void> _stepLoadCategories() async {
    _updateProgress(0.9, 'Kategoriler yukleniyor...');
    if (!mounted) return;
    await KategoriList.GetKategoriler(context);

    // Prepare ads
    _updateProgress(0.95, 'Reklamlar hazirlaniyor...');
    if (!mounted) return;
    KategoriList.ReklamYukle(context);
  }

  /// Step 6 -- Done -- navigate to main screen
  Future<void> _stepFinalize() async {
    _updateProgress(1.0, 'Tamamlandi!');
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _updateProgress(double value, String status) {
    if (!mounted) return;
    setState(() {
      _progress = value;
      _currentStatus = status;
    });
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _progress = 0.0;
      _currentStatus = 'Baslatiliyor...';
    });
    HapticFeedback.lightImpact();
    _startSetup();
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Keep legacy dimension globals in sync
    Genel.genislik = MediaQuery.of(context).size.width;
    Genel.yukseklik = MediaQuery.of(context).size.height;

    final themeMode = ref.watch(themeProvider);
    final isDark =
        themeMode == AppThemeMode.dark || themeMode == AppThemeMode.amoled;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF1a1a1a),
                    Color(0xFF2d2d2d),
                    Color(0xFF1a1a1a),
                  ]
                : const [
                    Color(0xFFf8f9fa),
                    Color(0xFFe9ecef),
                    Color(0xFFf8f9fa),
                  ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _hasError ? _buildErrorView(isDark) : _buildLoadingView(isDark),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Loading view
  // ---------------------------------------------------------------------------

  Widget _buildLoadingView(bool isDark) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        const Spacer(),

        // Logo
        ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.cardColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.05),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Image.asset(
              isDark
                  ? 'assets/images/4K-HDWHITE.png'
                  : 'assets/images/4K-HDBLACK.png',
              width: Genel.genislik * 0.5,
              height: Genel.genislik * 0.3,
            ),
          ),
        ),

        const SizedBox(height: 60),

        // Title
        Text(
          '4K-HD',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'DUVAR KAGITLARI',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
            color: theme.textTheme.titleMedium?.color?.withValues(alpha: 0.7),
          ),
        ),

        const Spacer(),

        // Progress section
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Animated loading dots
              LoadingAnimationWidget.fourRotatingDots(
                color: theme.primaryColor,
                size: 40,
              ),

              const SizedBox(height: 20),

              // Status text
              Text(
                _currentStatus,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Progress bar track
              Container(
                width: double.infinity,
                height: 6,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: screenWidth * _progress * 0.8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor,
                        theme.primaryColor.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Percentage
              Text(
                '${(_progress * 100).toInt()}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 60),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Error view
  // ---------------------------------------------------------------------------

  Widget _buildErrorView(bool isDark) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 60,
                color: Colors.red.shade400,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              'Bir Hata Olustu',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Message
            Text(
              _errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color
                    ?.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Retry button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _retry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Tekrar Dene',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
