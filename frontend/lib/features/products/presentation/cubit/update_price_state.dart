part of 'update_price_cubit.dart';

sealed class UpdatePriceState extends Equatable {
  const UpdatePriceState();

  bool get isSubmitting => this is UpdatePriceSubmitting;

  @override
  List<Object?> get props => [];
}

final class UpdatePriceIdle extends UpdatePriceState {
  const UpdatePriceIdle();
}

final class UpdatePriceSubmitting extends UpdatePriceState {
  const UpdatePriceSubmitting();
}

final class UpdatePriceSuccess extends UpdatePriceState {
  const UpdatePriceSuccess(this.product);

  final Product product;

  @override
  List<Object?> get props => [product];
}

final class UpdatePriceFailure extends UpdatePriceState {
  const UpdatePriceFailure(this.failure);

  final Failure failure;

  String? get priceError => switch (failure) {
    final ValidationFailure v => v.forField('price'),
    _ => null,
  };

  String? get currencyError => switch (failure) {
    final ValidationFailure v => v.forField('currency'),
    _ => null,
  };

  bool get isConflict => failure is ConflictFailure;

  @override
  List<Object?> get props => [failure];
}
