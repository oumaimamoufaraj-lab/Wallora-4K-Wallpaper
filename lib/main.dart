import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gallery_save.dart';
import 'screens/settings_screen.dart';
import 'wallpaper_catalog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WallcandyRoot());
}

class WallcandyRoot extends StatefulWidget {
  const WallcandyRoot({super.key});

  @override
  State<WallcandyRoot> createState() => _WallcandyRootState();
}

class _WallcandyRootState extends State<WallcandyRoot> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B4EFF)),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: _showSplash ? const SplashScreen() : const WallcandyHome(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flash_on, color: Colors.white, size: 52),
            SizedBox(height: 12),
            Text(
              'Wallora 4K Wallpaper',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: 10),
            Text('Loading...', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class WallcandyHome extends StatefulWidget {
  const WallcandyHome({super.key});

  @override
  State<WallcandyHome> createState() => _WallcandyHomeState();
}

class _WallcandyHomeState extends State<WallcandyHome> {
  static const String _prefsKeyFavoritePaths =
      'wallora_favorite_asset_paths';
  int _bottomIndex = 0;

  /// Insertion order; Like saves to gallery and adds here.
  final LinkedHashSet<String> _favoriteAssets = LinkedHashSet<String>();

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_prefsKeyFavoritePaths);
    if (raw == null || raw.isEmpty) return;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) return;
      final List<String> paths = decoded.map((e) => e.toString()).toList();
      if (!mounted) return;
      setState(() {
        _favoriteAssets
          ..clear()
          ..addAll(paths.where(WallpaperCatalog.isValidAsset));
      });
    } catch (_) {
      // ignore corrupt prefs
    }
  }

  Future<void> _persistFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKeyFavoritePaths,
      jsonEncode(_favoriteAssets.toList()),
    );
  }

  Future<bool> _saveAssetToGalleryImpl(String assetPath) async {
    final result = await saveBundledAssetToGallery(assetPath);
    if (result == GallerySaveResult.permissionDenied) {
      _showPhotosPermissionSnackBar();
    }
    return result == GallerySaveResult.success;
  }

  void _showPhotosPermissionSnackBar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Allow photo access to save wallpapers'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: 'Settings', onPressed: openAppSettings),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
  }

  Future<void> _handleTapOnAsset(String assetPath) async {
    if (!mounted) return;
    await _showImageViewerDialog(assetPath);
  }

  Future<void> _showImageViewerDialog(String assetPath) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        bool isFavorite = _favoriteAssets.contains(assetPath);

        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: SafeArea(
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Stack(
                  children: [
                    Positioned.fill(
                      child: InteractiveViewer(
                        child: Image.asset(assetPath, fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black45,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _BottomActionButton(
                            icon: isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            label: 'Like',
                            onPressed: () async {
                              if (isFavorite) {
                                setState(
                                  () => _favoriteAssets.remove(assetPath),
                                );
                                await _persistFavorites();
                                isFavorite = false;
                                setModalState(() {});
                                if (!mounted) return;
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Removed from favorites'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              final ok = await _saveAssetToGalleryImpl(
                                assetPath,
                              );
                              if (!mounted) return;
                              if (!ok) {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Could not save image'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }
                              setState(() => _favoriteAssets.add(assetPath));
                              await _persistFavorites();
                              if (!mounted) return;
                              isFavorite = true;
                              setModalState(() {});
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Saved to gallery and favorites',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                          _BottomActionButton(
                            icon: Icons.download,
                            label: 'Download',
                            onPressed: () async {
                              await _downloadImageToPhone(assetPath);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Shows “Download started” immediately, then saves to the device gallery / Photos.
  Future<void> _downloadImageToPhone(String assetPath) async {
    if (!mounted) return;
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('Download started'),
          behavior: SnackBarBehavior.floating,
        ),
      );

    final bool ok = await _saveAssetToGalleryImpl(assetPath);
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saved to your gallery'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Download failed — check Photos / storage permission'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        body: IndexedStack(
          index: _bottomIndex,
          children: [
            _HomeWithTabs(
              onTapImage: _handleTapOnAsset,
              onInfoPressed: _openSettings,
            ),
            _FavoritesTab(
              paths: _favoriteAssets.toList(),
              onTapImage: _handleTapOnAsset,
              onInfoPressed: _openSettings,
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _bottomIndex,
          onTap: (i) => setState(() => _bottomIndex = i),
          selectedItemColor: const Color(0xFF6B4EFF),
          unselectedItemColor: Colors.black54,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Favorite',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeWithTabs extends StatelessWidget {
  const _HomeWithTabs({
    required this.onTapImage,
    required this.onInfoPressed,
  });

  final void Function(String assetPath) onTapImage;
  final VoidCallback onInfoPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _TopHeader(title: 'Wallora 4K Wallpaper', onInfoPressed: onInfoPressed),
          const TabBar(
            isScrollable: true,
            labelPadding: EdgeInsets.symmetric(horizontal: 14),
            tabs: [
              Tab(text: 'Popular'),
              Tab(text: 'Anime'),
              Tab(text: 'Sports'),
              Tab(text: 'Fantastic'),
              Tab(text: 'Minimalist'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _PopularTab(onTapImage: onTapImage),
                _CategoryGridTab(
                  title: 'Anime',
                  onTapImage: onTapImage,
                  images: WallpaperCatalog.anime,
                  maxItems: 8,
                ),
                _CategoryGridTab(
                  title: 'Sports',
                  maxItems: 8,
                  childAspectRatio: 0.56,
                  onTapImage: onTapImage,
                  images: WallpaperCatalog.sports,
                ),
                _CategoryGridTab(
                  title: 'Fantastic',
                  maxItems: 8,
                  onTapImage: onTapImage,
                  images: WallpaperCatalog.fantastic,
                ),
                _CategoryGridTab(
                  title: 'Minimalist',
                  images: WallpaperCatalog.minimalist,
                  maxItems: 8,
                  onTapImage: onTapImage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoritesTab extends StatelessWidget {
  const _FavoritesTab({
    required this.paths,
    required this.onTapImage,
    required this.onInfoPressed,
  });

  final List<String> paths;
  final void Function(String assetPath) onTapImage;
  final VoidCallback onInfoPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _TopHeader(title: 'Wallora 4K Wallpaper', onInfoPressed: onInfoPressed),
          Expanded(
            child: paths.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 52,
                            color: Colors.black.withValues(alpha: 0.35),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'No favorites yet',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap Like on a wallpaper to save it and show it here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black.withValues(alpha: 0.55),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _CategoryGridTab(
                    title: 'Favorites',
                    images: paths,
                    onTapImage: onTapImage,
                  ),
          ),
        ],
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader({
    required this.title,
    required this.onInfoPressed,
  });

  final String title;
  final VoidCallback onInfoPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: 40),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
          IconButton(
            tooltip: 'About & privacy',
            onPressed: onInfoPressed,
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }
}

class _PopularTab extends StatefulWidget {
  const _PopularTab({required this.onTapImage});

  final void Function(String assetPath) onTapImage;

  @override
  State<_PopularTab> createState() => _PopularTabState();
}

class _PopularTabState extends State<_PopularTab> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = WallpaperCatalog.pickPopularRandom();
  }

  void _shuffle() {
    setState(() => _selected = WallpaperCatalog.pickPopularRandom());
  }

  @override
  Widget build(BuildContext context) {
    return _CategoryGridTab(
      title: 'Popular',
      headerTrailing: TextButton.icon(
        onPressed: _shuffle,
        icon: const Icon(Icons.shuffle, size: 20),
        label: const Text('Shuffle'),
      ),
      images: _selected,
      maxItems: WallpaperCatalog.popularGridCount,
      onTapImage: widget.onTapImage,
    );
  }
}

class _CategoryGridTab extends StatelessWidget {
  const _CategoryGridTab({
    required this.title,
    required this.images,
    this.maxItems,
    this.onTapImage,
    this.headerTrailing,
    this.childAspectRatio = 0.56,
  });

  final String title;
  final List<String> images;
  final int? maxItems;
  final void Function(String assetPath)? onTapImage;
  final Widget? headerTrailing;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final cards = (maxItems == null ? images : images.take(maxItems!)).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      children: [
        if (title.isNotEmpty || headerTrailing != null) ...[
          Row(
            children: [
              if (title.isNotEmpty)
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ?headerTrailing,
            ],
          ),
          const SizedBox(height: 12),
        ],
        GridView.builder(
          itemCount: cards.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            // This is adjustable per category so all thumbnails fit.
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, i) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: GestureDetector(
                onTap: onTapImage == null ? null : () => onTapImage!(cards[i]),
                child: Image.asset(
                  cards[i],
                  fit: BoxFit.cover, // Fill tile without side margins.
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _BottomActionButton extends StatelessWidget {
  const _BottomActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Colors.black.withValues(alpha: 0.55),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon)]),
    );
  }
}
