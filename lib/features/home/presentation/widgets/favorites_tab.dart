import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Third party packages
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Favorites (Favorilerim) tab - grid view of bookmarked wallpaper images.
///
/// Extracted from the old Sayfalar.dart `_buildFavoritesPage` section.
/// Displays a 2-column grid of favorite images with a red heart badge.
/// Supports tap to navigate to detail, long-press context menu for
/// remove-favorite / set-wallpaper / download actions.
class FavoritesTab extends ConsumerStatefulWidget {
  const FavoritesTab({super.key});

  @override
  ConsumerState<FavoritesTab> createState() => FavoritesTabState();
}

class FavoritesTabState extends ConsumerState<FavoritesTab> {
  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------
  List<ImageList> _favoriteImages = [];
  bool _isProcessing = false;
  bool _isWallpaperProcessing = false;
  Offset _tapPosition = Offset.zero;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavoriteImages();
    });
  }

  // ---------------------------------------------------------------------------
  // Public API - called by parent when the favorites tab is selected
  // ---------------------------------------------------------------------------
  void refresh() {
    _loadFavoriteImages();
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------
  void _loadFavoriteImages() {
    final List<ImageList> favorites = [];

    for (final image in Genel.Resimler) {
      if (Yardimci.favori_resimler_Kontrol(image.id)) {
        favorites.add(image);
      }
    }

    favorites.shuffle(math.Random());

    if (mounted) {
      setState(() {
        _favoriteImages = favorites;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: [
          _favoriteImages.isEmpty
              ? _buildEmptyFavoritesView()
              : _buildFavoritesGrid(),
          if (_isProcessing) _buildProcessingOverlay(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty state
  // ---------------------------------------------------------------------------
  Widget _buildEmptyFavoritesView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 80,
                color: Colors.red.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Henuz favorilerinize resim eklemediniz',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.color
                        ?.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Begendigeniz resimleri cift tiklayarak favorilerinize ekleyin',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.5),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Favorites grid
  // ---------------------------------------------------------------------------
  Widget _buildFavoritesGrid() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _buildFavoriteImageCard(_favoriteImages[index]),
              childCount: _favoriteImages.length,
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Favorite image card
  // ---------------------------------------------------------------------------
  Widget _buildFavoriteImageCard(ImageList imageData) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToImageDetail(imageData),
        onLongPress: () => _showImageContextMenu(imageData),
        onTapDown: (details) => _storeTapPosition(details),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Wallpaper image
                CachedNetworkImage(
                  imageUrl: '${ayarlar.resimsunucusu}${imageData.yol}',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.teal),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                ),

                // Red heart badge (top-right)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
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
  // Navigation
  // ---------------------------------------------------------------------------
  void _navigateToImageDetail(ImageList imageData) {
    HapticFeedback.lightImpact();
    Genel.SecilenResimler = imageData;
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ImageDetay(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ).then((_) {
      // Refresh favorites when returning from detail in case user removed it
      _loadFavoriteImages();
    });
  }

  // ---------------------------------------------------------------------------
  // Context menu (long-press)
  // ---------------------------------------------------------------------------
  void _storeTapPosition(TapDownDetails details) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    setState(() {
      _tapPosition = referenceBox.globalToLocal(details.globalPosition);
    });
  }

  void _showImageContextMenu(ImageList imageData) async {
    HapticFeedback.lightImpact();
    final RenderObject? overlay =
        Overlay.of(context).context.findRenderObject();

    final result = await showMenu<String>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      position: RelativeRect.fromRect(
        Rect.fromLTWH(_tapPosition.dx, _tapPosition.dy, 30, 30),
        Rect.fromLTWH(
          0,
          0,
          overlay!.paintBounds.size.width,
          overlay.paintBounds.size.height,
        ),
      ),
      items: [
        PopupMenuItem<String>(
          value: 'remove_favorite',
          child: Row(
            children: [
              const Icon(Icons.favorite_border, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              Text(
                'Favorilerden Cikar',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'set_wallpaper',
          child: Row(
            children: [
              const Icon(Icons.wallpaper, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              Text(
                'Duvar Kagidi Yap',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'download',
          child: Row(
            children: [
              const Icon(Icons.download, color: Colors.green, size: 20),
              const SizedBox(width: 12),
              Text(
                'Indir',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );

    if (result != null) {
      _handleContextMenuAction(result, imageData);
    }
  }

  void _handleContextMenuAction(String action, ImageList imageData) {
    switch (action) {
      case 'remove_favorite':
        _removeFavorite(imageData);
        break;
      case 'set_wallpaper':
        _setWallpaperWithConfirmation(imageData);
        break;
      case 'download':
        _downloadImageData(imageData);
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Remove favorite
  // ---------------------------------------------------------------------------
  Future<void> _removeFavorite(ImageList imageData) async {
    HapticFeedback.mediumImpact();
    try {
      await ImageList.FavorilereEkle(context, imageData.id);
      Yardimci.favori_resim_ekle(imageData.id.toString());
      _loadFavoriteImages();
    } catch (e) {
      _showErrorAlert('Islem tamamlanamadi');
    }
  }

  // ---------------------------------------------------------------------------
  // Set wallpaper flow
  // ---------------------------------------------------------------------------
  void _setWallpaperWithConfirmation(ImageList imageData) {
    if (_isWallpaperProcessing) return;

    HapticFeedback.lightImpact();
    if (ayarlar.odullureklamacikmi == '1') {
      _showRewardedAdForWallpaper(imageData);
    } else {
      _showWallpaperLocationDialog(imageData);
    }
  }

  void _showRewardedAdForWallpaper(ImageList imageData) {
    if (Genel.reklam == null) {
      _showWallpaperLocationDialog(imageData);
      KategoriList.ReklamYukle(context);
    } else {
      Genel.reklam?.show(onUserEarnedReward: (ad, rewardItem) {
        ad.dispose();
        _showWallpaperLocationDialog(imageData);
        KategoriList.ReklamYukle(context);
      });
    }
  }

  void _showWallpaperLocationDialog(ImageList imageData) async {
    final location = await WallpaperLocationDialog.show(context);
    if (location != null) {
      _performSetWallpaper(imageData, location.value);
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
  void _downloadImageData(ImageList imageData) {
    HapticFeedback.lightImpact();
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
