part of 'product_list_bloc.dart';

sealed class ProductListEvent {
  const ProductListEvent();
}

final class ProductsRequested extends ProductListEvent {
  const ProductsRequested();
}

final class SearchChanged extends ProductListEvent {
  const SearchChanged(this.query);

  final String query;
}

final class NextPageRequested extends ProductListEvent {
  const NextPageRequested();
}

final class FiltersChanged extends ProductListEvent {
  const FiltersChanged({
    required this.sortBy,
    required this.sortDir,
    required this.onlyInStock,
    this.minPrice,
    this.maxPrice,
    this.currency,
  });

  final ProductSortField sortBy;
  final SortDirection sortDir;
  final bool onlyInStock;
  final Decimal? minPrice;
  final Decimal? maxPrice;
  final String? currency;
}

final class ProductUpdated extends ProductListEvent {
  const ProductUpdated(this.product);

  final Product product;
}
