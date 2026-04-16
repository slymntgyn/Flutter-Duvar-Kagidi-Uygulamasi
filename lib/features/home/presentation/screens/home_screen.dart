import 'dart:ui';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:senseriduvarkagidi/ek/ayarlar.dart';
import 'package:senseriduvarkagidi/features/ai_generation/presentation/screens/ai_generation_screen.dart';
import 'package:senseriduvarkagidi/features/home/presentation/widgets/categories_tab.dart';
import 'package:senseriduvarkagidi/features/home/presentation/widgets/explore_tab.dart';
import 'package:senseriduvarkagidi/features/home/presentation/widgets/favorites_tab.dart';
import 'package:senseriduvarkagidi/features/premium/presentation/providers/premium_provider.dart';
import 'package:senseriduvarkagidi/features/settings/presentation/screens/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fabGlowController;
  late Animation<double> _fabGlowAnimation;

  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  // 0: Kesfet, 1: categories, 2: Favoriler, 3: Ayarlar
  int _selectedIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _fabGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _fabGlowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _fabGlowController, curve: Curves.easeInOut),
    );
    _initializeBannerAd();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabGlowController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _initializeBannerAd() {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    _bannerAd = BannerAd(
      adUnitId: LegacyAyarlar.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isBannerAdReady = true);
        },
        onAdFailedToLoad: (ad, err) {
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
  }

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

  void _openAIGeneration() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (ctx, anim, secAnim) => const AIGenerationScreen(),
        transitionsBuilder: (ctx, anim, secAnim, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.fastOutSlowIn;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final fade = Tween(begin: 0.0, end: 1.0)
              .animate(CurvedAnimation(parent: anim, curve: curve));
          return SlideTransition(
            position: anim.drive(tween),
            child: FadeTransition(opacity: fade, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final premium = ref.watch(premiumProvider);
    final showAd = !premium.adFree && _isBannerAdReady && _bannerAd != null;

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          if (showAd)
            Container(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: AdWidget(ad: _bannerAd!),
            ),
          Expanded(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: const [
                ExploreTab(),
                CategoriesTab(),
                FavoritesTab(),
                SettingsScreen(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildAiFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAiFab() {
    return AnimatedBuilder(
      animation: _fabGlowAnimation,
      builder: (context, child) {
        return Tooltip(
          message: 'AI Duvar Kagidi Olustur',
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea)
                      .withValues(alpha: _fabGlowAnimation.value * 0.5),
                  blurRadius: 20 * _fabGlowAnimation.value,
                  spreadRadius: 4 * _fabGlowAnimation.value,
                ),
                BoxShadow(
                  color: const Color(0xFF764ba2)
                      .withValues(alpha: _fabGlowAnimation.value * 0.3),
                  blurRadius: 30 * _fabGlowAnimation.value,
                  spreadRadius: 2 * _fabGlowAnimation.value,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openAIGeneration,
                borderRadius: BorderRadius.circular(32),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .scaffoldBackgroundColor
                .withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                _buildNavItem(0, Icons.explore_outlined, Icons.explore,
                    'Kesfet', Colors.blue),
                _buildNavItem(1, Icons.grid_view_outlined, Icons.grid_view,
                    'Kategoriler', Colors.orange),
                const SizedBox(width: 64),
                _buildNavItem(2, Icons.favorite_outline, Icons.favorite,
                    'Favoriler', Colors.red),
                _buildNavItem(3, Icons.settings_outlined, Icons.settings,
                    'Ayarlar', Colors.teal),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData selectedIcon,
    String label,
    Color accentColor,
  ) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onBottomNavigationTap(index),
        splashColor: accentColor.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? accentColor.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected
                      ? accentColor
                      : Theme.of(context)
                          .iconTheme
                          .color
                          ?.withValues(alpha: 0.5),
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? accentColor
                      : Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.5),
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
