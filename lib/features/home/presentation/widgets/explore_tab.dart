import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Third party packages
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:quickalert/quickalert.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';

// Backward-compatible local imports
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';
import 'package:senseriduvarkagidi/ek/ayarlar.dart';
import 'package:senseriduvarkagidi/model/image.dart';
import 'package:senseriduvarkagidi/model/KullaniciModel.dart';
import 'package:senseriduvarkagidi/model/kategoriler.dart';
import 'package:senseriduvarkagidi/Screens/ImageDetay.dart';
import 'package:senseriduvarkagidi/core/widgets/wallpaper_location_dialog.dart';

/// Explore (Kesfet) tab - full-screen vertical PageView of wallpaper images.
///
/// Extracted from the old Sayfalar.dart `_buildImagesPage` section.
/// Supports double-tap to favorite with Lottie animation, lazy image loading,
/// and action buttons for favorite / set-wallpaper / download.
class ExploreTab extends ConsumerStatefulWidget {
  const ExploreTab({super.key});

  @override
  ConsumerState<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends ConsumerState<ExploreTab>
    with TickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // Controllers
  // ---------------------------------------------------------------------------
  late PageController _imagePageController;
  late AnimationController _likeAnimationController;
  late AnimationController _buttonAnimationController;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------
  int _currentImageIndex = 0;
  bool _isProcessing = false;
  bool _isWallpaperProcessing = false;
  bool _showLikeAnimation = false;
  Color _favoriteButtonColor = Colors.white;

  // ---------------------------------------------------------------------------
  // Data - lazy loading
  // ---------------------------------------------------------------------------
  List<ImageList> _imageList = [];
  final List<Widget> _imageWidgets = [];

  static const int _initialLoadCount = 3;
  static const int _loadMoreCount = 2;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------
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
    // Shuffled copy of Genel.Resimler (backward compatible)
    _imageList = List<ImageList>.from(Genel.Resimler);
    _imageList.shuffle(math.Random());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialImages();
      _updateFavoriteButtonColor();
    });
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    _likeAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full-screen vertical PageView
        GestureDetector(
          onDoubleTap: _onImageDoubleTap,
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _imagePageController,
            itemCount: _imageWidgets.length,
            onPageChanged: _onImagePageChanged,
            itemBuilder: (context, index) => _imageWidgets[index],
          ),
        ),

        // Right-side action buttons
        _buildImageActionButtons(),

        // Lottie like animation overlay
        if (_showLikeAnimation) _buildLikeAnimation(),

        // Processing overlay (download / wallpaper)
        if (_isProcessing) _buildProcessingOverlay(),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Action buttons
  // ---------------------------------------------------------------------------
  Widget _buildImageActionButtons() {
    return Positioned(
      right: 16,
      bottom: 120,
      child: AnimatedBuilder(
        animation: _buttonAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_buttonAnimationController.value * 0.1),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(
                    icon: Icons.favorite_rounded,
                    label: 'Begen',
                    color: _favoriteButtonColor,
                    onPressed: _toggleFavorite,
                  ),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    icon: Icons.wallpaper_rounded,
                    label: 'Duvar\nKagidi',
                    color: Colors.white,
                    onPressed: _setWallpaperWithConfirmation,
                  ),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    icon: Icons.download_rounded,
                    label: 'Indir',
                    color: Colors.white,
                    onPressed: _downloadImage,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
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
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
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
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
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
                'Islem yapiliyor...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
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
    final int remainingImages = _imageList.length - currentLength;
    final int loadCount = math.min(_loadMoreCount, remainingImages);

    if (loadCount > 0) {
      for (int i = 0; i < loadCount; i++) {
        _imageWidgets.add(_buildImageWidget(_imageList[currentLength + i]));
      }
      if (mounted) setState(() {});
    }
  }

  Widget _buildImageWidget(ImageList imageData) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Hero(
        tag: imageData.id,
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
                colors: [
                  Colors.grey[300]!,
                  Colors.grey[400]!,
                ],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 8),
                Text(
                  'Resim yuklenemedi',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Page change & favorite color
  // ---------------------------------------------------------------------------
  void _onImagePageChanged(int index) {
    setState(() {
      _currentImageIndex = index;
    });

    _updateFavoriteButtonColor();

    // Load more images when near the end
    if (index >= _imageWidgets.length - 1) {
      _loadMoreImages();
    }
  }

  void _updateFavoriteButtonColor() {
    if (_currentImageIndex < _imageList.length) {
      setState(() {
        _favoriteButtonColor = Yardimci.favori_resimler_Kontrol(
          _imageList[_currentImageIndex].id,
        )
            ? Colors.red
            : Colors.white;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Double-tap to favorite
  // ---------------------------------------------------------------------------
  void _onImageDoubleTap() {
    HapticFeedback.mediumImpact();
    _toggleFavorite();
  }

  // ---------------------------------------------------------------------------
  // Toggle favorite
  // ---------------------------------------------------------------------------
  Future<void> _toggleFavorite() async {
    if (_currentImageIndex >= _imageList.length || !mounted) return;

    final imageId = _imageList[_currentImageIndex].id;
    final bool isFavorite = Yardimci.favori_resimler_Kontrol(imageId);

    try {
      await ImageList.FavorilereEkle(context, imageId);

      if (!isFavorite) {
        // Adding to favorites
        Yardimci.favori_resim_ekle(imageId.toString());

        setState(() {
          _favoriteButtonColor = Colors.red;
          _showLikeAnimation = true;
        });

        _likeAnimationController.forward().then((_) {
          _likeAnimationController.reset();
          if (mounted) {
            setState(() {
              _showLikeAnimation = false;
            });
          }
        });
      } else {
        // Removing from favorites
        Yardimci.favori_resim_ekle(imageId.toString());

        setState(() {
          _favoriteButtonColor = Colors.white;
        });
      }
    } catch (e) {
      if (mounted) {
        _updateFavoriteButtonColor();
        _showErrorAlert('Islem tamamlanamadi');
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Set wallpaper flow
  // ---------------------------------------------------------------------------
  void _setWallpaperWithConfirmation() {
    if (_isWallpaperProcessing) return;

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
    if (location != null && _currentImageIndex < _imageList.length) {
      _performSetWallpaper(
        _imageList[_currentImageIndex],
        location.value,
      );
    }
  }

  Future<void> _performSetWallpaper(
    ImageList imageData,
    int wallpaperLocation,
  ) async {
    if (_isWallpaperProcessing) return;

    try {
      setState(() {
        _isWallpaperProcessing = true;
        _isProcessing = true;
      });

      final url = '${ayarlar.resimsunucusu}${imageData.yol}';
      final file = await DefaultCacheManager().getSingleFile(url);

      String? result;
      try {
        result =
            await WallpaperManagerPlus().setWallpaper(file, wallpaperLocation);
      } catch (wallpaperError) {
        throw Exception(
            'Wallpaper ayarlanamadi: ${wallpaperError.toString()}');
      }

      if (result == 'Wallpaper set successfully' ||
          result?.contains('success') == true) {
        try {
          await Kullanici.IslemLog(
            context,
            Genel.CihazId,
            'Duvar Kagidi Yapma',
            imageData.id,
          );
        } catch (logError) {
          // Log error should not block the user
          debugPrint('Log error: $logError');
        }

        String locationText = '';
        switch (wallpaperLocation) {
          case 1:
            locationText = 'ana ekrana';
            break;
          case 2:
            locationText = 'kilit ekranina';
            break;
          case 3:
            locationText = 'her iki ekrana';
            break;
        }

        if (mounted) {
          _showSuccessAlert(
              'Duvar kagidi $locationText basariyla ayarlandi!');
        }
      } else {
        if (mounted) {
          _showErrorAlert('Duvar kagidi ayarlanamadi');
        }
      }
    } catch (e) {
      debugPrint('Wallpaper set error: $e');
      if (mounted) {
        _showErrorAlert('Bir hata olustu: ${e.toString()}');
      }
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
  // Download flow
  // ---------------------------------------------------------------------------
  void _downloadImage() {
    if (_currentImageIndex >= _imageList.length) return;

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
      final DateTime now = DateTime.now();

      // Download image bytes
      final response = await Dio().get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final Uint8List imageBytes = Uint8List.fromList(response.data);

      // Request gallery permission
      final PermissionState ps =
          await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth && ps != PermissionState.limited) {
        _showErrorAlert('Galeriyi kaydetmek icin izin verilmedi.');
        return;
      }

      // Save to gallery
      final asset = await PhotoManager.editor.saveImage(
        imageBytes,
        filename: 'wallpaper_${now.millisecondsSinceEpoch}',
        title: 'wallpaper_${now.millisecondsSinceEpoch}',
      );

      if (asset != null) {
        try {
          await Kullanici.IslemLog(
            context,
            Genel.CihazId,
            'Download',
            imageData.id,
          );
        } catch (logError) {
          debugPrint('Download log error: $logError');
        }
        _showSuccessAlert('Resim basariyla indirildi!');
      } else {
        _showErrorAlert('Resim indirilemedi');
      }
    } catch (e) {
      _showErrorAlert('Bir hata olustu: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Alerts
  // ---------------------------------------------------------------------------
  void _showSuccessAlert(String message) {
    if (mounted) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        title: 'Basarili!',
        text: message,
        confirmBtnColor: Colors.teal,
      );
    }
  }

  void _showErrorAlert(String message) {
    if (mounted) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Hata!',
        text: message,
        confirmBtnColor: Colors.red,
      );
    }
  }
}
