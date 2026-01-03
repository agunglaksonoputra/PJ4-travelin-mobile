class PaymentValidationResult {
  final String? amountError;
  final String? methodError;

  const PaymentValidationResult({this.amountError, this.methodError});

  bool get isValid => amountError == null && methodError == null;
}

class PaymentValidator {
  /// Validates payment amount
  /// Returns error message if validation fails, null if valid
  static String? validateAmount({
    required double? amount,
    required double? remainingBalance,
  }) {
    if (amount == null) {
      return 'Nominal tidak valid';
    }

    if (amount <= 0) {
      return 'Masukkan nominal pembayaran yang valid';
    }

    if (remainingBalance != null &&
        remainingBalance > 0 &&
        amount > remainingBalance) {
      return 'Nominal melebihi sisa hutang';
    }

    return null;
  }

  /// Validates payment method
  /// Returns error message if validation fails, null if valid
  static String? validateMethod(String? method) {
    if (method == null || method.isEmpty) {
      return 'Pilih metode pembayaran';
    }
    return null;
  }

  /// Validates all payment form fields
  /// Returns PaymentValidationResult with all validation errors
  static PaymentValidationResult validatePaymentForm({
    required double? amount,
    required String? method,
    required double? remainingBalance,
  }) {
    final amountError = validateAmount(
      amount: amount,
      remainingBalance: remainingBalance,
    );

    final methodError = validateMethod(method);

    return PaymentValidationResult(
      amountError: amountError,
      methodError: methodError,
    );
  }
}
