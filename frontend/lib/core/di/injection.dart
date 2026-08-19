import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:sol_catalog/core/config/app_config.dart';
import 'package:sol_catalog/core/network/dio_client.dart';
import 'package:sol_catalog/core/router/app_router.dart';
import 'package:sol_catalog/features/products/products_module.dart';

final GetIt di = GetIt.instance;

Future<void> configureDependencies() async {
  di
    ..registerLazySingleton(AppConfig.new)
    ..registerLazySingleton<Dio>(() => buildDio(di<AppConfig>()))
    ..registerLazySingleton(AppRouter.new);

  ProductsModule.registerDependencies(di);
}
