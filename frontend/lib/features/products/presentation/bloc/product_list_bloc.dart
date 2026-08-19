import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sol_catalog/core/config/app_config.dart';
import 'package:sol_catalog/core/error/failure.dart';
import 'package:sol_catalog/features/products/domain/entities/product.dart';
import 'package:sol_catalog/features/products/domain/entities/product_page.dart';
import 'package:sol_catalog/features/products/domain/repositories/product_repository.dart';
import 'package:sol_catalog/features/products/domain/usecases/search_products_usecase.dart';

part 'product_list_event.dart';
part 'product_list_state.dart';

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  ProductListBloc(this._searchProducts, this._config)
    : super(const ProductListInitial()) {
    on<ProductsRequested>(_onRequested, transformer: restartable());
    on<SearchChanged>(_onSearchChanged, transformer: _debounceRestartable());
    on<NextPageRequested>(_onNextPage, transformer: droppable());
    on<SortChanged>(_onSortChanged, transformer: restartable());
    on<StockFilterToggled>(_onStockFilterToggled, transformer: restartable());
    on<ProductUpdated>(_onProductUpdated, transformer: sequential());
  }

  final SearchProductsUseCase _searchProducts;
  final AppConfig _config;

  EventTransformer<E> _debounceRestartable<E>() =>
      (events, mapper) => restartable<E>()(
        events.debounceTime(_config.searchDebounce),
        mapper,
      );

  ProductQuery get _currentQuery => switch (state) {
    ProductListLoaded(:final query) => query,
    ProductListError(:final query) => query,
    _ => const ProductQuery(),
  };

  Future<void> _onRequested(
    ProductsRequested event,
    Emitter<ProductListState> emit,
  ) => _loadFirstPage(_currentQuery.copyWith(page: 1), emit);

  Future<void> _onSearchChanged(
    SearchChanged event,
    Emitter<ProductListState> emit,
  ) => _loadFirstPage(
    _currentQuery.copyWith(search: event.query, page: 1),
    emit,
  );

  Future<void> _onSortChanged(
    SortChanged event,
    Emitter<ProductListState> emit,
  ) => _loadFirstPage(
    _currentQuery.copyWith(
      sortBy: event.sortBy,
      sortDir: event.sortDir,
      page: 1,
    ),
    emit,
  );

  Future<void> _onStockFilterToggled(
    StockFilterToggled event,
    Emitter<ProductListState> emit,
  ) => _loadFirstPage(
    _currentQuery.copyWith(onlyInStock: event.onlyInStock, page: 1),
    emit,
  );

  Future<void> _loadFirstPage(
    ProductQuery query,
    Emitter<ProductListState> emit,
  ) async {
    emit(const ProductListLoading());

    try {
      final result = await _searchProducts(query);
      emit(ProductListLoaded(page: result, query: query));
    } on CancelledFailure {
      return;
    } on Failure catch (e) {
      emit(ProductListError(failure: e, query: query));
    }
  }

  Future<void> _onNextPage(
    NextPageRequested event,
    Emitter<ProductListState> emit,
  ) async {
    final current = state;

    if (current is! ProductListLoaded || !current.page.hasNext) return;

    emit(current.copyWith(isLoadingMore: true, clearFailure: true));

    final nextQuery = current.query.copyWith(page: current.page.page + 1);

    try {
      final result = await _searchProducts(nextQuery);
      emit(
        current.copyWith(
          page: current.page.concat(result),
          query: nextQuery,
          isLoadingMore: false,
        ),
      );
    } on CancelledFailure {
      return;
    } on Failure catch (e) {
      emit(current.copyWith(isLoadingMore: false, loadMoreFailure: e));
    }
  }

  void _onProductUpdated(
    ProductUpdated event,
    Emitter<ProductListState> emit,
  ) {
    final current = state;
    if (current is! ProductListLoaded) return;

    final updatedItems = [
      for (final product in current.products)
        if (product.id == event.product.id) event.product else product,
    ];

    emit(current.copyWith(page: current.page.copyWith(items: updatedItems)));
  }
}
