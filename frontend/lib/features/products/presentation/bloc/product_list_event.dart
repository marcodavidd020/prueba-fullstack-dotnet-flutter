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

final class SortChanged extends ProductListEvent {
  const SortChanged(this.sortBy, this.sortDir);

  final ProductSortField sortBy;
  final SortDirection sortDir;
}

final class StockFilterToggled extends ProductListEvent {
  const StockFilterToggled({required this.onlyInStock});

  final bool onlyInStock;
}

final class ProductUpdated extends ProductListEvent {
  const ProductUpdated(this.product);

  final Product product;
}
