import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:travelin/services/vehicle_service.dart';

import '../models/vehicle_models.dart';

class VehicleDropdown extends StatefulWidget {
  const VehicleDropdown({
    super.key,
    this.initialVehicle,
    this.onChanged,
    this.label = 'Vehicle',
    this.showLabel = true,
    this.hintText = 'Pilih kendaraan',
    this.leadingIcon = FontAwesomeIcons.car,
    this.autoSelectFirst = true,
    this.maxMenuHeight = 320,
  });

  final VehicleModel? initialVehicle;
  final ValueChanged<VehicleModel>? onChanged;
  final String label;
  final bool showLabel;
  final String hintText;
  final IconData leadingIcon;
  final bool autoSelectFirst;
  final double maxMenuHeight;

  @override
  State<VehicleDropdown> createState() => _VehicleDropdownState();
}

class _VehicleDropdownState extends State<VehicleDropdown> {
  bool _isLoading = false;
  bool _isOpen = false;
  String? _error;
  VehicleModel? _selected;
  int? _lastNotifiedVehicleId;
  List<VehicleModel> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialVehicle;
    _loadVehicles();
  }

  @override
  void didUpdateWidget(covariant VehicleDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialVehicle != null &&
        (oldWidget.initialVehicle == null ||
            widget.initialVehicle!.id != oldWidget.initialVehicle!.id)) {
      _selected = widget.initialVehicle;
      _lastNotifiedVehicleId = widget.initialVehicle!.id;
    }
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final vehicles = await VehicleService.getVehicles();
      if (!mounted) return;

      VehicleModel? next = _selected;
      if (next != null) {
        final index = vehicles.indexWhere((v) => v.id == next!.id);
        next = index != -1 ? vehicles[index] : null;
      }
      if (next == null && vehicles.isNotEmpty && widget.autoSelectFirst) {
        next = vehicles.first;
      }

      setState(() {
        _vehicles = vehicles;
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

  void _notifySelection(VehicleModel vehicle) {
    if (_lastNotifiedVehicleId == vehicle.id) return;
    _lastNotifiedVehicleId = vehicle.id;
    widget.onChanged?.call(vehicle);
  }

  void _toggleDropdown() {
    if (_vehicles.isEmpty) return;
    setState(() => _isOpen = !_isOpen);
  }

  void _selectVehicle(VehicleModel vehicle) {
    setState(() {
      _selected = vehicle;
      _isOpen = false;
    });
    _notifySelection(vehicle);
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
              onPressed: _loadVehicles,
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
                Row(
                  children: [
                    Icon(widget.leadingIcon, color: Colors.black87, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      _selected != null
                          ? _vehicleLabel(_selected!)
                          : widget.hintText,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
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
            child:
                _vehicles.isEmpty
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Tidak ada kendaraan tersedia'),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: _vehicles.length,
                      itemBuilder: (_, index) {
                        final vehicle = _vehicles[index];
                        final isSelected = _selected?.id == vehicle.id;
                        return InkWell(
                          onTap: () => _selectVehicle(vehicle),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Text(
                              _vehicleLabel(vehicle),
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? Colors.lightBlue
                                        : Colors.black87,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
      ],
    );
  }

  String _vehicleLabel(VehicleModel vehicle) {
    final parts = [
      if (vehicle.brand != null && vehicle.brand!.isNotEmpty) vehicle.brand!,
      if (vehicle.model != null && vehicle.model!.isNotEmpty) vehicle.model!,
      vehicle.plateNumber,
    ];
    final label =
        parts.where((part) => part.trim().isNotEmpty).join(' ').trim();
    return label.isNotEmpty ? label : 'Vehicle #${vehicle.id}';
  }
}
