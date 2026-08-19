import 'package:decimal/decimal.dart';
import 'package:sol_catalog/features/products/domain/entities/product.dart';
import 'package:sol_catalog/features/products/domain/entities/product_page.dart';

enum ProductSortField {
  name('Name', 'Nombre'),
  price('Price', 'Precio'),
  stock('Stock', 'Stock'),
  sku('Sku', 'SKU');

  const ProductSortField(this.wire, this.label);

  final String wire;
  final String label;
}

enum SortDirection {
  asc('Asc', 'ascendente'),
  desc('Desc', 'descendente');

  const SortDirection(this.wire, this.label);

  final String wire;
  final String label;
}

class ProductQuery {
  const ProductQuery({
    this.search = '',
    this.page = 1,
    this.sortBy = ProductSortField.name,
    this.sortDir = SortDirection.asc,
    this.onlyInStock = false,
  });

  final String search;
  final int page;
  final ProductSortField sortBy;
  final SortDirection sortDir;
  final bool onlyInStock;

  ProductQuery copyWith({
    String? search,
    int? page,
    ProductSortField? sortBy,
    SortDirection? sortDir,
    bool? onlyInStock,
  }) => ProductQuery(
    search: search ?? this.search,
    page: page ?? this.page,
    sortBy: sortBy ?? this.sortBy,
    sortDir: sortDir ?? this.sortDir,
    onlyInStock: onlyInStock ?? this.onlyInStock,
  );
}

abstract interface class ProductRepository {
  Future<ProductPage> search(ProductQuery query);

  Future<Product> updatePrice({
    required int id,
    required Decimal price,
    required String currency,
    int? expectedVersion,
  });
}
