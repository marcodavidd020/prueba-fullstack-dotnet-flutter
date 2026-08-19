import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sol_catalog/core/error/failure.dart';
import 'package:sol_catalog/features/products/domain/entities/product.dart';
import 'package:sol_catalog/features/products/domain/usecases/get_product_usecase.dart';
import 'package:sol_catalog/features/products/domain/usecases/update_product_price_usecase.dart';

part 'update_price_state.dart';

class UpdatePriceCubit extends Cubit<UpdatePriceState> {
  UpdatePriceCubit(this._updateProductPrice, this._getProduct)
    : super(const UpdatePriceIdle());

  final UpdateProductPriceUseCase _updateProductPrice;
  final GetProductUseCase _getProduct;

  void reset() {
    if (state is UpdatePriceFailure) emit(const UpdatePriceIdle());
  }

  Future<void> reload(int id) async {
    if (state.isBusy) return;

    emit(const UpdatePriceReloading());

    try {
      final fresh = await _getProduct(id);
      if (!isClosed) emit(UpdatePriceReloaded(fresh));
    } on Failure catch (e) {
      if (!isClosed) emit(UpdatePriceFailure(e));
    } on Object catch (e) {
      if (!isClosed) {
        emit(
          UpdatePriceFailure(
            UnexpectedFailure('No pudimos recargar el producto: $e'),
          ),
        );
      }
    }
  }

  Future<void> submit({
    required Product product,
    required Decimal price,
    required String currency,
  }) async {
    if (state.isBusy) return;

    emit(const UpdatePriceSubmitting());

    try {
      final updated = await _updateProductPrice(
        id: product.id,
        price: price,
        currency: currency,
        expectedVersion: product.version,
      );

      if (!isClosed) emit(UpdatePriceSuccess(updated));
    } on Failure catch (e) {
      if (!isClosed) emit(UpdatePriceFailure(e));
    } on Object catch (e) {
      if (!isClosed) {
        emit(
          UpdatePriceFailure(
            UnexpectedFailure('No pudimos guardar el precio: $e'),
          ),
        );
      }
    }
  }
}
