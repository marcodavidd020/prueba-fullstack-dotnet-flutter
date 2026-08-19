import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sol_catalog/features/products/presentation/pages/product_list_page.dart';

class AppRouter {
  static const productList = 'productList';

  late final GoRouter config = GoRouter(
    initialLocation: '/products',
    routes: [
      GoRoute(
        path: '/products',
        name: productList,
        builder: (context, state) => const ProductListPage(),
      ),
    ],
    errorBuilder: (context, state) => const _InvalidRoute(),
  );
}

class _InvalidRoute extends StatelessWidget {
  const _InvalidRoute();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Página no encontrada')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.explore_off_outlined, size: 56),
            const SizedBox(height: 16),
            const Text('Esta dirección no existe.'),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: () => context.goNamed(AppRouter.productList),
              child: const Text('Ir al catálogo'),
            ),
          ],
        ),
      ),
    );
  }
}
