import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sol_catalog/core/di/injection.dart';
import 'package:sol_catalog/core/utils/money_formatter.dart';
import 'package:sol_catalog/features/products/domain/entities/product.dart';
import 'package:sol_catalog/features/products/presentation/cubit/update_price_cubit.dart';

Future<Product?> showEditPriceSheet(BuildContext context, Product product) {
  return showModalBottomSheet<Product>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => BlocProvider(
      create: (_) => di<UpdatePriceCubit>(),
      child: _EditPriceSheet(product: product),
    ),
  );
}

class _EditPriceSheet extends StatefulWidget {
  const _EditPriceSheet({required this.product});

  final Product product;

  @override
  State<_EditPriceSheet> createState() => _EditPriceSheetState();
}

class _EditPriceSheetState extends State<_EditPriceSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _priceController;
  late String _currency;
  late Product _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _priceController = TextEditingController(
      text: MoneyFormatter.toWire(_product.price),
    );
    _currency = _product.currency;
  }

  bool get _wasReloaded => _product != widget.product;

  void _close() => Navigator.of(context).pop(_wasReloaded ? _product : null);

  void _adoptReloaded(Product fresh) {
    setState(() {
      _product = fresh;
      _currency = fresh.currency;
      _priceController.text = MoneyFormatter.toWire(fresh.price);
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El precio es obligatorio.';
    }

    final amount = Decimal.tryParse(value.trim());

    if (amount == null) {
      return 'Ingresá un número válido, por ejemplo 249.90.';
    }

    if (amount <= Decimal.zero) {
      return 'El precio debe ser mayor a 0.';
    }

    return null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final amount = Decimal.parse(_priceController.text.trim());

    unawaited(
      context.read<UpdatePriceCubit>().submit(
        product: _product,
        price: amount,
        currency: _currency,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texts = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return BlocConsumer<UpdatePriceCubit, UpdatePriceState>(
      listener: (context, state) {
        switch (state) {
          case UpdatePriceSuccess(:final product):
            Navigator.of(context).pop(product);

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    'Precio actualizado a '
                    '${MoneyFormatter.format(product.price, product.currency)}',
                  ),
                ),
              );

          case UpdatePriceReloaded(:final product):
            _adoptReloaded(product);

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Precio actualizado desde el servidor'),
                ),
              );

          case UpdatePriceFailure() ||
              UpdatePriceIdle() ||
              UpdatePriceSubmitting() ||
              UpdatePriceReloading():
            break;
        }
      },
      builder: (context, state) {
        final serverError = state is UpdatePriceFailure
            ? state.priceError
            : null;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: scheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                    child: state.isReloading
                        ? const Align(
                            alignment: Alignment.bottomCenter,
                            child: LinearProgressIndicator(minHeight: 3),
                          )
                        : null,
                  ),

                  Text('Editar precio', style: texts.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    _product.name,
                    style: texts.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _product.sku,
                    style: texts.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _priceController,
                          autofocus: true,
                          enabled: !state.isBusy,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Precio',
                            errorText: serverError,
                          ),
                          validator: _validatePrice,
                          onChanged: (_) =>
                              context.read<UpdatePriceCubit>().reset(),
                          onFieldSubmitted: (_) => _submit(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _currency,
                          decoration: const InputDecoration(
                            labelText: 'Moneda',
                          ),
                          items: const [
                            DropdownMenuItem(value: 'BOB', child: Text('BOB')),
                            DropdownMenuItem(value: 'USD', child: Text('USD')),
                            DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                          ],
                          onChanged: state.isSubmitting
                              ? null
                              : (value) => setState(
                                  () => _currency = value ?? _currency,
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (state
                      case UpdatePriceFailure(
                        :final failure,
                        :final priceError,
                        :final currencyError,
                        :final isConflict,
                      )
                      when priceError == null && currencyError == null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: scheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isConflict
                                ? Icons.sync_problem_outlined
                                : Icons.error_outline,
                            size: 20,
                            color: scheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  failure.message,
                                  style: texts.bodySmall?.copyWith(
                                    color: scheme.onErrorContainer,
                                  ),
                                ),
                                if (isConflict) ...[
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: FilledButton.tonalIcon(
                                      onPressed: state.isBusy
                                          ? null
                                          : () => unawaited(
                                              context
                                                  .read<UpdatePriceCubit>()
                                                  .reload(_product.id),
                                            ),
                                      icon: state.isReloading
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.refresh, size: 18),
                                      label: const Text('Recargar precio'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  Text(
                    'Precio actual: '
                    '${MoneyFormatter.format(_product.price, _product.currency)}',
                    style: texts.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: state.isBusy ? null : _close,
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: state.isBusy ? null : _submit,
                          child: state.isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Guardar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
