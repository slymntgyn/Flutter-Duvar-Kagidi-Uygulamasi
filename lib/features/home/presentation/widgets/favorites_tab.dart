
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';
import 'package:senseriduvarkagidi/core/utils/gallery_saver.dart';
import 'package:quickalert/quickalert.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';

import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';
import 'package:senseriduvarkagidi/ek/ayarlar.dart';
import 'package:senseriduvarkagidi/core/di/providers.dart';
import 'package:senseriduvarkagidi/core/utils/error_message_mapper.dart';
import 'package:senseriduvarkagidi/core/widgets/error_view.dart';
import 'package:senseriduvarkagidi/core/widgets/loading_overlay.dart';
import 'package:senseriduvarkagidi/model/image.dart';
import 'package:senseriduvarkagidi/model/kullanici_model.dart';
import 'package:senseriduvarkagidi/model/kategoriler.dart';
import 'package:senseriduvarkagidi/core/widgets/wallpaper_location_dialog.dart';
import 'package:senseriduvarkagidi/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:senseriduvarkagidi/features/wallpaper/domain/entities/wallpaper_image.dart';
import 'package:senseriduvarkagidi/features/wallpaper/presentation/providers/wallpaper_provider.dart';
import 'package:senseriduvarkagidi/features/wallpaper/presentation/screens/image_detail_screen.dart';

enum _SortMode { newest, oldest }

/// Favoriler tab — Pro UI.
/// Pinterest Masonry grid, swipe-to-delete + undo, Lottie empty state, sort.
class FavoritesTab extends ConsumerStatefulWidget {
  const FavoritesTab({super.key});

  @override
  ConsumerState<FavoritesTab> createState() => FavoritesTabState();
}

class FavoritesTabState extends ConsumerState<FavoritesTab>
    with TickerProviderStateMixin {
  bool _isProcessing = false;
  bool _isWallpaperProcessing = false;
  _SortMode _sortMode = _SortMode.newest;
  bool _showSwipeHint = true;
  String _processingMessage = 'Islem yapiliyor...';
  String? _processingStep;
  double? _downloadProgress;

  late final AnimationController _emptyAnimController;

  @override
  void initState() {
    super.initState();
    _emptyAnimController = AnimationController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncFavoritesProviderFromLegacyCache();
    });
  }

  @override
  void dispose() {
    _emptyAnimController.dispose();
    super.dispose();
  }

  void refresh() => ref.invalidate(wallpapersProvider);

  void _syncFavoritesProviderFromLegacyCache() {
    final ids = Genel.favoriteImages
        .map((e) => int.tryParse(e) ?? 0)
        .where((id) => id > 0)
        .toList();
    ref.read(favoritesProvider.notifier).loadFavorites(ids);
  }

  List<ImageList> _toLegacyImages(List<WallpaperImage> wallpapers) {
    return wallpapers
        .map((w) => ImageList(
              w.id,
              w.path,
              w.categoryIds.join(';'),
              isPro: w.isPro,
            ))
        .toList();
  }

  List<ImageList> _buildDisplayImages(
      List<WallpaperImage> wallpapers, List<int> favoriteIds) {
    final allImages = _toLegacyImages(wallpapers);
    final sorted =
        allImages.where((img) => favoriteIds.contains(img.id)).toList();

    if (_sortMode == _SortMode.newest) {
      sorted.sort((a, b) => b.id.compareTo(a.id));
    } else {
      sorted.sort((a, b) => a.id.compareTo(b.id));
    }

    return sorted;
  }

  void _showSortMenu() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .scaffoldBackgroundColor
                  .withValues(alpha: 0.9),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2)),
                ),
                Text('Siralama',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _sortTile(ctx, Icons.arrow_downward_rounded, 'En Yeni',
                    _SortMode.newest),
                _sortTile(ctx, Icons.arrow_upward_rounded, 'En Eski',
                    _SortMode.oldest),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sortTile(
      BuildContext ctx, IconData icon, String label, _SortMode mode) {
    final isSelected = _sortMode == mode;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.red : null),
      title: Text(label,
          style: TextStyle(
              color: isSelected ? Colors.red : null,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: Colors.red)
          : null,
      onTap: () {
        setState(() => _sortMode = mode);
        Navigator.pop(ctx);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallpapersAsync = ref.watch(wallpapersProvider);
    final favoriteIds = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          wallpapersAsync.when(
            loading: () => const LoadingOverlay(
              message: 'Favoriler yukleniyor...',
            ),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ErrorView(
                  message: mapErrorMessage(error),
                  onRetry: _retryWallpapers,
                ),
              ),
            ),
            data: (wallpapers) {
              final displayImages =
                  _buildDisplayImages(wallpapers, favoriteIds);
              return displayImages.isEmpty
                  ? _buildEmptyState()
                  : _buildFavoritesContent(displayImages);
            },
          ),
          if (_isProcessing) _buildProcessingOverlay(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Recovery
  // ---------------------------------------------------------------------------

  Future<void> _retryWallpapers() async {
    ref.invalidate(wallpapersProvider);
    await ref.read(wallpapersProvider.future);
  }

  // ---------------------------------------------------------------------------
  // Empty state with Lottie animation
  // ---------------------------------------------------------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/like2.json',
              width: 180,
              height: 180,
              controller: _emptyAnimController,
              onLoaded: (comp) {
                _emptyAnimController
                  ..duration = comp.duration
                  ..repeat();
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Henuz favori eklemediniz',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Cift tikla ya da favori butonuna bas\nresimlerini buraya ekle',
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
  // Favorites content with header + grid
  // ---------------------------------------------------------------------------
  Widget _buildFavoritesContent(List<ImageList> displayImages) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(wallpapersProvider);
        await ref.read(wallpapersProvider.future);
      },
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Favorilerim',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${displayImages.length} resim',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (_showSwipeHint)
                      TextButton.icon(
                        onPressed: () {
                          setState(() => _showSwipeHint = false);
                        },
                        icon: const Icon(Icons.swipe_left_rounded, size: 16),
                        label: const Text('Sola kaydir'),
                      ),
                    IconButton(
                      onPressed: _showSortMenu,
                      icon: const Icon(Icons.sort_rounded),
                      tooltip: 'Sirala',
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Masonry grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childCount: displayImages.length,
              itemBuilder: (context, index) =>
                  _buildFavoriteCard(displayImages[index], index),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Favorite card with swipe-to-delete
  // ---------------------------------------------------------------------------
  Widget _buildFavoriteCard(ImageList imageData, int index) {
    final isLong = index % 3 == 0;
    final height = isLong ? 260.0 : 200.0;
    final heroTag = 'fav_${imageData.id}';
    final imageUrl = LegacyAyarlar.buildImageUrl(imageData.yol);

    return Dismissible(
      key: ValueKey(imageData.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        final bool shouldDismiss = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Favoriden cikarilsin mi?'),
                content: const Text(
                    'Bu resmi favorilerden kaldirmak istiyor musun?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Iptal'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Kaldir'),
                  ),
                ],
              ),
            ) ??
            false;

        return shouldDismiss;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) => _removeFavoriteWithUndo(imageData),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (ctx, anim, secAnim) => ImageDetailScreen(
                  image: imageData,
                  heroTag: heroTag,
                ),
                transitionsBuilder: (ctx, anim, secAnim, child) {
                  final Animation<double> fadeAnimation = CurvedAnimation(
                    parent: anim,
                    curve: Curves.easeOut,
                  );
                  return FadeTransition(opacity: fadeAnimation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 280),
              ),
            ).then((_) => _syncFavoritesProviderFromLegacyCache());
          },
          onLongPress: () => _showContextMenu(imageData),
          borderRadius: BorderRadius.circular(16),
          child: Hero(
            tag: heroTag,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imageUrl.isEmpty
                        ? Container(
                            color: Colors.grey[300],
                            child:
                                const Icon(Icons.image_not_supported_outlined),
                          )
                        : CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: Colors.grey[300]),
                            errorWidget: (context, url, error) =>
                                Container(color: Colors.grey[300]),
                          ),
                    // Favorite badge
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
                                color: Colors.red.withValues(alpha: 0.4),
                                blurRadius: 8)
                          ],
                        ),
                        child: const Icon(Icons.favorite,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
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
    return LoadingOverlay(
      message: _processingMessage,
      stepLabel: _processingStep,
      progress: _downloadProgress,
    );
  }

  // ---------------------------------------------------------------------------
  // Remove with undo
  // ---------------------------------------------------------------------------
  void _removeFavoriteWithUndo(ImageList imageData) async {
    final removed = imageData;
    try {
      await ImageList.toggleFavorite(context, imageData.id);
      Yardimci.toggleFavoriteImage(imageData.id.toString());
      _syncFavoritesProviderFromLegacyCache();
    } catch (e) {
      debugPrint('Remove favorite error: $e');
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Favorilerden kaldirildi'),
          backgroundColor: Colors.grey[800],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'Geri Al',
            textColor: Colors.white,
            onPressed: () async {
              try {
                await ImageList.toggleFavorite(context, removed.id);
                Yardimci.toggleFavoriteImage(removed.id.toString());
                _syncFavoritesProviderFromLegacyCache();
              } catch (_) {}
            },
          ),
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Context menu (long press)
  // ---------------------------------------------------------------------------
  void _showContextMenu(ImageList imageData) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .scaffoldBackgroundColor
                  .withValues(alpha: 0.9),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2)),
                ),
                ListTile(
                  leading: const Icon(Icons.favorite_border, color: Colors.red),
                  title: const Text('Favorilerden Cikar'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _removeFavoriteWithUndo(imageData);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.wallpaper, color: Colors.blue),
                  title: const Text('Duvar Kagidi Yap'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _setWallpaperWithConfirmation(imageData);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download, color: Colors.green),
                  title: const Text('Indir'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _downloadImageData(imageData);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Set wallpaper
  // ---------------------------------------------------------------------------
  void _setWallpaperWithConfirmation(ImageList imageData) {
    if (_isWallpaperProcessing) return;
    HapticFeedback.lightImpact();
    if (LegacyAyarlar.rewardedAdsEnabled == '1') {
      _showRewardedAdForWallpaper(imageData);
    } else {
      _showWallpaperLocationDialog(imageData);
    }
  }

  void _showRewardedAdForWallpaper(ImageList imageData) {
    if (Genel.rewardedAd == null) {
      _showWallpaperLocationDialog(imageData);
      KategoriList.loadRewardedAd(context);
    } else {
      Genel.rewardedAd?.show(onUserEarnedReward: (ad, rewardItem) {
        ad.dispose();
        _showWallpaperLocationDialog(imageData);
        KategoriList.loadRewardedAd(context);
      });
    }
  }

  void _showWallpaperLocationDialog(ImageList imageData) async {
    final location = await WallpaperLocationDialog.show(context);
    if (!mounted) return;
    if (location != null) _performSetWallpaper(imageData, location.value);
  }

  Future<void> _performSetWallpaper(
      ImageList imageData, int wallpaperLocation) async {
    if (_isWallpaperProcessing) return;
    try {
      setState(() {
        _isWallpaperProcessing = true;
        _isProcessing = true;
        _processingMessage = 'Duvar kagidi ayarlaniyor...';
        _processingStep = 'Resim hazirlaniyor';
        _downloadProgress = null;
      });
      final url = LegacyAyarlar.buildImageUrl(imageData.yol);
      final file = await DefaultCacheManager().getSingleFile(url);
      if (mounted) {
        setState(() {
          _processingStep = 'Cihaza uygulaniyor';
        });
      }
      final result =
          await WallpaperManagerPlus().setWallpaper(file, wallpaperLocation);
      if (!mounted) return;
      if (result == 'Wallpaper set successfully' ||
          (result ?? '').contains('success')) {
        try {
          await Kullanici.logAction(
              context, Genel.deviceId, 'Duvar Kagidi Yapma', imageData.id);
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
          _processingMessage = 'Islem yapiliyor...';
          _processingStep = null;
          _downloadProgress = null;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Download
  // ---------------------------------------------------------------------------
  void _downloadImageData(ImageList imageData) {
    HapticFeedback.lightImpact();
    if (LegacyAyarlar.rewardedAdsEnabled == '1') {
      _showRewardedAdForDownload(imageData);
    } else {
      _download(imageData);
    }
  }

  void _showRewardedAdForDownload(ImageList imageData) {
    if (Genel.rewardedAd == null) {
      _download(imageData);
      KategoriList.loadRewardedAd(context);
    } else {
      Genel.rewardedAd?.show(onUserEarnedReward: (ad, rewardItem) {
        ad.dispose();
        _download(imageData);
        KategoriList.loadRewardedAd(context);
      });
    }
  }

  Future<void> _download(ImageList imageData) async {
    try {
      setState(() {
        _isProcessing = true;
        _processingMessage = 'Resim indiriliyor...';
        _processingStep = 'Dosya indiriliyor';
        _downloadProgress = null;
      });
      final imageUrl = LegacyAyarlar.buildImageUrl(imageData.yol);
      final now = DateTime.now();
      final response = await ref.read(dioClientProvider).externalGet<List<int>>(
        imageUrl,
        responseType: ResponseType.bytes,
        onReceiveProgress: (received, total) {
          if (!mounted || total <= 0) return;
          setState(() {
            _downloadProgress = received / total;
            _processingStep = 'Galeriye kaydetmeye hazirlaniyor';
          });
        },
      );
      final List<int> downloadedBytes = response.data ?? <int>[];
      final imageBytes = Uint8List.fromList(downloadedBytes);
      final saved = await GallerySaver.saveImage(imageBytes,
          name: 'wallpaper_${now.millisecondsSinceEpoch}');
      if (!mounted) return;
      if (saved) {
        try {
          await Kullanici.logAction(
              context, Genel.deviceId, 'Download', imageData.id);
        } catch (_) {}
        _showSuccessAlert('Resim basariyla indirildi!');
      } else {
        _showErrorAlert('Galeriye kaydetmek icin izin verilmedi veya bir hata olustu.');
      }
    } catch (e) {
      _showErrorAlert('Bir hata olustu: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _processingMessage = 'Islem yapiliyor...';
          _processingStep = null;
          _downloadProgress = null;
        });
      }
    }
  }

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


