import 'package:decimal/decimal.dart';
import 'package:sol_catalog/features/products/domain/entities/product.dart';
import 'package:sol_catalog/features/products/domain/entities/product_page.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    required this.sku,
    required this.name,
    required this.price,
    required this.currency,
    required this.stock,
    required this.updatedAt,
    required this.version,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: (json['id'] as num?)?.toInt() ?? 0,
    sku: json['sku']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    price: json['price']?.toString() ?? '0',
    currency: json['currency']?.toString() ?? '',
    stock: (json['stock'] as num?)?.toInt() ?? 0,
    updatedAt:
        DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
        DateTime.now().toUtc(),
    version: (json['version'] as num?)?.toInt() ?? 0,
  );

  final int id;
  final String sku;
  final String name;
  final String price;
  final String currency;
  final int stock;
  final DateTime updatedAt;
  final int version;

  Product toEntity() => Product(
    id: id,
    sku: sku,
    name: name,
    price: Decimal.tryParse(price) ?? Decimal.zero,
    currency: currency,
    stock: stock,
    updatedAt: updatedAt,
    version: version,
  );
}

class ProductPageModel {
  const ProductPageModel({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
    required this.hasNext,
  });

  factory ProductPageModel.fromJson(Map<String, dynamic> json) {
    final raw = json['items'] as List<dynamic>? ?? const [];

    return ProductPageModel(
      items: raw
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      hasNext: json['hasNext'] as bool? ?? false,
    );
  }

  final List<ProductModel> items;
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
  final bool hasNext;

  ProductPage toEntity() => ProductPage(
    items: [for (final item in items) item.toEntity()],
    page: page,
    pageSize: pageSize,
    total: total,
    totalPages: totalPages,
    hasNext: hasNext,
  );
}
