import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:sol_catalog/core/di/injection.dart';
import 'package:sol_catalog/core/router/app_router.dart';
import 'package:sol_catalog/core/theme/app_theme.dart';

void main() {
  unawaited(
    runZonedGuarded(
      () async {
        WidgetsFlutterBinding.ensureInitialized();

        usePathUrlStrategy();

        FlutterError.onError = (details) {
          FlutterError.presentError(details);
          debugPrint('[FlutterError] ${details.exceptionAsString()}');
        };

        await configureDependencies();

        runApp(const SolCatalogApp());
      },
      (error, stack) => debugPrint('[Zone] $error\n$stack'),
    ),
  );
}

class SolCatalogApp extends StatelessWidget {
  const SolCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Catálogo de productos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: di<AppRouter>().config,
    );
  }
}
