import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/vehicle_models.dart';

class VehicleSelector extends StatelessWidget {
  final VehicleModel? selectedVehicle;
  final List<VehicleModel> vehicleList;
  final Future<void> Function(VehicleModel vehicle) onVehicleSelected;

  const VehicleSelector({
    super.key,
    required this.selectedVehicle,
    required this.vehicleList,
    required this.onVehicleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showVehicleBottomSheet(context),
      child: _buildTrigger(),
    );
  }

  Widget _buildTrigger() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F0FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              FontAwesomeIcons.bus,
              color: Colors.blue.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Kendaraan",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _vehicleLabelAny(selectedVehicle),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            FontAwesomeIcons.chevronDown,
            size: 16,
            color: Colors.blue.shade600,
          ),
        ],
      ),
    );
  }

  // ===============================
  // Modal Bottom Sheet
  // ===============================
  void _showVehicleBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          FontAwesomeIcons.bus,
                          color: Colors.blue.shade700,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Pilih Kendaraan",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // List Vehicle
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: vehicleList.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicleList[index];
                      final isSelected =
                          vehicle.id == selectedVehicle?.id;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue.shade50
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue.shade200
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            _vehicleLabel(vehicle),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.blue.shade900
                                  : Colors.black87,
                            ),
                          ),
                          trailing: isSelected
                              ? Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade600,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            ),
                          )
                              : null,
                          onTap: () async {
                            Navigator.pop(context);
                            await onVehicleSelected(vehicle);
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _vehicleLabelAny(VehicleModel? vehicle) {
    if (vehicle == null) return "Pilih Kendaraan";

    final parts = [
      if (vehicle.brand?.isNotEmpty == true) vehicle.brand!,
      if (vehicle.model?.isNotEmpty == true) vehicle.model!,
      vehicle.plateNumber,
    ];
    return parts.join(' ').trim();
  }

  static String _vehicleLabel(VehicleModel vehicle) {
    final parts = [
      if (vehicle.brand?.isNotEmpty == true) vehicle.brand!,
      if (vehicle.model?.isNotEmpty == true) vehicle.model!,
      vehicle.plateNumber,
    ];
    return parts.join(' ').trim();
  }
}
