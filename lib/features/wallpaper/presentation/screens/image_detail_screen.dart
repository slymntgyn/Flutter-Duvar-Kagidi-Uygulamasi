import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:senseriduvarkagidi/core/di/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:quickalert/quickalert.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';

import 'package:senseriduvarkagidi/ek/ayarlar.dart';
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';
import 'package:senseriduvarkagidi/model/image.dart';
import 'package:senseriduvarkagidi/model/KullaniciModel.dart';
import 'package:senseriduvarkagidi/core/widgets/wallpaper_location_dialog.dart';
import 'package:senseriduvarkagidi/core/widgets/loading_overlay.dart';

/// Duvar kagidi detay ekrani.
/// Hero animasyonu, pinch-to-zoom, DraggableScrollableSheet aksiyon paneli.
class ImageDetailScreen extends ConsumerStatefulWidget {
  final ImageList image;
  final String heroTag;

  const ImageDetailScreen({
    super.key,
    required this.image,
    required this.heroTag,
  });

  @override
  ConsumerState<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends ConsumerState<ImageDetailScreen>
    with TickerProviderStateMixin {
  bool _isFavorite = false;
  bool _isProcessing = false;
  bool _isWallpaperProcessing = false;
  String _processingMessage = 'Islem yapiliyor...';
  String? _processingStep;
  double? _downloadProgress;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  List<ImageList> _similarImages = [];
  final ScrollController _similarScrollController = ScrollController();
  final int _similarLeadIndex = 1;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
    _isFavorite = Yardimci.favori_resimler_Kontrol(widget.image.id);
    _similarScrollController.addListener(() {
      final index = ((_similarScrollController.offset / 98).round() + 1)
          .clamp(1, _similarImages.isEmpty ? 1 : _similarImages.length);
      if (mounted && index != _similarLeadIndex) {
        setState(() => _similarLeadIndex = index);
      }
    });
    _loadSimilarImages();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _sheetController.dispose();
    _similarScrollController.dispose();
    super.dispose();
  }

  void _loadSimilarImages() {
    final similar = Genel.Resimler.where((img) =>
            img.kategori == widget.image.kategori && img.id != widget.image.id)
        .take(10)
        .toList();
    setState(() => _similarImages = similar);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Full-screen zoomable image
          _buildZoomableImage(),

          // Top gradient + AppBar actions
          _buildTopGradient(),

          // Action sheet
          _buildActionSheet(),

          // Processing overlay
          if (_isProcessing) _buildProcessingOverlay(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Zoomable image
  // ---------------------------------------------------------------------------

  Widget _buildZoomableImage() {
    final imageUrl = ayarlar.buildImageUrl(widget.image.yol);
    return FadeTransition(
      opacity: _fadeAnimation,
      child: InteractiveViewer(
        minScale: 0.8,
        maxScale: 4.0,
        child: Hero(
          tag: widget.heroTag,
          child: imageUrl.isEmpty
              ? const Center(
                  child: Icon(Icons.image_not_supported_outlined,
                      color: Colors.white54, size: 48),
                )
              : CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => const _ImageLoadingSkeleton(),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(Icons.broken_image_outlined,
                        color: Colors.white54, size: 48),
                  ),
                ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top gradient overlay + back/share buttons
  // ---------------------------------------------------------------------------

  Widget _buildTopGradient() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _buildIconButton(
                  icon: Icons.arrow_back_ios_rounded,
                  semanticLabel: 'Geri don',
                  onTap: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                _buildIconButton(
                  icon: Icons.share_rounded,
                  semanticLabel: 'Resmi paylas',
                  onTap: _shareImage,
                ),
                const SizedBox(width: 8),
                _buildIconButton(
                  icon: _isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: _isFavorite ? Colors.red : Colors.white,
                  semanticLabel:
                      _isFavorite ? 'Favorilerden cikar' : 'Favorilere ekle',
                  onTap: _toggleFavorite,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    Color color = Colors.white,
    required String semanticLabel,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Semantics(
          button: true,
          label: semanticLabel,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            child: Container(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Draggable action sheet
  // ---------------------------------------------------------------------------

  Widget _buildActionSheet() {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.18,
      minChildSize: 0.12,
      maxChildSize: 0.65,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    // Handle
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Action buttons row
                    _buildActionButtons(),

                    // Divider
                    Divider(
                      color: Colors.white.withValues(alpha: 0.1),
                      height: 24,
                      indent: 24,
                      endIndent: 24,
                    ),

                    // Image info
                    _buildImageInfo(),

                    // Similar wallpapers
                    if (_similarImages.isNotEmpty) ...[
                      Divider(
                        color: Colors.white.withValues(alpha: 0.1),
                        height: 24,
                        indent: 24,
                        endIndent: 24,
                      ),
                      _buildSimilarImages(),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionChip(
            icon: _isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            label: _isFavorite ? 'Favoride' : 'Favori',
            color: _isFavorite ? Colors.red : Colors.white,
            semanticLabel:
                _isFavorite ? 'Favorilerden cikar' : 'Favorilere ekle',
            onTap: _toggleFavorite,
          ),
          _buildActionChip(
            icon: Icons.wallpaper_rounded,
            label: 'Duvar\nKagidi',
            color: Colors.blue,
            semanticLabel: 'Duvar kagidi yap',
            onTap: _setWallpaperWithConfirmation,
          ),
          _buildActionChip(
            icon: Icons.download_rounded,
            label: 'Indir',
            color: Colors.green,
            semanticLabel: 'Resmi indir',
            onTap: _downloadImage,
          ),
          _buildActionChip(
            icon: Icons.share_rounded,
            label: 'Paylas',
            color: Colors.purple,
            semanticLabel: 'Resmi paylas',
            onTap: _shareImage,
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required Color color,
    required String semanticLabel,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resim Bilgisi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(Icons.tag_rounded, '#${widget.image.id}'),
              const SizedBox(width: 8),
              _buildInfoChip(
                  Icons.category_rounded,
                  widget.image.kategori.isNotEmpty
                      ? 'Kategori ${widget.image.kategori}'
                      : 'Genel'),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.hd_rounded, '4K HD'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Benzer Duvar Kagitlari',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Text(
                  '$_similarLeadIndex/${_similarImages.length}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            controller: _similarScrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _similarImages.length,
            itemBuilder: (context, index) {
              final img = _similarImages[index];
              final similarImageUrl = ayarlar.buildImageUrl(img.yol);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ImageDetailScreen(
                        image: img,
                        heroTag: 'similar_${img.id}',
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: 'similar_${img.id}',
                  child: Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: similarImageUrl.isEmpty
                          ? Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.white54),
                            )
                          : CachedNetworkImage(
                              imageUrl: similarImageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[800],
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[800],
                                child: const Icon(Icons.error,
                                    color: Colors.white54),
                              ),
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _toggleFavorite() async {
    HapticFeedback.selectionClick();
    try {
      await ImageList.FavorilereEkle(context, widget.image.id);
      if (!mounted) return;
      setState(() {
        _isFavorite = !_isFavorite;
      });
      Yardimci.favori_resim_ekle(widget.image.id.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite ? 'Favorilere eklendi' : 'Favorilerden cikarildi',
            ),
            backgroundColor: _isFavorite ? Colors.green : Colors.grey[700],
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Toggle favorite error: $e');
    }
  }

  void _shareImage() {
    final imageUrl = ayarlar.buildImageUrl(widget.image.yol);
    Share.share(
      '4K HD Duvar Kagidi:\n$imageUrl',
      subject: '4K-HD Duvar Kagidi #${widget.image.id}',
    );
  }

  void _setWallpaperWithConfirmation() {
    if (_isWallpaperProcessing) return;
    _showWallpaperLocationDialog();
  }

  void _showWallpaperLocationDialog() async {
    final location = await WallpaperLocationDialog.show(context);
    if (!mounted) return;
    if (location != null) {
      _performSetWallpaper(location.value);
    }
  }

  Future<void> _performSetWallpaper(int wallpaperLocation) async {
    if (_isWallpaperProcessing) return;
    try {
      setState(() {
        _isWallpaperProcessing = true;
        _isProcessing = true;
        _processingMessage = 'Duvar kagidi ayarlaniyor...';
        _processingStep = 'Resim hazirlaniyor';
        _downloadProgress = null;
      });

      final url = ayarlar.buildImageUrl(widget.image.yol);
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
          await Kullanici.IslemLog(
              context, Genel.CihazId, 'Duvar Kagidi Yapma', widget.image.id);
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

  Future<void> _downloadImage() async {
    try {
      setState(() {
        _isProcessing = true;
        _processingMessage = 'Resim indiriliyor...';
        _processingStep = 'Dosya indiriliyor';
        _downloadProgress = null;
      });

      final imageUrl = ayarlar.buildImageUrl(widget.image.yol);
      final now = DateTime.now();

      final response = await ref.read(dioClientProvider).externalGet<List<int>>(
        imageUrl,
        responseType: ResponseType.bytes,
        onReceiveProgress: (received, total) {
          if (!mounted || total <= 0) return;
          final ratio = received / total;
          final percent = (ratio * 100).clamp(0, 100).toInt();
          setState(() {
            _downloadProgress = ratio;
            _processingStep = 'Indiriliyor: %$percent';
          });
        },
      );
      final List<int> downloadedBytes = response.data ?? <int>[];
      final imageBytes = Uint8List.fromList(downloadedBytes);

      final ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth && ps != PermissionState.limited) {
        _showErrorAlert('Galeriyi kaydetmek icin izin verilmedi.');
        return;
      }

      final asset = await PhotoManager.editor.saveImage(
        imageBytes,
        filename: 'wallpaper_${now.millisecondsSinceEpoch}',
        title: 'wallpaper_${now.millisecondsSinceEpoch}',
      );
      if (!mounted) return;

      if (asset.id.isNotEmpty) {
        try {
          await Kullanici.IslemLog(
              context, Genel.CihazId, 'Download', widget.image.id);
        } catch (_) {}
        _showSuccessAlert('Resim basariyla indirildi!');
      } else {
        _showErrorAlert('Resim indirilemedi');
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
      confirmBtnColor: Colors.green,
    );
  }

  void _showErrorAlert(String message) {
    if (!mounted) return;
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Hata!',
      text: message,
      confirmBtnColor: Colors.red,
    );
  }
}

class _ImageLoadingSkeleton extends StatefulWidget {
  const _ImageLoadingSkeleton();

  @override
  State<_ImageLoadingSkeleton> createState() => _ImageLoadingSkeletonState();
}

class _ImageLoadingSkeletonState extends State<_ImageLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -1.4, end: 1.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                Colors.white.withValues(alpha: 0.05),
                Colors.white.withValues(alpha: 0.16),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: const Center(
            child: Icon(Icons.image_rounded, color: Colors.white24, size: 38),
          ),
        );
      },
    );
  }
}
