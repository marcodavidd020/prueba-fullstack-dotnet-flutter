import 'package:equatable/equatable.dart';
import 'package:sol_catalog/features/products/domain/entities/product.dart';

class ProductPage extends Equatable {
  const ProductPage({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
    required this.hasNext,
  });

  const ProductPage.empty()
    : items = const [],
      page = 1,
      pageSize = 20,
      total = 0,
      totalPages = 0,
      hasNext = false;

  final List<Product> items;
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
  final bool hasNext;

  ProductPage copyWith({
    List<Product>? items,
    int? page,
    int? pageSize,
    int? total,
    int? totalPages,
    bool? hasNext,
  }) => ProductPage(
    items: items ?? this.items,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
    total: total ?? this.total,
    totalPages: totalPages ?? this.totalPages,
    hasNext: hasNext ?? this.hasNext,
  );

  ProductPage concat(ProductPage next) =>
      next.copyWith(items: [...items, ...next.items]);

  @override
  List<Object?> get props => [
    items,
    page,
    pageSize,
    total,
    totalPages,
    hasNext,
  ];
}
