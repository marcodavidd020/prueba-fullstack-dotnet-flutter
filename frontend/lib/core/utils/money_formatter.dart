import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

abstract final class MoneyFormatter {
  static const _symbols = <String, String>{
    'BOB': 'Bs ',
    'USD': r'$ ',
    'EUR': '€ ',
  };

  static String format(Decimal amount, String currency, {String? locale}) {
    final formatter = NumberFormat.currency(
      locale: locale ?? 'es_BO',
      symbol: _symbols[currency.toUpperCase()] ?? '$currency ',
      decimalDigits: 2,
    );

    return formatter.format(amount.toDouble());
  }

  static Decimal? parse(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return Decimal.tryParse(value.trim());
  }

  static String toWire(Decimal amount) => amount.toStringAsFixed(2);
}
