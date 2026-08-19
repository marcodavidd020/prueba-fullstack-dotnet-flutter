import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:sol_catalog/core/config/app_config.dart';
import 'package:sol_catalog/features/products/data/datasources/product_remote_data_source.dart';
import 'package:sol_catalog/features/products/data/repositories/product_repository_impl.dart';
import 'package:sol_catalog/features/products/domain/repositories/product_repository.dart';
import 'package:sol_catalog/features/products/domain/usecases/get_product_usecase.dart';
import 'package:sol_catalog/features/products/domain/usecases/search_products_usecase.dart';
import 'package:sol_catalog/features/products/domain/usecases/update_product_price_usecase.dart';
import 'package:sol_catalog/features/products/presentation/bloc/product_list_bloc.dart';
import 'package:sol_catalog/features/products/presentation/cubit/update_price_cubit.dart';

abstract final class ProductsModule {
  static void registerDependencies(GetIt di) {
    di
      ..registerLazySingleton(
        () => ProductRemoteDataSource(di<Dio>(), di<AppConfig>()),
      )
      ..registerLazySingleton<ProductRepository>(
        () => ProductRepositoryImpl(di<ProductRemoteDataSource>()),
      )
      ..registerLazySingleton(
        () => SearchProductsUseCase(di<ProductRepository>()),
      )
      ..registerLazySingleton(
        () => UpdateProductPriceUseCase(di<ProductRepository>()),
      )
      ..registerLazySingleton(() => GetProductUseCase(di<ProductRepository>()))
      ..registerFactory(
        () => ProductListBloc(di<SearchProductsUseCase>(), di<AppConfig>()),
      )
      ..registerFactory(
        () => UpdatePriceCubit(
          di<UpdateProductPriceUseCase>(),
          di<GetProductUseCase>(),
        ),
      );
  }
}
