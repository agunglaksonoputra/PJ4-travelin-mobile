import 'package:intl/intl.dart';

class CurrencyUtils {
  static String format(num value) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  static String formatWithDecimals(num value, {int decimals = 2}) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: decimals,
    ).format(value);
  }

  static String compact(num value) {
    return NumberFormat.compactCurrency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(value);
  }

  static String raw(num value) {
    return NumberFormat('#,###', 'id_ID').format(value);
  }
}