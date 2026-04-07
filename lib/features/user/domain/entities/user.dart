/// Kullanici entity'si.
/// Pure Dart - Flutter bagimliligi yoktur.
class User {
  final List<String> permissions;
  final List<int> favoriteImageIds;

  const User({
    required this.permissions,
    required this.favoriteImageIds,
  });

  bool hasPermission(String permission) => permissions.contains(permission);

  bool isFavorite(int imageId) => favoriteImageIds.contains(imageId);

  static const User empty = User(permissions: [], favoriteImageIds: []);
}

