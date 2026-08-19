import 'package:sol_catalog/features/products/domain/entities/product_page.dart';
import 'package:sol_catalog/features/products/domain/repositories/product_repository.dart';

class SearchProductsUseCase {
  const SearchProductsUseCase(this._repository);

  final ProductRepository _repository;

  Future<ProductPage> call(ProductQuery query) => _repository.search(query);
}
