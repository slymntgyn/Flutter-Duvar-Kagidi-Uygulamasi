import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:senseriduvarkagidi/ek/ayarlar.dart';
import 'package:senseriduvarkagidi/model/kategoriler.dart';
import 'package:senseriduvarkagidi/features/wallpaper/presentation/screens/category_images_screen.dart';

/// Kategoriler tab — Pro UI.
/// Animated gradient hero baslik, arama/filtreleme, glassmorphism kartlar,
/// shimmer yukleme, pull-to-refresh, staggered masonry grid.
class CategoriesTab extends ConsumerStatefulWidget {
  const CategoriesTab({super.key});

  @override
  ConsumerState<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends ConsumerState<CategoriesTab>
    with TickerProviderStateMixin {
  late final AnimationController _headerGradientController;
  late final Animation<double> _headerGradientAnimation;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  List<KategoriList> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _headerGradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _headerGradientAnimation = CurvedAnimation(
      parent: _headerGradientController,
      curve: Curves.easeInOut,
    );
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  @override
  void dispose() {
    _headerGradientController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadCategories() {
    if (!mounted) return;
    setState(() {
      _filteredCategories = List.from(Genel.Kategoriler);
    });
  }

  void _onSearchChanged() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _searchQuery = q;
      _filteredCategories = Genel.Kategoriler
          .where((cat) => cat.kategori.toLowerCase().contains(q))
          .toList();
    });
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Gradient hero header + search bar (pinned)
          _buildSliverAppBar(),
          // Categories grid
          _filteredCategories.isEmpty
              ? _searchQuery.isNotEmpty
                  ? SliverFillRemaining(child: _buildNotFound())
                  : SliverFillRemaining(child: _buildLoadingPlaceholder())
              : _buildCategoryGrid(),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sliver AppBar with gradient + search
  // ---------------------------------------------------------------------------
  Widget _buildSliverAppBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SearchHeaderDelegate(
        headerGradientAnimation: _headerGradientAnimation,
        searchController: _searchController,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Masonry category grid
  // ---------------------------------------------------------------------------
  Widget _buildCategoryGrid() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childCount: _filteredCategories.length,
        itemBuilder: (context, index) =>
            _buildCategoryCard(_filteredCategories[index], index),
      ),
    );
  }

  Widget _buildCategoryCard(KategoriList category, int index) {
    final isLong = index % 3 == 0;
    final height = isLong ? 220.0 : 170.0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (ctx, anim, secAnim) =>
                CategoryImagesScreen(category: category),
            transitionsBuilder: (ctx, anim, secAnim, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              final tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
              return SlideTransition(position: anim.drive(tween), child: child);
            },
          ),
        );
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              CachedNetworkImage(
                imageUrl:
                    '${ayarlar.resimsunucusu}${category.kategorI_RESMI}',
                fit: BoxFit.cover,
                placeholder: (context, url) => _ShimmerBox(),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),

              // Glassmorphism label
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        border: Border(
                          top: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              category.kategori,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                      offset: Offset(1, 1),
                                      blurRadius: 3,
                                      color: Colors.black54),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // States
  // ---------------------------------------------------------------------------
  Widget _buildLoadingPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Kategoriler yukleniyor...',
              style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '"$_searchQuery" icin sonuc bulunamadi',
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pinned search header delegate
// ---------------------------------------------------------------------------
class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Animation<double> headerGradientAnimation;
  final TextEditingController searchController;

  _SearchHeaderDelegate({
    required this.headerGradientAnimation,
    required this.searchController,
  });

  @override
  double get minExtent => 70;
  @override
  double get maxExtent => 180;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(const Color(0xFF667eea), const Color(0xFF764ba2),
                    headerGradientAnimation.value)!,
            Color.lerp(const Color(0xFF764ba2), const Color(0xFFf093fb),
                    headerGradientAnimation.value)!,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular((1 - progress) * 24),
          bottomRight: Radius.circular((1 - progress) * 24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (progress < 0.8) ...[
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Opacity(
                      opacity: (1 - progress * 2).clamp(0.0, 1.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kategoriler',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${Genel.Kategoriler.length} kategori',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Kategori ara...',
                      hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6)),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: Colors.white.withValues(alpha: 0.8)),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close_rounded,
                                  color: Colors.white.withValues(alpha: 0.8)),
                              onPressed: () => searchController.clear(),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SearchHeaderDelegate oldDelegate) => true;
}

// ---------------------------------------------------------------------------
// Shimmer placeholder
// ---------------------------------------------------------------------------
class _ShimmerBox extends StatefulWidget {
  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _anim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(_anim.value - 1, 0),
              end: Alignment(_anim.value, 0),
              colors: [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
            ),
          ),
        );
      },
    );
  }
}
