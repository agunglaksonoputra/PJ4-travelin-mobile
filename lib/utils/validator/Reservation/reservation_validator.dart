class ReservationValidationResult {
  final String? customerNameError;
  final String? customerPhoneError;
  final String? vehicleError;
  final String? tariffError;
  final String? leaveDateError;
  final String? returnDateError;
  final String? tripCategoryError;
  final String? destinationError;
  final String? totalCostError;
  final String? notesError;

  const ReservationValidationResult({
    this.customerNameError,
    this.customerPhoneError,
    this.vehicleError,
    this.tariffError,
    this.leaveDateError,
    this.returnDateError,
    this.tripCategoryError,
    this.destinationError,
    this.totalCostError,
    this.notesError,
  });

  bool get isValid =>
      customerNameError == null &&
      customerPhoneError == null &&
      vehicleError == null &&
      tariffError == null &&
      leaveDateError == null &&
      returnDateError == null &&
      tripCategoryError == null &&
      destinationError == null &&
      totalCostError == null &&
      notesError == null;
}

class ReservationValidator {
  /// Validates customer name
  /// Returns error message if validation fails, null if valid
  static String? validateCustomerName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama customer wajib diisi';
    }

    if (value.length < 3) {
      return 'Nama customer minimal 3 karakter';
    }

    if (value.length > 100) {
      return 'Nama customer maksimal 100 karakter';
    }

    return null;
  }

  /// Validates customer phone number
  /// Returns error message if validation fails, null if valid
  static String? validateCustomerPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon wajib diisi';
    }

    // Remove non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length < 10) {
      return 'Nomor telepon minimal 10 digit';
    }

    if (digitsOnly.length > 15) {
      return 'Nomor telepon maksimal 15 digit';
    }

    return null;
  }

  /// Validates vehicle selection
  /// Returns error message if validation fails, null if valid
  static String? validateVehicle(dynamic vehicleId) {
    if (vehicleId == null) {
      return 'Pilih kendaraan terlebih dahulu';
    }

    return null;
  }

  /// Validates tariff selection
  /// Returns error message if validation fails, null if valid
  static String? validateTariff(dynamic tariffId) {
    if (tariffId == null) {
      return 'Pilih tarif terlebih dahulu';
    }

    return null;
  }

  /// Validates leave date
  /// Returns error message if validation fails, null if valid
  static String? validateLeaveDate(DateTime? value) {
    if (value == null) {
      return 'Tanggal keberangkatan wajib diisi';
    }

    if (value.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return 'Tanggal keberangkatan tidak boleh di masa lalu';
    }

    return null;
  }

  /// Validates return date
  /// Returns error message if validation fails, null if valid
  static String? validateReturnDate(DateTime? returnDate, DateTime? leaveDate) {
    if (returnDate == null) {
      return 'Tanggal kembali wajib diisi';
    }

    if (leaveDate != null && returnDate.isBefore(leaveDate)) {
      return 'Tanggal kembali tidak boleh sebelum tanggal berangkat';
    }

    return null;
  }

  /// Validates trip category
  /// Returns error message if validation fails, null if valid
  /// Note: Trip category is optional, returns null only
  static String? validateTripCategory(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length > 50) {
        return 'Kategori perjalanan maksimal 50 karakter';
      }
    }
    return null;
  }

  /// Validates destination
  /// Returns error message if validation fails, null if valid
  /// Note: Destination is optional, returns null only
  static String? validateDestination(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length > 100) {
        return 'Destinasi maksimal 100 karakter';
      }
    }
    return null;
  }

  /// Validates total cost
  /// Returns error message if validation fails, null if valid
  static String? validateTotalCost(double? amount) {
    if (amount == null) {
      return 'Total biaya wajib diisi';
    }

    if (amount <= 0) {
      return 'Total biaya harus lebih dari 0';
    }

    return null;
  }

  /// Validates notes
  /// Returns error message if validation fails, null if valid
  /// Note: Notes is optional, returns null only
  static String? validateNotes(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length > 500) {
        return 'Catatan maksimal 500 karakter';
      }
    }
    return null;
  }

  /// Validates all reservation form fields
  /// Returns ReservationValidationResult with all validation errors
  static ReservationValidationResult validateReservationForm({
    required String? customerName,
    required String? customerPhone,
    required dynamic vehicleId,
    required dynamic tariffId,
    required DateTime? leaveDate,
    required DateTime? returnDate,
    required String? tripCategory,
    required String? destination,
    required double? totalCost,
    required String? notes,
  }) {
    final customerNameError = validateCustomerName(customerName);
    final customerPhoneError = validateCustomerPhone(customerPhone);
    final vehicleError = validateVehicle(vehicleId);
    final tariffError = validateTariff(tariffId);
    final leaveDateError = validateLeaveDate(leaveDate);
    final returnDateError = validateReturnDate(returnDate, leaveDate);
    final tripCategoryError = validateTripCategory(tripCategory);
    final destinationError = validateDestination(destination);
    final totalCostError = validateTotalCost(totalCost);
    final notesError = validateNotes(notes);

    return ReservationValidationResult(
      customerNameError: customerNameError,
      customerPhoneError: customerPhoneError,
      vehicleError: vehicleError,
      tariffError: tariffError,
      leaveDateError: leaveDateError,
      returnDateError: returnDateError,
      tripCategoryError: tripCategoryError,
      destinationError: destinationError,
      totalCostError: totalCostError,
      notesError: notesError,
    );
  }
}
