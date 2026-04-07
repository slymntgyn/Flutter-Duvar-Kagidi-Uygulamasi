import 'package:senseriduvarkagidi/features/user/domain/entities/user.dart';

/// User data modeli.
/// JSON serialization yetenegi ekler.
class UserModel extends User {
  const UserModel({
    required super.permissions,
    required super.favoriteImageIds,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final permissionsStr = json['yetkiler'] as String? ?? '';
    final favoritesStr = json['favoriteImagesRaw'] as String? ?? '';

    return UserModel(
      permissions: permissionsStr
          .split(';')
          .where((s) => s.isNotEmpty)
          .toList(),
      favoriteImageIds: favoritesStr
          .split(';')
          .where((s) => s.isNotEmpty)
          .map((s) => int.tryParse(s) ?? 0)
          .where((id) => id > 0)
          .toList(),
    );
  }
}

