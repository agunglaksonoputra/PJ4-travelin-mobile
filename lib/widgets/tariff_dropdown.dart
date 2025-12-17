import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travelin/services/tariff_service.dart';

import '../models/tariff_model.dart';

class TariffDropdown extends StatefulWidget {
  const TariffDropdown({
    super.key,
    this.initialTariff,
    this.onChanged,
    this.onCleared,
    this.label = 'Tariff',
    this.showLabel = true,
    this.hintText = 'Pilih tarif',
    this.autoSelectFirst = false,
    this.includeAllItem = true,
    this.maxMenuHeight = 320,
  });

  final TariffModel? initialTariff;
  final ValueChanged<TariffModel?>? onChanged;
  final VoidCallback? onCleared;
  final String label;
  final bool showLabel;
  final String hintText;
  final bool autoSelectFirst;
  final bool includeAllItem;
  final double maxMenuHeight;

  @override
  State<TariffDropdown> createState() => _TariffDropdownState();
}

class _TariffDropdownState extends State<TariffDropdown> {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  bool _isLoading = false;
  bool _isOpen = false;
  String? _error;
  TariffModel? _selected;
  int? _lastNotifiedId;
  List<TariffModel> _tariffs = [];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialTariff;
    _loadTariffs();
  }

  @override
  void didUpdateWidget(covariant TariffDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTariff != null &&
        (oldWidget.initialTariff == null ||
            widget.initialTariff!.id != oldWidget.initialTariff!.id)) {
      _selected = widget.initialTariff;
      _lastNotifiedId = widget.initialTariff!.id;
    }
  }

  Future<void> _loadTariffs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tariffs = await TariffService.getTariffs();
      if (!mounted) return;

      TariffModel? next = _selected;
      if (next != null) {
        final index = tariffs.indexWhere((item) => item.id == next!.id);
        next = index != -1 ? tariffs[index] : null;
      }
      if (next == null && tariffs.isNotEmpty && widget.autoSelectFirst) {
        next = tariffs.first;
      }

      setState(() {
        _tariffs = tariffs;
        _selected = next;
        _isLoading = false;
      });

      if (next != null) {
        _notifySelection(next);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _notifySelection(TariffModel? tariff) {
    if (tariff == null) return;
    if (_lastNotifiedId == tariff.id) return;
    _lastNotifiedId = tariff.id;
    widget.onChanged?.call(tariff);
  }

  void _toggleDropdown() {
    if (_tariffs.isEmpty && !widget.includeAllItem) return;
    setState(() => _isOpen = !_isOpen);
  }

  void _selectTariff(TariffModel? tariff) {
    setState(() {
      _selected = tariff;
      _isOpen = false;
    });
    if (tariff == null) {
      _lastNotifiedId = null;
      widget.onCleared?.call();
    } else {
      _notifySelection(tariff);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
            IconButton(
              onPressed: _loadTariffs,
              icon: const Icon(Icons.refresh, color: Colors.redAccent),
            ),
          ],
        ),
      );
    }

    final hasLabel = widget.showLabel && widget.label.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasLabel)
          Text(
            widget.label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        if (hasLabel) const SizedBox(height: 6),
        GestureDetector(
          onTap: _toggleDropdown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selected != null
                      ? _tariffLabel(_selected!)
                      : widget.hintText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Icon(
                  _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
        if (_isOpen)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: BoxConstraints(maxHeight: widget.maxMenuHeight),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: _buildMenu(),
          ),
      ],
    );
  }

  Widget _buildMenu() {
    if (_tariffs.isEmpty && !widget.includeAllItem) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Tidak ada tarif tersedia'),
      );
    }

    final items = <Widget>[];

    if (widget.includeAllItem) {
      items.add(
        InkWell(
          onTap: () => _selectTariff(null),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Semua tarif',
              style: TextStyle(
                color: _selected == null ? Colors.lightBlue : Colors.black87,
                fontWeight:
                    _selected == null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }

    for (final tariff in _tariffs) {
      final isSelected = _selected?.id == tariff.id;
      items.add(
        InkWell(
          onTap: () => _selectTariff(tariff),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              _tariffLabel(tariff),
              style: TextStyle(
                color: isSelected ? Colors.lightBlue : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      children: items,
    );
  }

  String _tariffLabel(TariffModel tariff) {
    final price = tariff.basePrice;
    final formattedPrice =
        price != null ? _currencyFormat.format(price) : 'Tanpa harga';
    return '${tariff.code} • $formattedPrice';
  }
}
