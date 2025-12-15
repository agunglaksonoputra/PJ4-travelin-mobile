import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tariff_model.dart';
import '../models/transaction_models.dart';
import '../models/vehicle_models.dart';
import '../services/transaction_service.dart';
import '../utils/currency_input_utils.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/custom_flushbar.dart';
import '../widgets/tariff_dropdown.dart';
import '../widgets/vehicle_dropdown.dart';

class OnPlanningPage extends StatefulWidget {
  const OnPlanningPage({super.key});

  @override
  State<OnPlanningPage> createState() => _OnPlanningPageState();
}

class _OnPlanningPageState extends State<OnPlanningPage> {
  bool _isLoadingTransactions = false;
  String? _transactionError;
  VehicleModel? _selectedVehicle;
  TariffModel? _selectedTariff;
  List<TransactionModel> _transactions = [];

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 2,
  );

  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "On Planning",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/actual');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildVehicleDropdown(),
            const SizedBox(height: 12),
            _buildTariffDropdown(),
            const SizedBox(height: 20),
            Expanded(child: _buildTransactionSection()),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/actual');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/report');
              break;
          }
        },
      ),
    );
  }

  Widget _buildVehicleDropdown() {
    return VehicleDropdown(
      showLabel: false,
      initialVehicle: _selectedVehicle,
      onChanged: (vehicle) {
        setState(() {
          _selectedVehicle = vehicle;
          _transactions = [];
          _transactionError = null;
        });
        _loadTransactions();
      },
    );
  }

  Widget _buildTariffDropdown() {
    return TariffDropdown(
      showLabel: false,
      hintText: 'Filter tarif',
      includeAllItem: true,
      initialTariff: _selectedTariff,
      onChanged: (tariff) {
        setState(() {
          _selectedTariff = tariff;
          _transactions = [];
          _transactionError = null;
        });
        if (_selectedVehicle != null) {
          _loadTransactions();
        }
      },
      onCleared: () {
        if (_selectedTariff == null) return;
        setState(() {
          _selectedTariff = null;
          _transactions = [];
          _transactionError = null;
        });
        if (_selectedVehicle != null) {
          _loadTransactions();
        }
      },
    );
  }

  Widget _buildTransactionSection() {
    if (_selectedVehicle == null) {
      return _buildPlaceholder(
        icon: Icons.directions_bus,
        message: 'Pilih kendaraan untuk melihat transaksi planning.',
      );
    }

    if (_isLoadingTransactions) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_transactionError != null) {
      return _buildPlaceholder(
        icon: Icons.error_outline,
        message: _transactionError!,
        messageColor: Colors.redAccent,
      );
    }

    if (_transactions.isEmpty) {
      return _buildPlaceholder(
        icon: Icons.receipt_long,
        message: 'Belum ada transaksi planning untuk kendaraan ini.',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _transactions.length,
      itemBuilder:
          (context, index) =>
              _buildTripCard(context, _transactions[index], index),
    );
  }

  Future<void> _loadTransactions() async {
    final vehicleId = _selectedVehicle?.id;
    if (vehicleId == null) {
      setState(() {
        _transactions = [];
        _transactionError = null;
        _isLoadingTransactions = false;
      });
      return;
    }

    final tariffId = _selectedTariff?.id;

    setState(() {
      _isLoadingTransactions = true;
      _transactionError = null;
    });

    try {
      final items = await TransactionService.getTransactions(
        status: 'planning',
        vehicleId: vehicleId,
        tariffId: tariffId,
      );
      if (!mounted) return;
      setState(() {
        _transactions = items;
        _isLoadingTransactions = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingTransactions = false;
        _transactionError = e.toString();
        _transactions = [];
      });
    }
  }

  Widget _buildPlaceholder({
    required IconData icon,
    required String message,
    Color messageColor = Colors.black54,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Colors.black26),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: messageColor),
          ),
        ],
      ),
    );
  }

  String _tripSchedule(TransactionModel transaction) {
    final start = transaction.formattedStartDate;
    final end = transaction.formattedEndDate;

    if (start != null && end != null) {
      return '$start - $end';
    }

    return start ?? end ?? '-';
  }

  String _formatCurrency(double? value) {
    final amount = value ?? 0;
    return _currencyFormat.format(amount);
  }

  Widget _buildTripCard(
    BuildContext _,
    TransactionModel transaction,
    int index,
  ) {
    final schedule = _tripSchedule(transaction);
    final duration =
        transaction.durationDays != null
            ? '${transaction.durationDays} hari'
            : '-';
    final totalText = _formatCurrency(transaction.totalCost);
    final double paidAmount = transaction.paidAmount ?? 0;
    final bool hasAnyPayment = paidAmount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Trip #${index + 1} - ${transaction.tripCode}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(transaction.customerName, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Text('Jadwal: $schedule'),
          Text('Trip(s): $duration'),
          Text('Total: $totalText'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: hasAnyPayment ? Colors.grey : Colors.lightBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed:
                  hasAnyPayment
                      ? null
                      : () async {
                        await _showPaymentDialog(context, transaction);
                      },
              child: Text(
                hasAnyPayment ? 'PAYMENT RECORDED' : 'PAYMENT',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPaymentDialog(
    BuildContext context,
    TransactionModel transaction,
  ) async {
    final double existingPaidAmount = transaction.paidAmount?.toDouble() ?? 0;
    final double totalCost = transaction.totalCost?.toDouble() ?? 0;
    final double remainingBalance =
        totalCost > existingPaidAmount ? totalCost - existingPaidAmount : 0.0;
    final amountController = TextEditingController(text: '');
    final NumberFormat dialogCurrencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    bool isFormattingAmount = false;
    String? selectedMethod = transaction.paymentPlanMethod;
    String? amountError;
    String? methodError;
    bool isSubmitting = false;

    _dateController.clear();
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          final baseTheme = Theme.of(dialogContext);
          return StatefulBuilder(
            builder: (statefulContext, setDialogState) {
              return Theme(
                data: baseTheme.copyWith(
                  colorScheme: baseTheme.colorScheme.copyWith(
                    surface: Colors.white,
                    primary: Colors.black,
                  ),
                  dialogBackgroundColor: Colors.white,
                ),
                child: AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Payment Details",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Trip: ${transaction.tripCode}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Customer: ${transaction.customerName}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 12),

                        const Text(
                          "Payment Amount",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (existingPaidAmount > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Sudah dibayar: ${_formatCurrency(existingPaidAmount)}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                        if (totalCost > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'Total Biaya: ${_formatCurrency(totalCost)}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Sisa Hutang: ${_formatCurrency(remainingBalance)}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: amountController,
                          decoration: InputDecoration(
                            hintText: "Input Total",
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            errorText: amountError,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (value) {
                            if (isFormattingAmount) return;

                            final result = formatCurrencyInput(
                              value,
                              dialogCurrencyFormat,
                            );

                            if (result.shouldClear) {
                              isFormattingAmount = true;
                              amountController
                                ..text = ''
                                ..selection = const TextSelection.collapsed(
                                  offset: 0,
                                );
                              isFormattingAmount = false;
                              setDialogState(() {
                                amountError = null;
                              });
                              return;
                            }

                            if (!result.shouldUpdateText) {
                              setDialogState(() {
                                amountError = null;
                              });
                              return;
                            }

                            final formatted = result.formattedValue;
                            if (formatted == null) {
                              setDialogState(() {
                                amountError = null;
                              });
                              return;
                            }

                            isFormattingAmount = true;
                            amountController
                              ..text = formatted
                              ..selection = TextSelection.collapsed(
                                offset: formatted.length,
                              );
                            isFormattingAmount = false;
                            setDialogState(() {
                              amountError = null;
                            });
                          },
                        ),
                        const SizedBox(height: 10),

                        const Text(
                          "Payment Method",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value: selectedMethod,
                          items: const [
                            DropdownMenuItem(
                              value: 'cash',
                              child: Text('Cash'),
                            ),
                            DropdownMenuItem(
                              value: 'credit',
                              child: Text('Credit'),
                            ),
                          ],
                          onChanged: (value) {
                            setDialogState(() {
                              selectedMethod = value;
                              methodError = null;

                              if (value == 'cash') {
                                final double targetAmount =
                                    remainingBalance > 0
                                        ? remainingBalance
                                        : totalCost;
                                if (targetAmount > 0) {
                                  amountController.text =
                                      targetAmount % 1 == 0
                                          ? targetAmount.toStringAsFixed(0)
                                          : targetAmount.toStringAsFixed(2);
                                } else {
                                  amountController.clear();
                                }
                                amountError = null;
                              }
                            });
                          },
                          dropdownColor: Colors.white,
                          decoration: InputDecoration(
                            hintText: "Select Payment Method",
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            errorText: methodError,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                          ),
                          isExpanded: true,
                        ),
                        const SizedBox(height: 10),

                        const Text(
                          "Payment Type",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonFormField<String>(
                            dropdownColor: Colors.white,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                            ),
                            hint: const Text("Select Payment Type"),
                            items: const [
                              DropdownMenuItem(
                                value: "Cash",
                                child: Text("Cash"),
                              ),
                              DropdownMenuItem(
                                value: "Transfer",
                                child: Text("Transfer"),
                              ),
                            ],
                            onChanged: (value) {},
                          ),
                        ),
                        const SizedBox(height: 10),

                        const Text(
                          "Date",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _dateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: "Select Date",
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: dialogContext,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              _dateController.text = DateFormat(
                                'dd/MM/yyyy',
                              ).format(picked);
                            }
                          },
                        ),
                        const SizedBox(height: 10),

                        const Text(
                          "Note",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: "Write notes here...",
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    isSubmitting
                                        ? null
                                        : () =>
                                            Navigator.of(dialogContext).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text("Back"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    isSubmitting
                                        ? null
                                        : () async {
                                          final method = selectedMethod;
                                          final amountText =
                                              amountController.text.trim();
                                          final parsedAmount =
                                              amountText.isEmpty
                                                  ? 0.0
                                                  : double.tryParse(
                                                    amountText.replaceAll(
                                                      ',',
                                                      '',
                                                    ),
                                                  );

                                          String? amountValidation;
                                          String? methodValidation;

                                          if (method == null ||
                                              method.isEmpty) {
                                            methodValidation =
                                                'Pilih metode pembayaran';
                                          }
                                          if (parsedAmount == null) {
                                            amountValidation =
                                                'Nominal tidak valid';
                                          } else if (parsedAmount < 0) {
                                            amountValidation =
                                                'Nominal tidak boleh negatif';
                                          } else if (method == 'credit' &&
                                              parsedAmount > remainingBalance) {
                                            final double allowed =
                                                remainingBalance;
                                            amountValidation =
                                                'Nominal melebihi sisa hutang (${_formatCurrency(allowed)})';
                                          }

                                          if (amountValidation != null ||
                                              methodValidation != null) {
                                            setDialogState(() {
                                              amountError = amountValidation;
                                              methodError = methodValidation;
                                            });
                                            return;
                                          }

                                          setDialogState(() {
                                            isSubmitting = true;
                                            amountError = null;
                                            methodError = null;
                                          });

                                          try {
                                            await TransactionService.setPaymentPlan(
                                              transaction.id,
                                              {
                                                'payment_plan_method': method,
                                                'paid_amount': parsedAmount,
                                              },
                                            );

                                            if (!mounted) return;

                                            Navigator.of(dialogContext).pop();

                                            await _loadTransactions();

                                            if (!mounted) return;
                                            CustomFlushbar.show(
                                              context,
                                              message: 'Payment plan updated',
                                              type: FlushbarType.success,
                                            );
                                          } catch (error) {
                                            setDialogState(() {
                                              isSubmitting = false;
                                            });

                                            if (!mounted) return;
                                            CustomFlushbar.show(
                                              context,
                                              message: error.toString(),
                                              type: FlushbarType.error,
                                            );
                                          }
                                        },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child:
                                    isSubmitting
                                        ? const SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Text("Submit"),
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
        },
      );
    } finally {
      // Schedule disposal for the next frame to avoid disposing
      // while TextField still has focus/dependents
      WidgetsBinding.instance.addPostFrameCallback((_) {
        amountController.dispose();
      });
    }
  }
}
