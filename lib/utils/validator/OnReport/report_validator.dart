class ReportValidationResult {
  final String? driverNameError;
  final String? kmStartError;
  final String? kmEndError;
  final String? driverFeeError;
  final String? gasolineError;
  final String? tollCostError;
  final String? parkingCostError;
  final String? othersError;

  const ReportValidationResult({
    this.driverNameError,
    this.kmStartError,
    this.kmEndError,
    this.driverFeeError,
    this.gasolineError,
    this.tollCostError,
    this.parkingCostError,
    this.othersError,
  });

  bool get isValid =>
      driverNameError == null &&
      kmStartError == null &&
      kmEndError == null &&
      driverFeeError == null &&
      gasolineError == null &&
      tollCostError == null &&
      parkingCostError == null &&
      othersError == null;
}

class ReportValidator {
  /// Validates driver name
  /// Returns error message if validation fails, null if valid
  static String? validateDriverName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Driver Name tidak boleh kosong';
    }

    if (value.length < 3) {
      return 'Driver Name minimal 3 karakter';
    }

    return null;
  }

  /// Validates KM Start value
  /// Returns error message if validation fails, null if valid
  static String? validateKmStart(int? value) {
    if (value == null) {
      return 'KM Start tidak boleh kosong';
    }

    if (value < 0) {
      return 'KM Start tidak boleh negatif';
    }

    return null;
  }

  /// Validates KM End value
  /// Returns error message if validation fails, null if valid
  static String? validateKmEnd(int? kmEnd, int? kmStart) {
    if (kmEnd == null) {
      return 'KM End tidak boleh kosong';
    }

    if (kmEnd < 0) {
      return 'KM End tidak boleh negatif';
    }

    if (kmStart != null && kmEnd < kmStart) {
      return 'KM End tidak boleh kurang dari KM Start';
    }

    return null;
  }

  /// Validates driver fee amount
  /// Returns error message if validation fails, null if valid
  static String? validateDriverFee(double? amount) {
    if (amount == null) {
      return 'Driver Fee tidak boleh kosong';
    }

    if (amount < 0) {
      return 'Driver Fee tidak boleh negatif';
    }

    return null;
  }

  /// Validates gasoline cost amount
  /// Returns error message if validation fails, null if valid
  static String? validateGasoline(double? amount) {
    if (amount == null) {
      return 'Gasoline tidak boleh kosong';
    }

    if (amount < 0) {
      return 'Gasoline tidak boleh negatif';
    }

    return null;
  }

  /// Validates toll cost amount
  /// Returns error message if validation fails, null if valid
  static String? validateTollCost(double? amount) {
    if (amount == null) {
      return 'Toll Cost tidak boleh kosong';
    }

    if (amount < 0) {
      return 'Toll Cost tidak boleh negatif';
    }

    return null;
  }

  /// Validates parking cost amount
  /// Returns error message if validation fails, null if valid
  static String? validateParkingCost(double? amount) {
    if (amount == null) {
      return 'Parking Cost tidak boleh kosong';
    }

    if (amount < 0) {
      return 'Parking Cost tidak boleh negatif';
    }

    return null;
  }

  /// Validates other/misc cost amount
  /// Returns error message if validation fails, null if valid
  static String? validateOthers(double? amount) {
    if (amount == null) {
      return 'Others tidak boleh kosong';
    }

    if (amount < 0) {
      return 'Others tidak boleh negatif';
    }

    return null;
  }

  /// Validates all report form fields
  /// Returns ReportValidationResult with all validation errors
  static ReportValidationResult validateReportForm({
    required String? driverName,
    required int? kmStart,
    required int? kmEnd,
    required double? driverFee,
    required double? gasoline,
    required double? tollCost,
    required double? parkingCost,
    required double? others,
  }) {
    final driverNameError = validateDriverName(driverName);
    final kmStartError = validateKmStart(kmStart);
    final kmEndError = validateKmEnd(kmEnd, kmStart);
    final driverFeeError = validateDriverFee(driverFee);
    final gasolineError = validateGasoline(gasoline);
    final tollCostError = validateTollCost(tollCost);
    final parkingCostError = validateParkingCost(parkingCost);
    final othersError = validateOthers(others);

    return ReportValidationResult(
      driverNameError: driverNameError,
      kmStartError: kmStartError,
      kmEndError: kmEndError,
      driverFeeError: driverFeeError,
      gasolineError: gasolineError,
      tollCostError: tollCostError,
      parkingCostError: parkingCostError,
      othersError: othersError,
    );
  }
}
