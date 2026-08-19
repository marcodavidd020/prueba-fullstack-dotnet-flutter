import 'package:sol_catalog/features/products/domain/entities/product.dart';
import 'package:sol_catalog/features/products/domain/repositories/product_repository.dart';

class GetProductUseCase {
  const GetProductUseCase(this._repository);

  final ProductRepository _repository;

  Future<Product> call(int id) => _repository.getById(id);
}
