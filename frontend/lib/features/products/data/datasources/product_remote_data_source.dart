import 'package:dio/dio.dart';
import 'package:sol_catalog/core/config/app_config.dart';
import 'package:sol_catalog/features/products/data/models/product_model.dart';
import 'package:sol_catalog/features/products/domain/repositories/product_repository.dart';

class ProductRemoteDataSource {
  const ProductRemoteDataSource(this._dio, this._config);

  final Dio _dio;
  final AppConfig _config;

  Future<ProductPageModel> search(
    ProductQuery query, {
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/products',
      queryParameters: <String, dynamic>{
        if (query.search.trim().isNotEmpty) 'q': query.search.trim(),
        'page': query.page,
        'pageSize': _config.pageSize,
        'sortBy': query.sortBy.wire,
        'sortDir': query.sortDir.wire,
        if (query.minPrice != null) 'minPrice': query.minPrice.toString(),
        if (query.maxPrice != null) 'maxPrice': query.maxPrice.toString(),
        if (query.currency != null) 'currency': query.currency,
        if (query.onlyInStock) 'inStock': true,
      },
      cancelToken: cancelToken,
    );

    return ProductPageModel.fromJson(response.data!);
  }

  Future<ProductModel> getById(int id, {CancelToken? cancelToken}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/products/$id',
      cancelToken: cancelToken,
    );

    return ProductModel.fromJson(response.data!);
  }

  Future<ProductModel> updatePrice({
    required int id,
    required String price,
    required String currency,
    int? expectedVersion,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/products/$id/price',
      data: <String, dynamic>{'price': price, 'currency': currency},
      options: Options(
        headers: <String, dynamic>{
          if (expectedVersion != null) 'If-Match': '"$expectedVersion"',
        },
      ),
      cancelToken: cancelToken,
    );

    return ProductModel.fromJson(response.data!);
  }
}
