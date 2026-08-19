import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.price,
    required this.currency,
    required this.stock,
    required this.updatedAt,
    required this.version,
  });

  final int id;
  final String sku;
  final String name;
  final Decimal price;
  final String currency;
  final int stock;
  final DateTime updatedAt;
  final int version;

  bool get hasStock => stock > 0;

  Product copyWith({
    int? id,
    String? sku,
    String? name,
    Decimal? price,
    String? currency,
    int? stock,
    DateTime? updatedAt,
    int? version,
  }) => Product(
    id: id ?? this.id,
    sku: sku ?? this.sku,
    name: name ?? this.name,
    price: price ?? this.price,
    currency: currency ?? this.currency,
    stock: stock ?? this.stock,
    updatedAt: updatedAt ?? this.updatedAt,
    version: version ?? this.version,
  );

  @override
  List<Object?> get props => [
    id,
    sku,
    name,
    price,
    currency,
    stock,
    updatedAt,
    version,
  ];
}
