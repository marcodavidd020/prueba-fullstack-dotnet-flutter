import 'package:decimal/decimal.dart';
import 'package:sol_catalog/features/products/domain/entities/product.dart';
import 'package:sol_catalog/features/products/domain/repositories/product_repository.dart';

class UpdateProductPriceUseCase {
  const UpdateProductPriceUseCase(this._repository);

  final ProductRepository _repository;

  Future<Product> call({
    required int id,
    required Decimal price,
    required String currency,
    int? expectedVersion,
  }) => _repository.updatePrice(
    id: id,
    price: price,
    currency: currency,
    expectedVersion: expectedVersion,
  );
}
