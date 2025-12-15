import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../services/vehicle_service.dart';

class VehicleMasterPage extends StatefulWidget {
  const VehicleMasterPage({super.key});

  @override
  State<VehicleMasterPage> createState() => _VehicleMasterPageState();
}

class _VehicleMasterPageState extends State<VehicleMasterPage> {
  late Future<List<dynamic>> _vehicleFuture;

  @override
  void initState() {
    super.initState();
    _vehicleFuture = VehicleService.getVehicles();
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
          "Vehicle Master",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _vehicleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Gagal memuat data kendaraan",
                style: TextStyle(color: Colors.red[600]),
              ),
            );
          }

          final vehicles = snapshot.data ?? [];

          if (vehicles.isEmpty) {
            return const Center(
              child: Text("Data kendaraan belum tersedia"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return _vehicleCard(vehicle);
            },
          );
        },
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
            onPressed: () {},
            child: const Icon(FontAwesomeIcons.add, color: Colors.white, size: 26),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _vehicleCard(Map<String, dynamic> vehicle) {
    return Card(
      color: Colors.white,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => _showVehicleDetail(vehicle),
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: const Icon(FontAwesomeIcons.car, color: Colors.white, size: 16),
        ),
        title: Text(
          "${vehicle['brand']} ${vehicle['model']}",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(vehicle['plate_number']),
        trailing: const Icon(FontAwesomeIcons.angleRight, size: 18),
      ),
    );
  }

  void _showVehicleDetail(Map<String, dynamic> vehicle) {
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
                "Detail Kendaraan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _detailRow("Brand", vehicle['brand']),
              _detailRow("Model", vehicle['model']),
              _detailRow("Plate Nomor", vehicle['plate_number']),
              _detailRow("Tahun", vehicle['manufacture_year']),
              _detailRow(
                "Status",
                vehicle['status'] == 'active' ? "Active" : "Inactive",
              ),
              _detailRow("Catatan", vehicle['notes']),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: edit vehicle
                      },
                      icon: const Icon(FontAwesomeIcons.pencil, color: Colors.white, size: 16),
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
                      },
                      icon: const Icon(FontAwesomeIcons.trashCan, color: Colors.white, size: 16),
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

}