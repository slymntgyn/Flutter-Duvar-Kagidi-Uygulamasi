import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

// Third party packages
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:wallpaper_manager_plus/wallpaper_manager_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hyper_effects/hyper_effects.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';

// Local imports
import 'package:senseriduvarkagidi/Screens/ImageDetay.dart';
import 'package:senseriduvarkagidi/Screens/Sayfalar.dart';
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:senseriduvarkagidi/ek/ayarlar.dart';
import 'package:senseriduvarkagidi/ek/widgets.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';
import 'package:senseriduvarkagidi/model/Ayarlar.dart';
import 'package:senseriduvarkagidi/model/kategoriler.dart';
import 'package:senseriduvarkagidi/model/KullaniciModel.dart';
import 'package:senseriduvarkagidi/model/image.dart';

class KategoriResim extends StatefulWidget {
  const KategoriResim({Key? key}) : super(key: key);

  @override
  State<KategoriResim> createState() => _KategoriResimState();
}

class _KategoriResimState extends State<KategoriResim>
    with TickerProviderStateMixin {

  // Controllers and Animation
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  // Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  // State variables
  bool _isLoading = true;
  bool _isProcessing = false;
  Offset _tapPosition = Offset.zero;

  // Data lists
  List<Widget> _imageWidgets = [];
  List<ImageList> _categoryImages = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeBannerAd();
    _loadCategoryImages();
  }

  void _initializeControllers() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _initializeBannerAd() {
    if (Platform.isAndroid || Platform.isIOS) {
      _bannerAd = BannerAd(
        adUnitId: _getBannerAdUnitId(),
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (_) {
            if (mounted) {
              setState(() {
                _isBannerAdReady = true;
              });
            }
          },
          onAdFailedToLoad: (ad, err) {
            print('Failed to load a banner ad: ${err.message}');
            _isBannerAdReady = false;
            ad.dispose();
          },
        ),
      );
      _bannerAd?.load();
    }
  }

  String _getBannerAdUnitId() {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            // Banner Ad
            if (_isBannerAdReady && _bannerAd != null)
              Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            Expanded(
              child: Stack(
                children: [
                  _buildContent(),
                  if (_isProcessing) _buildProcessingOverlay(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final categoryName = Genel.Kategoriler.isNotEmpty &&
        int.tryParse(Genel.SecilenKategori) != null &&
        int.parse(Genel.SecilenKategori) < Genel.Kategoriler.length
        ? Genel.Kategoriler[int.parse(Genel.SecilenKategori)].kategori
        : "Kategori";

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _navigateBack(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.teal,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    categoryName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ),
              ),
              // Category info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      color: Colors.teal,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${_categoryImages.length}",
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingView();
    }

    if (_imageWidgets.isEmpty) {
      return _buildEmptyView();
    }

    return FadeTransition(
      opacity: _fadeController,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _imageWidgets[index],
                childCount: _imageWidgets.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Resimler yükleniyor...",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).textTheme.titleMedium?.color?.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: Colors.orange.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Bu kategoride henüz duvar kağıdı yok",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).textTheme.titleMedium?.color?.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Çok yakında yeni resimler eklenecek",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
              const SizedBox(height: 16),
              Text(
                "İşlem yapılıyor...",
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

  void _loadCategoryImages() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    _categoryImages.clear();
    _imageWidgets.clear();

    final selectedCategoryId = Genel.Kategoriler.isNotEmpty &&
        int.tryParse(Genel.SecilenKategori) != null &&
        int.parse(Genel.SecilenKategori) < Genel.Kategoriler.length
        ? Genel.Kategoriler[int.parse(Genel.SecilenKategori)].id.toString()
        : null;

    if (selectedCategoryId != null) {
      for (var image in Genel.Resimler) {
        List<String> kategoriler = image.kategori.split(';');

        if (kategoriler.contains(selectedCategoryId)) {
          _categoryImages.add(image);
          _imageWidgets.add(_buildImageWidget(image));
        }
      }
    }

    setState(() {
      _isLoading = false;
    });

    // Start fade animation
    _fadeController.forward();
  }

  Widget _buildImageWidget(ImageList imageData) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToImageDetail(imageData),
        onTapDown: (details) => _getTapPosition(details),
        onLongPress: () => _showImageContextMenu(imageData),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedBuilder(
          animation: _scaleController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 - (_scaleController.value * 0.05),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Image
                      CachedNetworkImage(
                        imageUrl: "${ayarlar.resimsunucusu}${imageData.yol}",
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        memCacheWidth: 400,
                        memCacheHeight: 600,
                        placeholder: (context, url) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.grey[200]!,
                                Colors.grey[300]!,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                                  strokeWidth: 2,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Yükleniyor...",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 32,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Yüklenemedi",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Gradient overlay for better text visibility
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),

                      // Favorite indicator
                      if (Yardimci.favori_resimler_Kontrol(imageData.id))
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
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),

                      // Action overlay on press
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _navigateToImageDetail(imageData),
                            onTapDown: (details) => _getTapPosition(details),
                            onLongPress: () => _showImageContextMenu(imageData),
                            borderRadius: BorderRadius.circular(16),
                            splashColor: Colors.white.withOpacity(0.2),
                            highlightColor: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).scrollTransition((context, widget, event) {
                return widget
                    .blur(event.phase == ScrollPhase.identity ? 0 : 2)
                    .scale(event.phase == ScrollPhase.identity ? 1 : 0.98);
              }),
            );
          },
        ),
      ),
    );
  }

  void _navigateBack() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => Sayfalar(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(-1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

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
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _getTapPosition(TapDownDetails details) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    setState(() {
      _tapPosition = referenceBox.globalToLocal(details.globalPosition);
    });
  }

  void _showImageContextMenu(ImageList imageData) async {
    HapticFeedback.lightImpact();
    final RenderObject? overlay = Overlay.of(context)?.context.findRenderObject();

    final result = await showMenu(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).cardColor,
      elevation: 8,
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
        PopupMenuItem(
          value: Yardimci.favori_resimler_Kontrol(imageData.id)
              ? 'remove_favorite'
              : 'add_favorite',
          child: Row(
            children: [
              Icon(
                Yardimci.favori_resimler_Kontrol(imageData.id)
                    ? Icons.favorite_border_rounded
                    : Icons.favorite_rounded,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                Yardimci.favori_resimler_Kontrol(imageData.id)
                    ? 'Favorilerden Çıkar'
                    : 'Favorilere Ekle',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'set_wallpaper',
          child: Row(
            children: [
              Icon(Icons.wallpaper_rounded, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              Text(
                'Duvar Kağıdı Yap',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'download',
          child: Row(
            children: [
              Icon(Icons.download_rounded, color: Colors.green, size: 20),
              const SizedBox(width: 12),
              Text(
                'İndir',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    _handleContextMenuAction(result, imageData);
  }

// KategoriResim.dart dosyasında _setWallpaperWithConfirmation metodunu değiştirin:

  void _setWallpaperWithConfirmation(ImageList imageData) {
    HapticFeedback.lightImpact();
    _showWallpaperLocationDialog(imageData);
  }

  void _showWallpaperLocationDialog(ImageList imageData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                  if (ayarlar.odullureklamacikmi == "1") {
                    _showRewardedAdForAction(() => _performSetWallpaper(imageData, WallpaperManagerPlus.lockScreen));
                  } else {
                    _performSetWallpaper(imageData, WallpaperManagerPlus.lockScreen);
                  }
                },
              ),
              const SizedBox(height: 8),
              _buildWallpaperOption(
                icon: Icons.home_outlined,
                title: "Ana Ekran",
                subtitle: "Sadece ana ekranda görünür",
                onTap: () {
                  Navigator.of(context).pop();
                  if (ayarlar.odullureklamacikmi == "1") {
                    _showRewardedAdForAction(() => _performSetWallpaper(imageData, WallpaperManagerPlus.homeScreen));
                  } else {
                    _performSetWallpaper(imageData, WallpaperManagerPlus.homeScreen);
                  }
                },
              ),
              const SizedBox(height: 8),
              _buildWallpaperOption(
                icon: Icons.phone_android_rounded,
                title: "Her İki Ekran",
                subtitle: "Hem kilit hem ana ekranda görünür",
                onTap: () {
                  Navigator.of(context).pop();
                  if (ayarlar.odullureklamacikmi == "1") {
                    _showRewardedAdForAction(() => _performSetWallpaper(imageData, WallpaperManagerPlus.bothScreens));
                  } else {
                    _performSetWallpaper(imageData, WallpaperManagerPlus.bothScreens);
                  }
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

// _performSetWallpaper metodunu güncelleyin:
  Future<void> _performSetWallpaper(ImageList imageData, int wallpaperLocation) async {
    try {
      setState(() => _isProcessing = true);

      final url = "${ayarlar.resimsunucusu}${imageData.yol}";
      final file = await DefaultCacheManager().getSingleFile(url);

      final result = await WallpaperManagerPlus().setWallpaper(file, wallpaperLocation);

      if (result!.isEmpty) {
        await Kullanici.IslemLog(
          context,
          Genel.CihazId,
          "Duvar Kagidi Yapma",
          imageData.id,
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

// _handleContextMenuAction metodunu güncelleyin:
  void _handleContextMenuAction(String? action, ImageList imageData) {
    switch (action) {
      case 'add_favorite':
      case 'remove_favorite':
        _toggleFavorite(imageData.id);
        break;
      case 'set_wallpaper':
        _setWallpaperWithConfirmation(imageData);
        break;
      case 'download':
        _downloadImage(imageData);
        break;
    }
  }


  void _downloadImage(ImageList imageData) {
    if (ayarlar.odullureklamacikmi == "1") {
      _showRewardedAdForAction(() => _performDownload(imageData));
    } else {
      _performDownload(imageData);
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

  Future<void> _performDownload(ImageList imageData) async {
    try {
      setState(() => _isProcessing = true);

      final imageUrl = "${ayarlar.resimsunucusu}${imageData.yol}";
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
      );

      if (asset != null) {
        // 4️⃣ İşlem log kaydı
        await Kullanici.IslemLog(context, Genel.CihazId, "Download", imageData.id);
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



  Future<void> _toggleFavorite(int imageId) async {
    try {
      await ImageList.FavorilereEkle(context, imageId);
      Yardimci.favori_resim_ekle(imageId.toString());

      // Update UI immediately
      setState(() {
        // Trigger rebuild of image widgets to update favorite indicator
        _imageWidgets.clear();
        for (var image in _categoryImages) {
          _imageWidgets.add(_buildImageWidget(image));
        }
      });

      // Show feedback
      final message = Yardimci.favori_resimler_Kontrol(imageId)
          ? "Favorilere eklendi"
          : "Favorilerden çıkarıldı";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      _showErrorAlert("İşlem gerçekleştirilemedi");
    }
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