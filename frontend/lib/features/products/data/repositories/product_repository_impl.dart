import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:sol_catalog/core/error/failure.dart';
import 'package:sol_catalog/core/network/dio_client.dart';
import 'package:sol_catalog/core/utils/money_formatter.dart';
import 'package:sol_catalog/features/products/data/datasources/product_remote_data_source.dart';
import 'package:sol_catalog/features/products/domain/entities/product.dart';
import 'package:sol_catalog/features/products/domain/entities/product_page.dart';
import 'package:sol_catalog/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._remote);

  final ProductRemoteDataSource _remote;

  @override
  Future<ProductPage> search(ProductQuery query) async {
    try {
      final page = await _remote.search(query);
      return page.toEntity();
    } on DioException catch (e) {
      throw e.failure;
    } on FormatException catch (e) {
      throw UnexpectedFailure(
        'La respuesta del servidor no tiene el formato esperado: ${e.message}',
      );
    }
  }

  @override
  Future<Product> updatePrice({
    required int id,
    required Decimal price,
    required String currency,
    int? expectedVersion,
  }) async {
    try {
      final updated = await _remote.updatePrice(
        id: id,
        price: MoneyFormatter.toWire(price),
        currency: currency,
        expectedVersion: expectedVersion,
      );
      return updated.toEntity();
    } on DioException catch (e) {
      throw e.failure;
    } on FormatException catch (e) {
      throw UnexpectedFailure(
        'La respuesta del servidor no tiene el formato esperado: ${e.message}',
      );
    }
  }
}
