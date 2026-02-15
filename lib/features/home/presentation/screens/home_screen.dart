import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

import 'package:senseriduvarkagidi/ek/ayarlar.dart';
import 'package:senseriduvarkagidi/features/home/presentation/widgets/categories_tab.dart';
import 'package:senseriduvarkagidi/features/home/presentation/widgets/explore_tab.dart';
import 'package:senseriduvarkagidi/features/home/presentation/widgets/favorites_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  // Controllers
  late PageController _pageController;

  // Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  // Navigation state
  int _selectedIndex = 1; // Start on Kesfet (Explore) page

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _initializeBannerAd();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Banner Ad
  // ---------------------------------------------------------------------------

  void _initializeBannerAd() {
    if (!Platform.isAndroid && !Platform.isIOS) return;

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
          debugPrint('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
  }

  String _getBannerAdUnitId() {
    if (Platform.isAndroid) {
      return ayarlar.bannerReklamId;
    } else if (Platform.isIOS) {
      return ayarlar.bannerReklamId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _onBottomNavigationTap(int index) {
    if (_selectedIndex == index) return;

    setState(() => _selectedIndex = index);
    HapticFeedback.lightImpact();

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

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
                controller: _pageController,
                children: const [
                  CategoriesTab(),
                  ExploreTab(),
                  FavoritesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom Navigation Bar
  // ---------------------------------------------------------------------------

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
            title: 'Ke\u015ffet',
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
}
