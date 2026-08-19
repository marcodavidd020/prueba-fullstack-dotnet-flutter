import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sol_catalog/core/di/injection.dart';
import 'package:sol_catalog/core/widgets/app_empty_view.dart';
import 'package:sol_catalog/core/widgets/app_error_view.dart';
import 'package:sol_catalog/core/widgets/app_skeleton_list.dart';
import 'package:sol_catalog/features/products/domain/entities/product.dart';
import 'package:sol_catalog/features/products/domain/repositories/product_repository.dart';
import 'package:sol_catalog/features/products/presentation/bloc/product_list_bloc.dart';
import 'package:sol_catalog/features/products/presentation/widgets/edit_price_sheet.dart';
import 'package:sol_catalog/features/products/presentation/widgets/product_card.dart';
import 'package:sol_catalog/features/products/presentation/widgets/product_search_field.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di<ProductListBloc>()..add(const ProductsRequested()),
      child: const ProductListView(),
    );
  }
}

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final remaining =
        _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;

    if (remaining < 400) {
      context.read<ProductListBloc>().add(const NextPageRequested());
    }
  }

  Future<void> _refresh() async {
    context.read<ProductListBloc>().add(const ProductsRequested());
    await context.read<ProductListBloc>().stream.firstWhere(
      (state) => state is! ProductListLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ProductListBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo'),
        actions: [
          BlocBuilder<ProductListBloc, ProductListState>(
            buildWhen: (previous, current) => current is ProductListLoaded,
            builder: (context, state) => _SortMenu(
              query: state is ProductListLoaded
                  ? state.query
                  : const ProductQuery(),
              onSort: (field, dir) => bloc.add(SortChanged(field, dir)),
              onStock: ({required onlyInStock}) =>
                  bloc.add(StockFilterToggled(onlyInStock: onlyInStock)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: ProductSearchField(
            onChanged: (text) => bloc.add(SearchChanged(text)),
          ),
        ),
      ),
      body: BlocBuilder<ProductListBloc, ProductListState>(
        builder: (context, state) {
          return switch (state) {
            ProductListInitial() ||
            ProductListLoading() => const AppSkeletonList(),

            ProductListError(:final failure) => AppErrorView(
              failure: failure,
              onRetry: () => bloc.add(const ProductsRequested()),
            ),

            final ProductListLoaded loaded when loaded.isEmptyBySearch =>
              AppEmptyView.search(
                query: loaded.query.search,
                onClear: () => bloc.add(const SearchChanged('')),
              ),

            final ProductListLoaded loaded when loaded.isEmpty =>
              const AppEmptyView(
                message: 'Todavía no hay productos en el catálogo.',
              ),

            final ProductListLoaded loaded => RefreshIndicator(
              onRefresh: _refresh,
              child: _ProductList(state: loaded, controller: _scrollController),
            ),
          };
        },
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList({required this.state, required this.controller});

  final ProductListLoaded state;
  final ScrollController controller;

  Future<void> _editPrice(BuildContext context, Product product) async {
    final bloc = context.read<ProductListBloc>();
    final updated = await showEditPriceSheet(context, product);

    if (updated == null) return;

    bloc.add(ProductUpdated(updated));
  }

  @override
  Widget build(BuildContext context) {
    final products = state.products;

    return ListView.separated(
      controller: controller,
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: products.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == products.length) {
          return _ListFooter(state: state);
        }

        final product = products[index];

        return ProductCard(
          onTap: () => unawaited(_editPrice(context, product)),
          key: ValueKey(product.id),
          product: product,
        );
      },
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.state});

  final ProductListLoaded state;

  @override
  Widget build(BuildContext context) {
    final texts = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.loadMoreFailure case final failure?) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              failure.message,
              textAlign: TextAlign.center,
              style: texts.bodySmall?.copyWith(color: scheme.error),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => context.read<ProductListBloc>().add(
                const NextPageRequested(),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          state.page.hasNext
              ? 'Mostrando ${state.products.length} de ${state.page.total}'
              : '${state.page.total} producto${state.page.total == 1 ? '' : 's'}',
          style: texts.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _SortMenu extends StatelessWidget {
  const _SortMenu({
    required this.query,
    required this.onSort,
    required this.onStock,
  });

  final ProductQuery query;
  final void Function(ProductSortField, SortDirection) onSort;
  final void Function({required bool onlyInStock}) onStock;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      icon: const Icon(Icons.tune),
      tooltip: 'Ordenar y filtrar',
      itemBuilder: (context) => [
        for (final field in ProductSortField.values)
          for (final dir in SortDirection.values)
            PopupMenuItem<void>(
              onTap: () => onSort(field, dir),
              child: Row(
                children: [
                  Icon(
                    query.sortBy == field && query.sortDir == dir
                        ? Icons.check
                        : null,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text('${field.label} ${dir.label}'),
                ],
              ),
            ),
        const PopupMenuDivider(),
        PopupMenuItem<void>(
          onTap: () => onStock(onlyInStock: !query.onlyInStock),
          child: Row(
            children: [
              Icon(query.onlyInStock ? Icons.check : null, size: 18),
              const SizedBox(width: 8),
              const Text('Solo con stock'),
            ],
          ),
        ),
      ],
    );
  }
}
