import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
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

class ProductQuery extends Equatable {
  const ProductQuery({
    this.search = '',
    this.page = 1,
    this.sortBy = ProductSortField.name,
    this.sortDir = SortDirection.asc,
    this.minPrice,
    this.maxPrice,
    this.currency,
    this.onlyInStock = false,
  });

  final String search;
  final int page;
  final ProductSortField sortBy;
  final SortDirection sortDir;
  final Decimal? minPrice;
  final Decimal? maxPrice;
  final String? currency;
  final bool onlyInStock;

  bool get isDefaultSort =>
      sortBy == ProductSortField.name && sortDir == SortDirection.asc;

  int get activeFilterCount => [
    minPrice != null,
    maxPrice != null,
    currency != null,
    onlyInStock,
    !isDefaultSort,
  ].where((active) => active).length;

  ProductQuery copyWith({String? search, int? page}) => ProductQuery(
    search: search ?? this.search,
    page: page ?? this.page,
    sortBy: sortBy,
    sortDir: sortDir,
    minPrice: minPrice,
    maxPrice: maxPrice,
    currency: currency,
    onlyInStock: onlyInStock,
  );

  @override
  List<Object?> get props => [
    search,
    page,
    sortBy,
    sortDir,
    minPrice,
    maxPrice,
    currency,
    onlyInStock,
  ];
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
