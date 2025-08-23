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
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hyper_effects/hyper_effects.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:stylish_bottom_bar/model/bar_items.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

// Local imports
import 'package:senseriduvarkagidi/Screens/ImageDetay.dart';
import 'package:senseriduvarkagidi/Screens/KategoriResim.dart';
import 'package:senseriduvarkagidi/model/Ayarlar.dart';
import 'package:senseriduvarkagidi/model/kategoriler.dart';
import 'package:senseriduvarkagidi/theme.dart';
import 'package:senseriduvarkagidi/theme_provider.dart';
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:senseriduvarkagidi/ek/widgets.dart';
import 'package:senseriduvarkagidi/ek/yardimci.dart';
import 'package:senseriduvarkagidi/ek/ayarlar.dart';
import 'package:senseriduvarkagidi/model/KullaniciModel.dart';
import 'package:senseriduvarkagidi/model/image.dart';

class Sayfalar extends StatefulWidget {
  const Sayfalar({super.key});

  @override
  State<Sayfalar> createState() => _SayfalarState();
}

class _SayfalarState extends State<Sayfalar>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  // Controllers
  late PageController _mainPageController;
  late PageController _imagePageController;
  late AnimationController _likeAnimationController;
  late AnimationController _buttonAnimationController;

  // Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  // State variables
  int _selectedIndex = 1; // Start with images page
  int _currentImageIndex = 0;
  bool _isProcessing = false;
  bool _showLikeAnimation = false;
  Color _favoriteButtonColor = Colors.white;
  Offset _tapPosition = Offset.zero;

  // Data lists - Use lazy loading
  List<ImageList> _favoriteImages = [];
  final List<Widget> _imageWidgets = [];
  final List<Widget> _categoryWidgets = [];
  final List<Widget> _favoriteImageWidgets = [];
  List<ImageList> _imageList = [];

  // Performance optimization
  static const int _initialLoadCount = 3;
  static const int _loadMoreCount = 2;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeBannerAd();
    _initializeData();
  }

  void _initializeControllers() {
    _mainPageController = PageController(initialPage: 1);
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

  void _initializeBannerAd() {
    if (Platform.isAndroid || Platform.isIOS) {
      _bannerAd = BannerAd(
        adUnitId: _getBannerAdUnitId(),
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (_) {
            setState(() {
              _isBannerAdReady = true;
            });
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
      return ayarlar.bannerReklamId; // Test ID
    } else if (Platform.isIOS) {
      return ayarlar.bannerReklamId; // Test ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  void _initializeData() {
    _imageList = List.from(Genel.Resimler);
    _imageList.shuffle(math.Random());

    // Build categories asynchronously
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buildCategoryWidgets();
      _loadInitialImages();
      _updateFavoriteButtonColor();
    });
  }

  @override
  void dispose() {
    _mainPageController.dispose();
    _imagePageController.dispose();
    _likeAnimationController.dispose();
    _buttonAnimationController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Banner Ad at top
            if (_isBannerAdReady && _bannerAd != null)
              Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                margin: const EdgeInsets.only(bottom: 8),
                child: AdWidget(ad: _bannerAd!),
              ),
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _mainPageController,
                children: [
                  _buildCategoriesPage(),
                  _buildImagesPage(),
                  _buildFavoritesPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: StylishBottomBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        option: BubbleBarOptions(
          inkEffect: true,
          barStyle: BubbleBarStyle.horizontal,
          bubbleFillStyle: BubbleFillStyle.fill,
          opacity: 0.8,
        ),
        items: [
          _buildBottomBarItem(
            icon: Icons.grid_view_rounded,
            selectedIcon: Icons.grid_view,
            title: 'Kategoriler',
            color: Colors.orange,
          ),
          _buildBottomBarItem(
            icon: Icons.explore_outlined,
            selectedIcon: Icons.explore,
            title: 'Keşfet',
            color: Colors.blue,
          ),
          _buildBottomBarItem(
            icon: Icons.favorite_outline,
            selectedIcon: Icons.favorite,
            title: 'Favorilerim',
            color: Colors.red,
          ),
        ],
        hasNotch: false,
        currentIndex: _selectedIndex,
        onTap: _onBottomNavigationTap,
      ),
    );
  }

  BottomBarItem _buildBottomBarItem({
    required IconData icon,
    required IconData selectedIcon,
    required String title,
    required Color color,
  }) {
    return BottomBarItem(
      icon: Icon(icon, color: Colors.white70, size: 22),
      selectedIcon: Icon(selectedIcon, color: Colors.white, size: 24),
      backgroundColor: color,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _onBottomNavigationTap(int index) {
    if (_selectedIndex == index) return;

    setState(() => _selectedIndex = index);
    HapticFeedback.lightImpact();

    switch (index) {
      case 0:
        if (_categoryWidgets.isEmpty) _buildCategoryWidgets();
        break;
      case 1:
        _updateFavoriteButtonColor();
        break;
      case 2:
        _loadFavoriteImages();
        break;
    }

    _mainPageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildCategoriesPage() {
    return CustomScrollView(
      slivers: [
        // App Header için sabit alan
        SliverToBoxAdapter(
          child: _buildAppHeader(),
        ),

        SliverPadding(
          padding: const EdgeInsets.only(bottom: 100),
          sliver: _categoryWidgets.isEmpty
              ? SliverToBoxAdapter(child: _buildLoadingGrid())
              : SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _categoryWidgets[index],
              childCount: _categoryWidgets.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Genel.darkbutton ? Icons.dark_mode : Icons.light_mode,
              color: Colors.teal,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hoş Geldiniz",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                Text(
                  "En güzel duvar kağıtları",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch.adaptive(
              value: Genel.darkbutton,
              onChanged: _toggleTheme,
              activeColor: Colors.teal,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }


  void _toggleTheme(bool value) {
    HapticFeedback.selectionClick();
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
    setState(() {
      Genel.darkbutton = value;
    });
    Yardimci.Veri_Kaydet_String("darkmode", value.toString());
  }

  Widget _buildImagesPage() {
    return Stack(
      children: [
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
        _buildImageActionButtons(),
        // Like Animation - only show when triggered
        if (_showLikeAnimation) _buildLikeAnimation(),
        if (_isProcessing) _buildProcessingOverlay(),
      ],
    );
  }

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
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(
                    icon: Icons.favorite_rounded,
                    label: "Beğen",
                    color: _favoriteButtonColor,
                    onPressed: _toggleFavorite,
                  ),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    icon: Icons.wallpaper_rounded,
                    label: "Duvar\nKağıdı",
                    color: Colors.white,
                    onPressed: _setWallpaperWithConfirmation,
                  ),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    icon: Icons.download_rounded,
                    label: "İndir",
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
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
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

  Widget _buildFavoritesPage() {
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

  Widget _buildEmptyFavoritesView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 80,
              color: Colors.red.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Henüz favorilerinize resim eklemediniz",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).textTheme.titleMedium?.color?.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Beğendiğiniz resimleri çift tıklayarak favorilerinize ekleyin",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

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
                  (context, index) => _favoriteImageWidgets[index],
              childCount: _favoriteImageWidgets.length,
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

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

  Widget _buildLoadingGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(3, (index) =>
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ),
      ),
    );
  }

  // Image building methods
  void _loadInitialImages() {
    _imageWidgets.clear();
    final int loadCount = math.min(_initialLoadCount, _imageList.length);

    for (int i = 0; i < loadCount; i++) {
      _imageWidgets.add(_buildImageWidget(_imageList[i]));
    }

    if (mounted) setState(() {});
  }

  Widget _buildImageWidget(ImageList imageData) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Hero(
        tag: imageData.id,
        child: CachedNetworkImage(
          imageUrl: "${ayarlar.resimsunucusu}${imageData.yol}",
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
                  "Resim yüklenemedi",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Category building methods
  void _buildCategoryWidgets() {
    _categoryWidgets.clear();

    for (int i = 0; i < Genel.Kategoriler.length; i++) {
      _categoryWidgets.add(_buildCategoryWidget(Genel.Kategoriler[i], i));
    }

    if (mounted) setState(() {});
  }

  Widget _buildCategoryWidget(KategoriList category, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToCategory(index),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: "${ayarlar.resimsunucusu}${category.kategorI_RESMI}",
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.kategori,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 3,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Koleksiyonu görüntüle",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).scrollTransition((context, widget, event) {
          return widget
              .blur(event.phase == ScrollPhase.identity ? 0 : 3)
              .scale(event.phase == ScrollPhase.identity ? 1 : 0.97);
        }),
      ),
    );
  }

  // Favorite images methods
  void _loadFavoriteImages() {
    _favoriteImages.clear();
    _favoriteImageWidgets.clear();

    for (var image in _imageList) {
      if (Yardimci.favori_resimler_Kontrol(image.id)) {
        _favoriteImages.add(image);
      }
    }

    _favoriteImages.shuffle(math.Random());

    for (var image in _favoriteImages) {
      _favoriteImageWidgets.add(_buildFavoriteImageWidget(image));
    }

    if (mounted) setState(() {});
  }

  Widget _buildFavoriteImageWidget(ImageList imageData) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToImageDetail(imageData),
        onLongPress: () => _showImageContextMenu(imageData),
        onTapDown: (details) => _getTapPosition(details),
        borderRadius: BorderRadius.circular(16),
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
                CachedNetworkImage(
                  imageUrl: "${ayarlar.resimsunucusu}${imageData.yol}",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                ),
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

  // Event handlers
  void _onImageDoubleTap() {
    HapticFeedback.mediumImpact();
    _toggleFavorite();
  }

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

  void _updateFavoriteButtonColor() {
    if (_currentImageIndex < _imageList.length) {
      setState(() {
        _favoriteButtonColor = Yardimci.favori_resimler_Kontrol(
          _imageList[_currentImageIndex].id,
        ) ? Colors.red : Colors.white;
      });
    }
  }

  void _toggleFavorite() {
    if (_currentImageIndex < _imageList.length) {
      final imageId = _imageList[_currentImageIndex].id;
      _addToFavorites(imageId);

      // Show like animation only when adding to favorites
      if (Yardimci.favori_resimler_Kontrol(imageId)) {
        setState(() {
          _showLikeAnimation = true;
        });

        _likeAnimationController.forward().then((_) {
          _likeAnimationController.reset();
          setState(() {
            _showLikeAnimation = false;
          });
        });
      }

      _updateFavoriteButtonColor();
    }
  }

  void _navigateToCategory(int categoryIndex) {
    HapticFeedback.lightImpact();
    Genel.SecilenKategori = categoryIndex.toString();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => KategoriResim(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
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
      ),
    );
  }

  // Utility methods
  void _getTapPosition(TapDownDetails details) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    setState(() {
      _tapPosition = referenceBox.globalToLocal(details.globalPosition);
    });
  }
// Sayfalar.dart dosyasında _setWallpaperWithConfirmation metodunu değiştirin:

  void _setWallpaperWithConfirmation() {
    HapticFeedback.lightImpact();
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
                  _performSetWallpaper(_imageList[_currentImageIndex], WallpaperManagerFlutter.lockScreen);
                },
              ),
              const SizedBox(height: 8),
              _buildWallpaperOption(
                icon: Icons.home_outlined,
                title: "Ana Ekran",
                subtitle: "Sadece ana ekranda görünür",
                onTap: () {
                  Navigator.of(context).pop();
                  _performSetWallpaper(_imageList[_currentImageIndex], WallpaperManagerFlutter.homeScreen);
                },
              ),
              const SizedBox(height: 8),
              _buildWallpaperOption(
                icon: Icons.phone_android_rounded,
                title: "Her İki Ekran",
                subtitle: "Hem kilit hem ana ekranda görünür",
                onTap: () {
                  Navigator.of(context).pop();
                  _performSetWallpaper(_imageList[_currentImageIndex], WallpaperManagerFlutter.bothScreens);
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

// _performSetWallpaper metodunu da güncelleyin:
  Future<void> _performSetWallpaper(ImageList imageData, int wallpaperLocation) async {
    try {
      setState(() => _isProcessing = true);

      final url = "${ayarlar.resimsunucusu}${imageData.yol}";
      final file = await DefaultCacheManager().getSingleFile(url);

      final result = await WallpaperManagerFlutter().setWallpaper(file, wallpaperLocation);

      if (result) {
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

// _setWallpaper metodunu da güncelleyin:
  void _setWallpaper() {
    if (_currentImageIndex < _imageList.length) {
      final imageData = _imageList[_currentImageIndex];

      if (ayarlar.odullureklamacikmi == "1") {
        _showRewardedAdForAction(() => _showWallpaperLocationDialog());
      } else {
        _showWallpaperLocationDialog();
      }
    }
  }
  // Action methods


  void _downloadImage() {
    if (_currentImageIndex < _imageList.length) {
      final imageData = _imageList[_currentImageIndex];

      if (ayarlar.odullureklamacikmi == "1") {
        _showRewardedAdForAction(() => _download(imageData));
      } else {
        _download(imageData);
      }
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
  Future<void> _download(ImageList imageData) async {
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

      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth && ps != PermissionState.limited) {
        _showErrorAlert("Galeriyi kaydetmek için izin verilmedi.");
        return;
      }


      // 3️⃣ Resmi kaydet
      final asset = await PhotoManager.editor.saveImage(
        imageBytes,
        filename:"wallpaper_${now.millisecondsSinceEpoch}",
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


  Future<void> _addToFavorites(int imageId) async {
    try {
      await ImageList.FavorilereEkle(context, imageId);
      Yardimci.favori_resim_ekle(imageId.toString());

      // Refresh favorites if on favorites page
      if (_selectedIndex == 2) {
        _loadFavoriteImages();
      }
    } catch (e) {
      _showErrorAlert("Favorilere eklenemedi");
    }
  }

  void _showImageContextMenu(ImageList imageData) async {
    HapticFeedback.lightImpact();
    final RenderObject? overlay = Overlay.of(context)?.context.findRenderObject();

    final result = await showMenu(
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
        PopupMenuItem(
          value: 'remove_favorite',
          child: Row(
            children: [
              Icon(Icons.favorite_border, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              Text(
                'Favorilerden Çıkar',
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
              Icon(Icons.wallpaper, color: Colors.blue, size: 20),
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
              Icon(Icons.download, color: Colors.green, size: 20),
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

  void _handleContextMenuAction(String? action, ImageList imageData) {
    switch (action) {
      case 'remove_favorite':
        _addToFavorites(imageData.id);
        break;
      case 'set_wallpaper':
        _setWallpaperWithConfirmation();
        break;
      case 'download':
        _download(imageData);
        break;
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