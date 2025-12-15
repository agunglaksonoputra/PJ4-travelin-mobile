import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:travelin/widgets/custom_input_field.dart';

import '../../models/vehicle_models.dart';
import '../../services/vehicle_service.dart';

class VehicleMasterPage extends StatefulWidget {
  const VehicleMasterPage({super.key});

  @override
  State<VehicleMasterPage> createState() => _VehicleMasterPageState();
}

class _VehicleMasterPageState extends State<VehicleMasterPage> {
  List<VehicleModel> _vehicles = [];
  // String statusVehicle = 'active';

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    final data = await VehicleService.getVehicles();
    setState(() {
      _vehicles = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Vehicle Management",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
          child: Column(
            children: _vehicles.map((vehicle) {
              return _vehicleCard(vehicle);
            }).toList(),
          ),
        ),
      ),


      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 8),
        child: SizedBox(
          width: 50,
          height: 50,
          child: FloatingActionButton(
            backgroundColor: Colors.blue,
            elevation: 5,
            shape: const CircleBorder(),
            onPressed: () {
              _showAddVehicleModal();
            },
            child: const Icon(FontAwesomeIcons.add, color: Colors.white, size: 26),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _vehicleCard(VehicleModel vehicle) {
    return Card(
      color: Colors.white,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => _showVehicleDetail(vehicle),
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(FontAwesomeIcons.car, color: Colors.white, size: 16),
        ),
        title: Text(
          "${vehicle.brand ?? '-'} ${vehicle.model ?? ''}",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(vehicle.plateNumber),
        trailing: const Icon(FontAwesomeIcons.angleRight, size: 18),
      ),
    );
  }

  void _showVehicleDetail(VehicleModel vehicle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Detail Kendaraan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _detailRow("Brand", vehicle.brand),
              _detailRow("Model", vehicle.model),
              _detailRow("Plate Nomor", vehicle.plateNumber),
              _detailRow("Tahun", vehicle.manufactureYear),
              _detailRow(
                "Status",
                vehicle.status == 'active' ? "Active" : "Inactive",
              ),
              _detailRow("Catatan", vehicle.notes),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: edit vehicle
                        // Navigator.push(...)
                      },
                      icon: const Icon(
                        FontAwesomeIcons.pencil,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: const Text(
                        "Edit",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: delete vehicle
                        // VehicleModel.delete(vehicle.id)
                      },
                      icon: const Icon(
                        FontAwesomeIcons.trashCan,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value?.toString() ?? "-"),
          ),
        ],
      ),
    );
  }

  void _showAddVehicleModal() {
    final plateController = TextEditingController();
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final yearController = TextEditingController();
    final notesController = TextEditingController();

    String localStatus = 'active';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    const Text(
                      "Tambah Kendaraan",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    CustomInputField(
                      label: "Plat Nomor",
                      icon: FontAwesomeIcons.idCard,
                      hint: "B 1234 ABC",
                      controller: plateController,
                    ),
                    const SizedBox(height: 12),

                    CustomInputField(
                      label: "Brand",
                      icon: FontAwesomeIcons.carSide,
                      hint: "Toyota",
                      controller: brandController,
                    ),
                    const SizedBox(height: 12),

                    CustomInputField(
                      label: "Model",
                      icon: FontAwesomeIcons.car,
                      hint: "Avanza",
                      controller: modelController,
                    ),
                    const SizedBox(height: 12),

                    CustomInputField(
                      label: "Tahun",
                      icon: FontAwesomeIcons.calendar,
                      hint: "2023",
                      controller: yearController,
                    ),
                    const SizedBox(height: 12),

                    // ===== STATUS PICKER =====
                    const Text(
                      "Status",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {
                        _pickStatus(
                          current: localStatus,
                          onSelected: (value) {
                            setModalState(() {
                              localStatus = value;
                            });
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.toggle_on_outlined),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                localStatus == 'active'
                                    ? 'Active'
                                    : 'Inactive',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    CustomInputField(
                      label: "Catatan",
                      icon: FontAwesomeIcons.noteSticky,
                      hint: "Integration test",
                      controller: notesController,
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final payload = {
                                "plate_number": plateController.text,
                                "brand": brandController.text,
                                "model": modelController.text,
                                "manufacture_year":
                                int.tryParse(yearController.text),
                                "status": localStatus,
                                "notes": notesController.text,
                              };

                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text("Save"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _pickStatus({
    required String current,
    required Function(String) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _statusItem("Active", 'active', current, onSelected),
                _statusItem("Inactive", 'inactive', current, onSelected),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusItem(
      String label,
      String value,
      String current,
      Function(String) onSelected,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          onSelected(value);
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              if (current == value)
                const Icon(Icons.check, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

}