import 'dart:math' as math;
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';

// Third party packages
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hyper_effects/hyper_effects.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:quickalert/quickalert.dart';
import 'package:vibration/vibration.dart';

// Local imports
import 'package:senseriduvarkagidi/Screens/KategoriResim.dart';
import 'package:senseriduvarkagidi/model/Ayarlar.dart';
import 'package:senseriduvarkagidi/model/kategoriler.dart';
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:senseriduvarkagidi/ek/widgets.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';
import 'package:senseriduvarkagidi/ek/ayarlar.dart';
import 'package:senseriduvarkagidi/model/KullaniciModel.dart';
import 'package:senseriduvarkagidi/model/image.dart';

class ImageDetay extends StatefulWidget {
  const ImageDetay({Key? key}) : super(key: key);

  @override
  State<ImageDetay> createState() => _ImageDetayState();
}

class _ImageDetayState extends State<ImageDetay>
    with TickerProviderStateMixin {

  // Animation Controllers
  late AnimationController _likeAnimationController;
  late AnimationController _buttonAnimationController;
  late AnimationController _fadeAnimationController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // State Variables
  bool _isProcessing = false;
  bool _showLikeAnimation = false;
  bool _showControls = true;
  Color _favoriteButtonColor = Colors.white;
  Timer? _hideControlsTimer;

  // Constants
  static const Duration _animationDuration = Duration(milliseconds: 300);
  static const Duration _likeAnimationDuration = Duration(milliseconds: 1200);
  static const Duration _hideControlsDelay = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _loadInitialData();
    _startHideControlsTimer();
  }

  void _initializeControllers() {
    _likeAnimationController = AnimationController(
      duration: _likeAnimationDuration,
      vsync: this,
    );

    _buttonAnimationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _fadeAnimationController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
  }

  void _initializeAnimations() {
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimationController.forward();
  }

  void _loadInitialData() {
    KategoriList.ReklamYukle(context);
    _updateFavoriteButtonColor();

    if (kDebugMode) {
      print("Selected Image ID: ${Genel.SecilenResimler.id}");
    }
  }

  void _updateFavoriteButtonColor() {
    setState(() {
      _favoriteButtonColor = Yardimci.favori_resimler_Kontrol(
        Genel.SecilenResimler.id,
      ) ? Colors.red : Colors.white;
    });
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(_hideControlsDelay, () {
      if (mounted && _showControls) {
        setState(() => _showControls = false);
      }
    });
  }

  void _resetHideControlsTimer() {
    setState(() => _showControls = true);
    _startHideControlsTimer();
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _buttonAnimationController.dispose();
    _fadeAnimationController.dispose();
    _hideControlsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildMainImage(),
          _buildGradientOverlays(),
          if (_showControls) _buildTopControls(),
          if (_showControls) _buildBottomControls(),
          if (_showLikeAnimation) _buildLikeAnimation(),
          if (_isProcessing) _buildProcessingOverlay(),
        ],
      ),
    );
  }

  Widget _buildMainImage() {
    return GestureDetector(
      onTap: _resetHideControlsTimer,
      onDoubleTap: _onImageDoubleTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Hero(
          tag: ayarlar.resimsunucusu + Genel.SecilenResimler.yol,
          child: CachedNetworkImage(
            imageUrl: ayarlar.resimsunucusu + Genel.SecilenResimler.yol,
            fit: BoxFit.cover,
            memCacheWidth: 1200,
            memCacheHeight: 1800,
            placeholder: (context, url) => _buildImagePlaceholder(),
            errorWidget: (context, url, error) => _buildImageError(),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[800]!,
            Colors.grey[900]!,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              "Yükleniyor...",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              "Resim yüklenemedi",
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "İnternet bağlantınızı kontrol edin",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
// ImageDetay.dart dosyasında _setWallpaperWithConfirmation metodunu değiştirin:

  void _setWallpaperWithConfirmation() {
    _showWallpaperLocationDialog();
  }

  void _showWallpaperLocationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Theme.of(context).cardColor,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.wallpaper_rounded,
                  color: Colors.teal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Duvar Kağıdı",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Duvar kağıdını nereye uygulamak istiyorsunuz?",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),
              _buildWallpaperOption(
                icon: Icons.lock_outline_rounded,
                title: "Kilit Ekranı",
                subtitle: "Sadece kilit ekranında görünür",
                onTap: () {
                  Navigator.of(context).pop();
                  _performAction(() => _setWallpaper(WallpaperManagerPlus.lockScreen));
                },
              ),
              const SizedBox(height: 8),
              _buildWallpaperOption(
                icon: Icons.home_outlined,
                title: "Ana Ekran",
                subtitle: "Sadece ana ekranda görünür",
                onTap: () {
                  Navigator.of(context).pop();
                  _performAction(() => _setWallpaper(WallpaperManagerPlus.homeScreen));
                },
              ),
              const SizedBox(height: 8),
              _buildWallpaperOption(
                icon: Icons.phone_android_rounded,
                title: "Her İki Ekran",
                subtitle: "Hem kilit hem ana ekranda görünür",
                onTap: () {
                  Navigator.of(context).pop();
                  _performAction(() => _setWallpaper(WallpaperManagerPlus.bothScreens));
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "İptal",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWallpaperOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
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
                child: Icon(
                  icon,
                  color: Colors.teal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

// _setWallpaper metodunu güncelleyin (parametre ekleyin):
  Future<void> _setWallpaper(int wallpaperLocation) async {
    try {
      setState(() => _isProcessing = true);

      final url = ayarlar.resimsunucusu + Genel.SecilenResimler.yol;
      final file = await DefaultCacheManager().getSingleFile(url);

      final result = await WallpaperManagerPlus().setWallpaper(file, wallpaperLocation);

      if (result!.isEmpty) {
        await Kullanici.IslemLog(
          context,
          Genel.CihazId,
          "Duvar Kagidi Yapma",
          Genel.SecilenResimler.id,
        );

        String locationText = "";
        switch (wallpaperLocation) {
          case 1: // WallpaperManagerFlutter.homeScreen
            locationText = "ana ekrana";
            break;
          case 2: // WallpaperManagerFlutter.lockScreen
            locationText = "kilit ekranına";
            break;
          case 3: // WallpaperManagerFlutter.bothScreens
            locationText = "her iki ekrana";
            break;
        }

        _showSuccessAlert("Duvar kağıdı $locationText başarıyla ayarlandı!");
      } else {
        _showErrorAlert("Duvar kağıdı ayarlanamadı");
      }
    } catch (e) {
      _showErrorAlert("Bir hata oluştu: ${e.toString()}");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

// _buildOptionsBottomSheet içinde set_wallpaper seçeneğini güncelleyin:
  Widget _buildOptionsBottomSheet() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          _buildOptionItem(
            icon: Icons.wallpaper_rounded,
            title: "Duvar Kağıdı Yap",
            subtitle: "Ekran seçerek duvar kağıdı yap",
            onTap: () => _setWallpaperWithConfirmation(),
          ),
          _buildOptionItem(
            icon: Icons.info_outline_rounded,
            title: "Resim Bilgileri",
            subtitle: "Çözünürlük ve boyut",
            onTap: () => _showImageInfo(),
          ),
          _buildOptionItem(
            icon: Icons.share_rounded,
            title: "Paylaş",
            subtitle: "Arkadaşlarınla paylaş",
            onTap: () => _shareImage(),
          ),
          _buildOptionItem(
            icon: Icons.report_outlined,
            title: "Şikayet Et",
            subtitle: "Bu görseli bildir",
            onTap: () => _reportImage(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  Widget _buildGradientOverlays() {
    return AnimatedOpacity(
      opacity: _showControls ? 1.0 : 0.0,
      duration: _animationDuration,
      child: Stack(
        children: [
          // Top gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bottom gradient
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(_fadeAnimation),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTopButton(
                icon: Icons.arrow_back_ios_rounded,
                onPressed: () => Navigator.of(context).pop(),
              ),
              _buildImageInfo(),
              _buildTopButton(
                icon: Icons.more_vert_rounded,
                onPressed: _showImageOptionsMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        icon: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        splashRadius: 24,
      ),
    );
  }

  Widget _buildImageInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.photo_outlined,
            color: Colors.white70,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            "HD Duvar Kağıdı",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 32,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.favorite_rounded,
                  label: "Beğen",
                  color: _favoriteButtonColor,
                  onPressed: _toggleFavorite,
                ),
                _buildActionButton(
                  icon: Icons.wallpaper_rounded,
                  label: "Duvar Kağıdı",
                  color: Colors.white,
                  onPressed: _setWallpaperWithConfirmation,
                ),
                _buildActionButton(
                  icon: Icons.download_rounded,
                  label: "İndir",
                  color: Colors.white,
                  onPressed: _downloadImage,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: AnimatedBuilder(
        animation: _buttonAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_buttonAnimationController.value * 0.05),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _buttonAnimationController.forward().then((_) {
                    _buttonAnimationController.reverse();
                  });
                  onPressed();
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        color: color,
                        size: 28,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

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

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              Text(
                "İşlem yapılıyor...",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Lütfen bekleyiniz",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Event Handlers
  void _onImageDoubleTap() {
    HapticFeedback.heavyImpact();
    _toggleFavorite();
  }

  void _toggleFavorite() {
    _addToFavorites(Genel.SecilenResimler.id);

    // Show like animation only when adding to favorites
    if (Yardimci.favori_resimler_Kontrol(Genel.SecilenResimler.id)) {
      setState(() => _showLikeAnimation = true);

      _likeAnimationController.forward().then((_) {
        _likeAnimationController.reset();
        setState(() => _showLikeAnimation = false);
      });
    }

    _updateFavoriteButtonColor();
  }


  void _downloadImage() {
    _performAction(() => _download());
  }

  void _performAction(VoidCallback action) {
    if (ayarlar.odullureklamacikmi == "1") {
      _showRewardedAdForAction(action);
    } else {
      action();
    }
  }

  void _showRewardedAdForAction(VoidCallback action) {
    if (Genel.reklam == null) {
      action();
      KategoriList.ReklamYukle(context);
    } else {
      Genel.reklam?.show(onUserEarnedReward: (ad, rewardItem) {
        ad.dispose();
        action();
        KategoriList.ReklamYukle(context);
      });
    }
  }

  void _showImageOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildOptionsBottomSheet(),
    );
  }


  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.teal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.teal, size: 20),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Action Methods
  Future<void> _download() async {
    try {
      setState(() => _isProcessing = true);

      final imageUrl = ayarlar.resimsunucusu + Genel.SecilenResimler.yol;
      final DateTime now = DateTime.now();

      // 1️⃣ Resmi indir
      final response = await Dio().get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final Uint8List imageBytes = Uint8List.fromList(response.data);

      // 2️⃣ Galeri izni iste
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth) {
        _showErrorAlert("Galeriyi kaydetmek için izin verilmedi.");
        return;
      }

      // 3️⃣ Resmi kaydet
      final asset = await PhotoManager.editor.saveImage(
        imageBytes,
        filename: "wallpaper_${now.millisecondsSinceEpoch}",
        title: "wallpaper_${now.millisecondsSinceEpoch}",
        desc: "turan wallpaper",
      );

      if (asset != null) {
        // 4️⃣ İşlem log kaydı
        await Kullanici.IslemLog(
          context,
          Genel.CihazId,
          "Download",
          Genel.SecilenResimler.id,
        );
        _showSuccessAlert("Resim başarıyla indirildi!");
      } else {
        _showErrorAlert("Resim indirilemedi");
      }
    } catch (e) {
      _showErrorAlert("Bir hata oluştu: ${e.toString()}");
    } finally {
      setState(() => _isProcessing = false);
    }
  }



  Future<void> _addToFavorites(int imageId) async {
    try {
      await ImageList.FavorilereEkle(context, imageId);
      Yardimci.favori_resim_ekle(imageId.toString());
    } catch (e) {
      _showErrorAlert("Favorilere eklenemedi");
    }
  }

  // Utility Methods
  void _showImageInfo() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      title: "Resim Bilgileri",
      text: "ID: ${Genel.SecilenResimler.id}\nYüksek çözünürlüklü duvar kağıdı",
      confirmBtnColor: Colors.teal,
    );
  }

  void _shareImage() {
    _showSuccessAlert("Paylaşım özelliği yakında eklenecek!");
  }

  void _reportImage() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.warning,
      title: "Şikayet",
      text: "Bu görseli bildirmek istediğinizden emin misiniz?",
      confirmBtnText: 'Bildir',
      cancelBtnText: 'İptal',
      confirmBtnColor: Colors.orange,
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
        _showSuccessAlert("Şikayetiniz alındı. Teşekkürler!");
      },
    );
  }

  void _showSuccessAlert(String message) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: "Başarılı!",
      text: message,
      confirmBtnColor: Colors.teal,
    );
  }

  void _showErrorAlert(String message) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: "Hata!",
      text: message,
      confirmBtnColor: Colors.red,
    );
  }
}