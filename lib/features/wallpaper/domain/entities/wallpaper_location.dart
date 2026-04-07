/// Duvar kagidi uygulanacak ekran.
enum WallpaperLocation {
  homeScreen(1, 'Ana Ekran'),
  lockScreen(2, 'Kilit Ekranı'),
  bothScreens(3, 'Her İki Ekran');

  final int value;
  final String label;

  const WallpaperLocation(this.value, this.label);
}

