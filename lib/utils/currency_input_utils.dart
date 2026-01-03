import 'package:intl/intl.dart';

class CurrencyInputFormatResult {
  const CurrencyInputFormatResult({
    required this.shouldUpdateText,
    required this.isOverride,
    this.formattedValue,
    this.shouldClear = false,
  });

  final bool shouldUpdateText;
  final bool isOverride;
  final String? formattedValue;
  final bool shouldClear;
}

CurrencyInputFormatResult formatCurrencyInput(
  String rawValue,
  NumberFormat formatter,
) {
  final trimmed = rawValue.trim();
  final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');

  if (digitsOnly.isEmpty) {
    return const CurrencyInputFormatResult(
      shouldUpdateText: true,
      shouldClear: true,
      isOverride: false,
      formattedValue: null,
    );
  }

  final amount = double.tryParse(digitsOnly);
  if (amount == null) {
    return const CurrencyInputFormatResult(
      shouldUpdateText: false,
      isOverride: false,
      formattedValue: null,
    );
  }

  final formatted = formatter.format(amount);
  final shouldUpdate = formatted != trimmed;

  return CurrencyInputFormatResult(
    shouldUpdateText: shouldUpdate,
    isOverride: true,
    formattedValue: formatted,
  );
}

/// Parse currency string to double value
/// Handles various formats including 'Rp 1.000.000', '1,000.00', etc.
/// Returns null if the value is invalid or <= 0
double? parseCurrencyToDouble(String? raw) {
  if (raw == null) return null;
  var s = raw.trim();
  if (s.isEmpty) return null;

  // Remove currency symbols and spaces
  s = s.replaceAll(RegExp(r"[\sRp]", caseSensitive: false), "");

  // Handle mixed decimal formats (e.g., "1.000,00" or "1,000.00")
  if (s.contains('.') && s.contains(',')) {
    // Assume . is thousands separator and , is decimal
    s = s.replaceAll('.', '').replaceAll(',', '.');
  } else {
    // If only comma exists, treat comma as decimal and remove any dot thousands
    if (s.contains(',') && !s.contains('.')) {
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else if (s.contains('.') && !s.contains(',')) {
      // Only dot exists. Decide if it's decimal or thousands separator.
      final dotCount = '.'.allMatches(s).length;
      if (dotCount > 1) {
        // Multiple dots -> treat as thousands separators
        s = s.replaceAll('.', '');
      } else {
        // Single dot. If the group after the dot has length 3 (e.g., 160.000),
        // treat as thousands separator and remove it; otherwise treat as decimal.
        final lastDot = s.lastIndexOf('.');
        final digitsAfter = s.length - lastDot - 1;
        if (digitsAfter == 3) {
          s = s.replaceAll('.', '');
        }
      }
    } else {}
  }

  // Remove any remaining non-numeric characters except decimal point
  s = s.replaceAll(RegExp(r"[^0-9.]"), "");

  if (s.isEmpty || s == '.') return null;

  try {
    final value = double.parse(s);
    if (value <= 0) return null;
    return value;
  } catch (_) {
    return null;
  }
}
