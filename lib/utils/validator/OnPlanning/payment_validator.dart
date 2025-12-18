class PaymentValidationResult {
  final String? amountError;
  final String? methodError;
  final String? dateError;
  final String? paymentTypeError;

  const PaymentValidationResult({
    this.amountError,
    this.methodError,
    this.dateError,
    this.paymentTypeError,
  });

  bool get isValid =>
      amountError == null &&
      methodError == null &&
      dateError == null &&
      paymentTypeError == null;
}

class PaymentValidator {
  /// Validates payment amount
  /// Returns error message if validation fails, null if valid
  static String? validateAmount({
    required double? amount,
    required double remainingBalance,
    required String? method,
  }) {
    if (amount == null) {
      return 'Nominal tidak valid';
    }

    if (amount <= 0) {
      return 'Nominal tidak boleh negatif';
    }

    if (method == 'credit' && amount > remainingBalance) {
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

  /// Validates payment date
  /// Returns error message if validation fails, null if valid
  static String? validateDate(String? dateText) {
    if (dateText == null || dateText.trim().isEmpty) {
      return 'Tanggal harus diisi';
    }
    return null;
  }

  /// Validates payment type
  /// Returns error message if validation fails, null if valid
  static String? validatePaymentType(String? paymentType) {
    if (paymentType == null || paymentType.trim().isEmpty) {
      return 'Pilih tipe pembayaran';
    }
    return null;
  }

  /// Validates all payment form fields
  /// Returns PaymentValidationResult with all validation errors
  static PaymentValidationResult validatePaymentForm({
    required double? amount,
    required String? method,
    required double remainingBalance,
    required String? dateText,
    required String? paymentType,
  }) {
    final amountError = validateAmount(
      amount: amount,
      remainingBalance: remainingBalance,
      method: method,
    );

    final methodError = validateMethod(method);
    final dateError = validateDate(dateText);
    final paymentTypeError = validatePaymentType(paymentType);

    return PaymentValidationResult(
      amountError: amountError,
      methodError: methodError,
      dateError: dateError,
      paymentTypeError: paymentTypeError,
    );
  }

  /// Formats remaining balance error message
  static String formatAmountExceedsBalanceError(double remainingBalance) {
    return 'Nominal melebihi sisa hutang (${_formatCurrency(remainingBalance)})';
  }

  static String _formatCurrency(double value) {
    // Simple Indonesian currency formatting
    final formatted = value.toStringAsFixed(2);
    return 'Rp $formatted';
  }
}
