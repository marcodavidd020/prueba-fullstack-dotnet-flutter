import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sol_catalog/core/error/failure.dart';
import 'package:sol_catalog/features/products/domain/entities/product.dart';
import 'package:sol_catalog/features/products/domain/usecases/update_product_price_usecase.dart';

part 'update_price_state.dart';

class UpdatePriceCubit extends Cubit<UpdatePriceState> {
  UpdatePriceCubit(this._updateProductPrice) : super(const UpdatePriceIdle());

  final UpdateProductPriceUseCase _updateProductPrice;

  void reset() {
    if (state is UpdatePriceFailure) emit(const UpdatePriceIdle());
  }

  Future<void> submit({
    required Product product,
    required Decimal price,
    required String currency,
  }) async {
    if (state is UpdatePriceSubmitting) return;

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
