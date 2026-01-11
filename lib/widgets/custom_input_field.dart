import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:travelin/utils/currency_utils.dart';

enum InputFieldType {
  defaultField,
  password,
  note,
  date,
  currency
}

class CustomInputField extends StatefulWidget {
  final String label;
  final IconData icon;
  final String hint;
  final TextEditingController controller;

  final InputFieldType type;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;

  final double? quickAmount;
  final NumberFormat? currencyFormat;

  const CustomInputField({
    super.key,
    required this.label,
    required this.icon,
    required this.hint,
    required this.controller,
    this.type = InputFieldType.defaultField,
    this.maxLines = 1,
    this.inputFormatters,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.enabled = true,
    this.focusNode,
    this.onChanged,
    this.onTap,
    this.quickAmount,
    this.currencyFormat,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late bool _obscure;
  late bool _isFormattingCurrency;
  late NumberFormat _currencyFormatter;

  @override
  void initState() {
    super.initState();
    _obscure = widget.type == InputFieldType.password;
    _isFormattingCurrency = false;

    _currencyFormatter = widget.currencyFormat ??
      NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
  }

  Future<void> _handleDateTap(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.controller.text =
        DateFormat('d MMM yyyy').format(picked);

      widget.onChanged?.call(
        DateFormat('yyyy-MM-dd').format(picked),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPassword = widget.type == InputFieldType.password;
    final bool isNote = widget.type == InputFieldType.note;
    final bool isDate = widget.type == InputFieldType.date;
    final bool isCurrency = widget.type == InputFieldType.currency;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black,
            letterSpacing: 0.1,
          ),
        ),

        const SizedBox(height: 8),

        // Text Field
        TextFormField(
          controller: widget.controller,
          readOnly: isDate,
          obscureText: isPassword ? _obscure : false,
          keyboardType: isNote ? TextInputType.multiline : widget.keyboardType,
          inputFormatters: isCurrency
              ? [FilteringTextInputFormatter.digitsOnly]
              : widget.inputFormatters,
          enabled: widget.enabled,
          focusNode: widget.focusNode,
          onChanged: isCurrency ? _handleCurrencyChanged : widget.onChanged,
          onTap: isDate
              ? () => _handleDateTap(context)
              : widget.onTap,
          validator: widget.validator,
          cursorColor: Colors.black,
          cursorErrorColor: Colors.red,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
          maxLines: isNote ? 3 : 1,
          textAlignVertical: isNote ? TextAlignVertical.top : TextAlignVertical.center,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,

            // Prefix Icon
            prefixIcon: isNote
                ? null
                : Icon(
              widget.icon,
              size: 16,
              color: widget.enabled ? Colors.blue : Colors.grey,
            ),

            // Hint
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            alignLabelWithHint: isNote,

            // Suffix Icon
            suffixIcon: _buildSuffixIcon(),

            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isNote ? 14 : 14,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
                width: 1.5,
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.blue,
                width: 2,
              ),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red,
                width: 1.5,
              ),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),

            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
            ),

            errorStyle: const TextStyle(
              fontSize: 12,
              height: 1.2,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    switch (widget.type) {
      case InputFieldType.currency:
        if (widget.quickAmount == null) return null;

        return IntrinsicWidth(
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            onTap: () {
              final formatted =
              _currencyFormatter.format(widget.quickAmount);

              widget.controller
                ..text = formatted
                ..selection = TextSelection.collapsed(
                  offset: formatted.length,
                );

              widget.onChanged?.call(formatted);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border.all(
                  color: Colors.blue,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                "MAX",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        );

      case InputFieldType.password:
        return IconButton(
          icon: Icon(
            _obscure
                ? FontAwesomeIcons.eyeSlash
                : FontAwesomeIcons.eye,
            size: 18,
            color: Colors.blue,
          ),
          onPressed: () {
            setState(() => _obscure = !_obscure);
          },
        );

      default:
        return null;
    }
  }

  void _handleCurrencyChanged(String value) {
    if (_isFormattingCurrency) return;

    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      widget.controller.text = '';
      return;
    }

    final number = int.parse(digits);
    final formatted = _currencyFormatter.format(number);

    _isFormattingCurrency = true;
    widget.controller
      ..text = formatted
      ..selection = TextSelection.collapsed(offset: formatted.length);
    _isFormattingCurrency = false;

    widget.onChanged?.call(widget.controller.text);
  }

}