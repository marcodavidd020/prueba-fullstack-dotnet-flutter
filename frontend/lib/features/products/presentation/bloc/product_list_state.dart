part of 'product_list_bloc.dart';

sealed class ProductListState extends Equatable {
  const ProductListState();

  @override
  List<Object?> get props => [];
}

final class ProductListInitial extends ProductListState {
  const ProductListInitial();
}

final class ProductListLoading extends ProductListState {
  const ProductListLoading();
}

final class ProductListLoaded extends ProductListState {
  const ProductListLoaded({
    required this.page,
    required this.query,
    this.isLoadingMore = false,
    this.loadMoreFailure,
  });

  final ProductPage page;
  final ProductQuery query;
  final bool isLoadingMore;
  final Failure? loadMoreFailure;

  List<Product> get products => page.items;

  bool get isEmpty => page.items.isEmpty;

  bool get isEmptyBySearch => isEmpty && query.search.trim().isNotEmpty;

  ProductListLoaded copyWith({
    ProductPage? page,
    ProductQuery? query,
    bool? isLoadingMore,
    Failure? loadMoreFailure,
    bool clearFailure = false,
  }) => ProductListLoaded(
    page: page ?? this.page,
    query: query ?? this.query,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadMoreFailure: clearFailure
        ? null
        : (loadMoreFailure ?? this.loadMoreFailure),
  );

  @override
  List<Object?> get props => [page, query, isLoadingMore, loadMoreFailure];
}

final class ProductListError extends ProductListState {
  const ProductListError({required this.failure, required this.query});

  final Failure failure;
  final ProductQuery query;

  @override
  List<Object?> get props => [failure, query];
}
