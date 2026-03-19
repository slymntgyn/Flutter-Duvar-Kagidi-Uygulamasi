import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:senseriduvarkagidi/ek/ayarlar.dart';
import 'package:senseriduvarkagidi/ek/genel.dart';
import 'package:senseriduvarkagidi/model/image.dart';
import 'package:senseriduvarkagidi/model/kategoriler.dart';
import 'package:senseriduvarkagidi/features/wallpaper/presentation/screens/image_detail_screen.dart';

/// Kategori detay ekrani.
/// Collapsible SliverAppBar, Masonry grid, siralama, Hero navigasyon.
class CategoryImagesScreen extends ConsumerStatefulWidget {
  final KategoriList category;

  const CategoryImagesScreen({super.key, required this.category});

  @override
  ConsumerState<CategoryImagesScreen> createState() =>
      _CategoryImagesScreenState();
}

enum _SortOption { shuffle, idAsc, idDesc }

class _CategoryImagesScreenState extends ConsumerState<CategoryImagesScreen>
    with SingleTickerProviderStateMixin {
  List<ImageList> _images = [];
  _SortOption _sortOption = _SortOption.shuffle;

  late final AnimationController _headerAnimController;

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerAnimController.forward();
    _loadImages();
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    super.dispose();
  }

  void _loadImages() {
    final filtered = Genel.Resimler
        .where((img) =>
            img.kategori == widget.category.id.toString())
        .toList();

    // If no match by ID, show all (fallback)
    final list = filtered.isNotEmpty ? filtered : List<ImageList>.from(Genel.Resimler);

    switch (_sortOption) {
      case _SortOption.shuffle:
        list.shuffle();
        break;
      case _SortOption.idAsc:
        list.sort((a, b) => a.id.compareTo(b.id));
        break;
      case _SortOption.idDesc:
        list.sort((a, b) => b.id.compareTo(a.id));
        break;
    }

    setState(() => _images = list);
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _loadImages();
  }

  void _showSortSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildSortSheet(ctx),
    );
  }

  Widget _buildSortSheet(BuildContext ctx) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Siralama',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _sortTile(ctx, Icons.shuffle_rounded, 'Karistir', _SortOption.shuffle),
              _sortTile(ctx, Icons.arrow_upward_rounded, 'Eskiden Yeniye', _SortOption.idAsc),
              _sortTile(ctx, Icons.arrow_downward_rounded, 'Yeniden Eskiye', _SortOption.idDesc),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sortTile(BuildContext ctx, IconData icon, String label, _SortOption opt) {
    final isSelected = _sortOption == opt;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.teal : null),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.teal : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check_rounded, color: Colors.teal) : null,
      onTap: () {
        setState(() => _sortOption = opt);
        Navigator.pop(ctx);
        _loadImages();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            _buildImageGrid(),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sliver AppBar with collapsing hero image
  // ---------------------------------------------------------------------------

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.sort_rounded, color: Colors.white),
          onPressed: _showSortSheet,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.category.kategori,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(offset: Offset(1, 1), blurRadius: 4, color: Colors.black54),
            ],
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        background: _buildHeroBackground(),
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
      ),
    );
  }

  Widget _buildHeroBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Category cover image
        CachedNetworkImage(
          imageUrl:
              '${ayarlar.resimsunucusu}${widget.category.kategorI_RESMI}',
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey[800]!, Colors.grey[900]!],
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[800],
            child: const Icon(Icons.broken_image_outlined,
                color: Colors.white38, size: 48),
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
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
        ),

        // Image count badge
        Positioned(
          top: 16,
          right: 16,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.photo_library_outlined,
                      color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${_images.length} resim',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Masonry grid
  // ---------------------------------------------------------------------------

  Widget _buildImageGrid() {
    if (_images.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childCount: _images.length,
        itemBuilder: (context, index) =>
            _buildImageCard(_images[index], index),
      ),
    );
  }

  Widget _buildImageCard(ImageList image, int index) {
    // Alternate card heights for masonry effect
    final isLong = index % 3 == 0;
    final height = isLong ? 260.0 : 200.0;
    final heroTag = 'category_${image.id}_$index';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (ctx, anim, secAnim) => ImageDetailScreen(
              image: image,
              heroTag: heroTag,
            ),
            transitionsBuilder: (ctx, anim, secAnim, child) {
              return FadeTransition(opacity: anim, child: child);
            },
          ),
        );
      },
      child: Hero(
        tag: heroTag,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
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
                CachedNetworkImage(
                  imageUrl: '${ayarlar.resimsunucusu}${image.yol}',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildShimmerPlaceholder(),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.error_outline),
                  ),
                ),

                // Gradient overlay at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '4K',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 10),
                          ),
                        ),
                        Icon(
                          Icons.fullscreen_rounded,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 16,
                        ),
                      ],
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

  Widget _buildShimmerPlaceholder() {
    return _ShimmerBox();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_outlined,
              size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Bu kategoride resim bulunamadi',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Simple shimmer placeholder
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
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
            ),
          ),
        );
      },
    );
  }
}
