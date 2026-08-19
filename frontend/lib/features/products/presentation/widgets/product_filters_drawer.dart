import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sol_catalog/features/products/domain/repositories/product_repository.dart';

class ProductFiltersDrawer extends StatefulWidget {
  const ProductFiltersDrawer({
    required this.query,
    required this.onApply,
    super.key,
  });

  final ProductQuery query;
  final void Function(FiltersDraft draft) onApply;

  @override
  State<ProductFiltersDrawer> createState() => _ProductFiltersDrawerState();
}

class FiltersDraft {
  const FiltersDraft({
    required this.sortBy,
    required this.sortDir,
    required this.onlyInStock,
    this.minPrice,
    this.maxPrice,
    this.currency,
  });

  final ProductSortField sortBy;
  final SortDirection sortDir;
  final bool onlyInStock;
  final Decimal? minPrice;
  final Decimal? maxPrice;
  final String? currency;
}

class _ProductFiltersDrawerState extends State<ProductFiltersDrawer> {
  static const _currencies = ['BOB', 'USD', 'EUR'];

  late ProductSortField _sortBy;
  late SortDirection _sortDir;
  late bool _onlyInStock;
  late String? _currency;
  late final TextEditingController _minController;
  late final TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    _sortBy = widget.query.sortBy;
    _sortDir = widget.query.sortDir;
    _onlyInStock = widget.query.onlyInStock;
    _currency = widget.query.currency;
    _minController = TextEditingController(
      text: widget.query.minPrice?.toString() ?? '',
    );
    _maxController = TextEditingController(
      text: widget.query.maxPrice?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _sortBy = ProductSortField.name;
      _sortDir = SortDirection.asc;
      _onlyInStock = false;
      _currency = null;
      _minController.clear();
      _maxController.clear();
    });
  }

  void _apply() {
    final min = Decimal.tryParse(_minController.text.trim());
    final max = Decimal.tryParse(_maxController.text.trim());

    widget.onApply(
      FiltersDraft(
        sortBy: _sortBy,
        sortDir: _sortDir,
        onlyInStock: _onlyInStock,
        minPrice: min,
        maxPrice: max,
        currency: _currency,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final texts = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Drawer(
      width: 360,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Ordenar y filtrar', style: texts.titleLarge),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                children: [
                  const _SectionLabel('Ordenar por'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final field in ProductSortField.values)
                        ChoiceChip(
                          label: Text(field.label),
                          selected: _sortBy == field,
                          onSelected: (_) => setState(() => _sortBy = field),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<SortDirection>(
                    segments: const [
                      ButtonSegment(
                        value: SortDirection.asc,
                        label: Text('Ascendente'),
                        icon: Icon(Icons.arrow_upward, size: 16),
                      ),
                      ButtonSegment(
                        value: SortDirection.desc,
                        label: Text('Descendente'),
                        icon: Icon(Icons.arrow_downward, size: 16),
                      ),
                    ],
                    selected: {_sortDir},
                    onSelectionChanged: (selection) =>
                        setState(() => _sortDir = selection.first),
                  ),

                  const SizedBox(height: 32),
                  const _SectionLabel('Rango de precio'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Desde',
                            hintText: '0.00',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _maxController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Hasta',
                            hintText: 'sin tope',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const _SectionLabel('Moneda'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Todas'),
                        selected: _currency == null,
                        onSelected: (_) => setState(() => _currency = null),
                      ),
                      for (final code in _currencies)
                        ChoiceChip(
                          label: Text(code),
                          selected: _currency == code,
                          onSelected: (_) => setState(() => _currency = code),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  SwitchListTile(
                    value: _onlyInStock,
                    onChanged: (value) => setState(() => _onlyInStock = value),
                    title: const Text('Solo con stock'),
                    subtitle: const Text('Oculta los productos agotados'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: scheme.outlineVariant)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      child: const Text('Limpiar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _apply,
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
