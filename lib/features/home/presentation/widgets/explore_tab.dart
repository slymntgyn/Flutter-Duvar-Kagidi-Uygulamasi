import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:quickalert/quickalert.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';

import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';
import 'package:senseriduvarkagidi/ek/ayarlar.dart';
import 'package:senseriduvarkagidi/model/image.dart';
import 'package:senseriduvarkagidi/model/KullaniciModel.dart';
import 'package:senseriduvarkagidi/model/kategoriler.dart';
import 'package:senseriduvarkagidi/core/widgets/wallpaper_location_dialog.dart';
import 'package:senseriduvarkagidi/features/premium/presentation/providers/premium_provider.dart';
import 'package:senseriduvarkagidi/features/premium/presentation/screens/premium_paywall_screen.dart';
import 'package:senseriduvarkagidi/features/wallpaper/presentation/screens/image_detail_screen.dart';

/// Explore (Kesfet) tab — Pro UI.
/// Full-screen vertical PageView + glassmorphism action pill + gradient overlay
/// + vertical page indicator + navigation to ImageDetailScreen.
class ExploreTab extends ConsumerStatefulWidget {
  const ExploreTab({super.key});

  @override
  ConsumerState<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends ConsumerState<ExploreTab>
    with TickerProviderStateMixin {
  late PageController _imagePageController;
  late AnimationController _likeAnimationController;
  late AnimationController _buttonAnimationController;

  int _currentImageIndex = 0;
  bool _isProcessing = false;
  bool _isWallpaperProcessing = false;
  bool _showLikeAnimation = false;
  bool _isFavorite = false;

  List<ImageList> _imageList = [];
  final List<Widget> _imageWidgets = [];

  static const int _initialLoadCount = 3;
  static const int _loadMoreCount = 2;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeData();
  }

  void _initializeControllers() {
    _imagePageController = PageController();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _initializeData() {
    _imageList = List<ImageList>.from(Genel.Resimler);
    _imageList.shuffle(math.Random());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialImages();
      _updateFavoriteState();
    });
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    _likeAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full-screen vertical PageView
        GestureDetector(
          onDoubleTap: _onImageDoubleTap,
          onTap: _navigateToDetail,
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _imagePageController,
            itemCount: _imageWidgets.length,
            onPageChanged: _onImagePageChanged,
            itemBuilder: (context, index) => _imageWidgets[index],
          ),
        ),

        // Gradient info overlay (bottom)
        _buildBottomGradientOverlay(),

        // Glassmorphism action pill (right side)
        _buildGlassActionPill(),

        // Vertical page indicator (right edge)
        _buildPageIndicator(),

        // Lottie like animation
        if (_showLikeAnimation) _buildLikeAnimation(),

        // Processing overlay
        if (_isProcessing) _buildProcessingOverlay(),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom gradient info overlay
  // ---------------------------------------------------------------------------
  Widget _buildBottomGradientOverlay() {
    if (_imageList.isEmpty || _currentImageIndex >= _imageList.length) {
      return const SizedBox.shrink();
    }
    final image = _imageList[_currentImageIndex];
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 100, right: 80),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (image.kategori.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'Kategori ${image.kategori}',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11),
                    ),
                  ),
                Row(
                  children: [
                    const Icon(Icons.hd_rounded, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    const Text('4K HD',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(width: 12),
                    Icon(Icons.touch_app_rounded, color: Colors.white.withValues(alpha: 0.5), size: 14),
                    const SizedBox(width: 4),
                    Text('Detay icin dokun',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Glassmorphism action pill
  // ---------------------------------------------------------------------------
  Widget _buildGlassActionPill() {
    return Positioned(
      right: 12,
      bottom: 120,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPillButton(
                  icon: _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  label: 'Begen',
                  color: _isFavorite ? Colors.red : Colors.white,
                  onPressed: _toggleFavorite,
                ),
                const SizedBox(height: 12),
                _buildPillButton(
                  icon: Icons.wallpaper_rounded,
                  label: 'Duvar\nKagidi',
                  color: Colors.blue,
                  onPressed: _setWallpaperWithConfirmation,
                ),
                const SizedBox(height: 12),
                _buildPillButton(
                  icon: Icons.download_rounded,
                  label: 'Indir',
                  color: Colors.green,
                  onPressed: _downloadImage,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPillButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _buttonAnimationController.forward().then((_) {
          _buttonAnimationController.reverse();
        });
        onPressed();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Vertical page indicator
  // ---------------------------------------------------------------------------
  Widget _buildPageIndicator() {
    if (_imageList.isEmpty) return const SizedBox.shrink();
    final total = math.min(_imageWidgets.length, 8);
    return Positioned(
      right: 6,
      top: 0,
      bottom: 0,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(total, (i) {
            final isActive = i == _currentImageIndex % total;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(vertical: 3),
              width: isActive ? 6 : 4,
              height: isActive ? 18 : 8,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
                boxShadow: isActive
                    ? [BoxShadow(color: Colors.white.withValues(alpha: 0.5), blurRadius: 6)]
                    : null,
              ),
            );
          }),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Like animation
  // ---------------------------------------------------------------------------
  Widget _buildLikeAnimation() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Lottie.asset(
            'assets/animations/like.json',
            controller: _likeAnimationController,
            width: 200,
            height: 200,
            repeat: false,
            onLoaded: (composition) {
              _likeAnimationController.duration = composition.duration;
            },
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Processing overlay
  // ---------------------------------------------------------------------------
  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text('Islem yapiliyor...',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Image building & lazy loading
  // ---------------------------------------------------------------------------
  void _loadInitialImages() {
    _imageWidgets.clear();
    final int loadCount = math.min(_initialLoadCount, _imageList.length);
    for (int i = 0; i < loadCount; i++) {
      _imageWidgets.add(_buildImageWidget(_imageList[i]));
    }
    if (mounted) setState(() {});
  }

  void _loadMoreImages() {
    final int currentLength = _imageWidgets.length;
    final int remaining = _imageList.length - currentLength;
    final int loadCount = math.min(_loadMoreCount, remaining);
    if (loadCount > 0) {
      for (int i = 0; i < loadCount; i++) {
        _imageWidgets.add(_buildImageWidget(_imageList[currentLength + i]));
      }
      if (mounted) setState(() {});
    }
  }

  Widget _buildImageWidget(ImageList imageData) {
    final premium = ref.read(premiumProvider);
    final isLocked = imageData.isPro && !premium.isPro;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'explore_${imageData.id}',
            child: CachedNetworkImage(
              imageUrl: '${ayarlar.resimsunucusu}${imageData.yol}',
              fit: BoxFit.cover,
              memCacheWidth: 800,
              memCacheHeight: 1200,
              placeholder: (context, url) => Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.grey[850]!, Colors.grey[900]!],
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white38)),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[900],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.grey[600]),
                    const SizedBox(height: 8),
                    Text('Resim yuklenemedi',
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
          ),
          // Pro kilit overlay
          if (isLocked) _buildProLockOverlay(),
        ],
      ),
    );
  }

  Widget _buildProLockOverlay() {
    return GestureDetector(
      onTap: _showPaywall,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            color: Colors.black.withValues(alpha: 0.45),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.5),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.lock_rounded,
                        color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.workspace_premium_rounded,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'PRO Ozel Icerik',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Pro\'ya gec, tum iceriklerden yararlan',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPaywall() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()),
    );
  }

  // ---------------------------------------------------------------------------
  // Page change & state updates
  // ---------------------------------------------------------------------------
  void _onImagePageChanged(int index) {
    setState(() => _currentImageIndex = index);
    _updateFavoriteState();
    if (index >= _imageWidgets.length - 1) _loadMoreImages();
  }

  void _updateFavoriteState() {
    if (_currentImageIndex < _imageList.length) {
      setState(() {
        _isFavorite = Yardimci.favori_resimler_Kontrol(
            _imageList[_currentImageIndex].id);
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Navigate to detail
  // ---------------------------------------------------------------------------
  /// Mevcut resim pro mu ve kullanici pro degil mi kontrol eder.
  bool _isCurrentImageLocked() {
    if (_currentImageIndex >= _imageList.length) return false;
    final image = _imageList[_currentImageIndex];
    final premium = ref.read(premiumProvider);
    return image.isPro && !premium.isPro;
  }

  void _navigateToDetail() {
    if (_currentImageIndex >= _imageList.length) return;
    if (_isCurrentImageLocked()) {
      _showPaywall();
      return;
    }
    final image = _imageList[_currentImageIndex];
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (ctx, anim, secAnim) => ImageDetailScreen(
          image: image,
          heroTag: 'explore_${image.id}',
        ),
        transitionsBuilder: (ctx, anim, secAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    ).then((_) => _updateFavoriteState());
  }

  // ---------------------------------------------------------------------------
  // Double-tap to favorite
  // ---------------------------------------------------------------------------
  void _onImageDoubleTap() {
    HapticFeedback.mediumImpact();
    if (_isCurrentImageLocked()) {
      _showPaywall();
      return;
    }
    _toggleFavorite();
  }

  // ---------------------------------------------------------------------------
  // Toggle favorite
  // ---------------------------------------------------------------------------
  Future<void> _toggleFavorite() async {
    if (_currentImageIndex >= _imageList.length || !mounted) return;
    final imageId = _imageList[_currentImageIndex].id;
    final bool wasFavorite = Yardimci.favori_resimler_Kontrol(imageId);

    try {
      await ImageList.FavorilereEkle(context, imageId);
      if (!mounted) return;
      Yardimci.favori_resim_ekle(imageId.toString());

      if (!wasFavorite) {
        setState(() {
          _isFavorite = true;
          _showLikeAnimation = true;
        });
        _likeAnimationController.forward().then((_) {
          _likeAnimationController.reset();
          if (mounted) setState(() => _showLikeAnimation = false);
        });
      } else {
        setState(() => _isFavorite = false);
      }
    } catch (e) {
      if (mounted) _updateFavoriteState();
    }
  }

  // ---------------------------------------------------------------------------
  // Set wallpaper
  // ---------------------------------------------------------------------------
  void _setWallpaperWithConfirmation() {
    if (_isWallpaperProcessing) return;
    if (_isCurrentImageLocked()) {
      _showPaywall();
      return;
    }
    HapticFeedback.lightImpact();
    if (ayarlar.odullureklamacikmi == '1') {
      _showRewardedAdForWallpaper();
    } else {
      _showWallpaperLocationDialog();
    }
  }

  void _showRewardedAdForWallpaper() {
    if (Genel.reklam == null) {
      _showWallpaperLocationDialog();
      KategoriList.ReklamYukle(context);
    } else {
      Genel.reklam?.show(onUserEarnedReward: (ad, rewardItem) {
        ad.dispose();
        _showWallpaperLocationDialog();
        KategoriList.ReklamYukle(context);
      });
    }
  }

  void _showWallpaperLocationDialog() async {
    final location = await WallpaperLocationDialog.show(context);
    if (!mounted) return;
    if (location != null && _currentImageIndex < _imageList.length) {
      _performSetWallpaper(_imageList[_currentImageIndex], location.value);
    }
  }

  Future<void> _performSetWallpaper(
      ImageList imageData, int wallpaperLocation) async {
    if (_isWallpaperProcessing) return;
    try {
      setState(() {
        _isWallpaperProcessing = true;
        _isProcessing = true;
      });
      final url = '${ayarlar.resimsunucusu}${imageData.yol}';
      final file = await DefaultCacheManager().getSingleFile(url);
      final result =
          await WallpaperManagerPlus().setWallpaper(file, wallpaperLocation);
      if (!mounted) return;
      if (result == 'Wallpaper set successfully' ||
          (result ?? '').contains('success')) {
        try {
          await Kullanici.IslemLog(context, Genel.CihazId,
              'Duvar Kagidi Yapma', imageData.id);
        } catch (_) {}
        _showSuccessAlert('Duvar kagidi basariyla ayarlandi!');
      } else {
        _showErrorAlert('Duvar kagidi ayarlanamadi');
      }
    } catch (e) {
      _showErrorAlert('Bir hata olustu: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isWallpaperProcessing = false;
          _isProcessing = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Download
  // ---------------------------------------------------------------------------
  void _downloadImage() {
    if (_currentImageIndex >= _imageList.length) return;
    if (_isCurrentImageLocked()) {
      _showPaywall();
      return;
    }
    final imageData = _imageList[_currentImageIndex];
    if (ayarlar.odullureklamacikmi == '1') {
      _showRewardedAdForDownload(imageData);
    } else {
      _download(imageData);
    }
  }

  void _showRewardedAdForDownload(ImageList imageData) {
    if (Genel.reklam == null) {
      _download(imageData);
      KategoriList.ReklamYukle(context);
    } else {
      Genel.reklam?.show(onUserEarnedReward: (ad, rewardItem) {
        ad.dispose();
        _download(imageData);
        KategoriList.ReklamYukle(context);
      });
    }
  }

  Future<void> _download(ImageList imageData) async {
    try {
      setState(() => _isProcessing = true);
      final imageUrl = '${ayarlar.resimsunucusu}${imageData.yol}';
      final now = DateTime.now();
      final response = await Dio()
          .get(imageUrl, options: Options(responseType: ResponseType.bytes));
      final imageBytes = Uint8List.fromList(response.data);
      final ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth && ps != PermissionState.limited) {
        _showErrorAlert('Galeriyi kaydetmek icin izin verilmedi.');
        return;
      }
      final asset = await PhotoManager.editor.saveImage(imageBytes,
          filename: 'wallpaper_${now.millisecondsSinceEpoch}',
          title: 'wallpaper_${now.millisecondsSinceEpoch}');
      if (!mounted) return;
      if (asset.id.isNotEmpty) {
        try {
          await Kullanici.IslemLog(
              context, Genel.CihazId, 'Download', imageData.id);
        } catch (_) {}
        _showSuccessAlert('Resim basariyla indirildi!');
      } else {
        _showErrorAlert('Resim indirilemedi');
      }
    } catch (e) {
      _showErrorAlert('Bir hata olustu: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Alerts
  // ---------------------------------------------------------------------------
  void _showSuccessAlert(String message) {
    if (!mounted) return;
    QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Basarili!',
        text: message,
        confirmBtnColor: Colors.teal);
  }

  void _showErrorAlert(String message) {
    if (!mounted) return;
    QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Hata!',
        text: message,
        confirmBtnColor: Colors.red);
  }
}
