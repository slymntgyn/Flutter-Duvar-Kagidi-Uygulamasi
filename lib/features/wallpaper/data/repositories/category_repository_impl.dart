import 'dart:convert';

import 'package:senseriduvarkagidi/core/constants/api_constants.dart';
import 'package:senseriduvarkagidi/core/errors/failures.dart';
import 'package:senseriduvarkagidi/core/errors/result.dart';
import 'package:senseriduvarkagidi/core/network/dio_client.dart';
import 'package:senseriduvarkagidi/features/wallpaper/data/models/category_model.dart';
import 'package:senseriduvarkagidi/features/wallpaper/domain/entities/category.dart';
import 'package:senseriduvarkagidi/features/wallpaper/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final DioClient _dioClient;

  CategoryRepositoryImpl(this._dioClient);

  @override
  Future<Result<List<Category>>> getCategories() async {
    try {
      final response = await _dioClient.get(ApiConstants.getCategories);
      if (response.statusCode == 200) {
        final jsonList = jsonDecode(response.data.toString()) as List;
        final categories = jsonList
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return Success(categories);
      }
      return Error(ServerFailure(
        'categories yüklenemedi',
        statusCode: response.statusCode,
      ));
    } catch (e) {
      return Error(NetworkFailure('categories yüklenirken hata: $e'));
    }
  }
}

