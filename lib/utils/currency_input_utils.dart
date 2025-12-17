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
